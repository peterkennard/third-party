
myDir = File.expand_path(File.dirname(__FILE__));
require "#{myDir}/../build-options.rb"
require "rakish/GitModule"

depends=[
    "../google-depot-tools"
];

Rakish.Project(
    :includes=>[Rakish::CppProjectModule, Rakish::GitModule ],
    :id          => "",
	:name 		 => "google-dawn",
	:dependsUpon => [ depends ]
) do

    tools_path = File.expand_path("../google-depot-tools/depot_tools");

	libSource = "#{projectDir}/dawn";

    vendorBuildDir = ensureDirectoryTask("#{projectDir}/build");
    setSourceSubdir(libSource);

    # readme on building
    # https://github.com/cwoffenden/hello-webgpu/blob/main/lib/README.md

    # https://dawn.googlesource.com/dawn/+/refs/heads/chromium-gpu-experimental/README.md

	file libSource do |t|
	    git.clone("https://dawn.googlesource.com/dawn", t.name );
	    FileUtils.cd(t.name) do
	        git.checkout("chromium/4473");
	    end
	end

    setupCppConfig :targetType=>'DLL' do |cfg|


        cfg.targetName = 'google-dawn';

        pubTargs = task :publicTargets;

       task :buildVendorLibs => [libSource] do |t|

            opath = ENV['PATH'];
            begin
                ENV['PATH'] = "#{tools_path}#{pathSeparator}#{opath}";
                ENV['DEPOT_TOOLS_WIN_TOOLCHAIN']="0";
                ENV['DEPOT_TOOLS_UPDATE']="1";

                FileUtils::mkdir_p(vendorBuildDir);  # make sure it is there

                FileUtils.cd(libSource) do

                    # to do make this a dependency task ? ".gclient" ?

                    system( "cp ./scripts/standalone.gclient .gclient" );
                    system( "bash -c \"gclient sync\"");
                    system("bash -c \"gclient sync\"");
                    system("bash -c \"gn args out/Release\"");

                    FileUtils::mkdir_p("out/Release");
                    system("bash -c \"ninja -C out/Release src/dawn/native:shared src/dawn/platform:shared proc_shared webgpu_dawn\"");

                  #  FileUtils.cd("out/Release") do
                  #      system("cmake ../..");
                  #      system("make");  # -j N for N-way parallel
                  #  end
                end
            rescue
                ENV['DEPOT_TOOLS_WIN_TOOLCHAIN']="";
                ENV['PATH'] = opath;
            end
        end

        export task :vendorLibs => [ libSource, :buildVendorLibs ] do |t|
        end

    end

end  # project





#    export task :vendorLibs => [ :buildVendorLibs, :includes, :publicTargets ] do |t|
#    end


