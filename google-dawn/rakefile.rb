
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

    opath = ENV['PATH'];
    ENV['PATH'] = "#{tools_path}#{pathSeparator}#{opath}";

	libSource = "#{projectDir}/dawn";

    vendorBuildDir = ensureDirectoryTask("#{projectDir}/build");
    setSourceSubdir(libSource);

    # readme on building
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

            FileUtils::mkdir_p(vendorBuildDir);  # make sure it is there

            FileUtils.cd(libSource) do

               log.debug("############# now in #{libSource}");

                # to do make this a dependency task ? ".gclient" ?

                system( "cp ./scripts/standalone.gclient .gclient" );
                system( "gclient sync");

                log.debug("############# building with make");
                FileUtils::mkdir_p("out/debug");

                FileUtils.cd("out/debug") do
                    system("cmake ../..");
                    system("make");  # -j N for N-way parallel
                end
            end
        end

        export task :vendorLibs => [ libSource, :buildVendorLibs ] do |t|
        end

    end

end  # project





#    export task :vendorLibs => [ :buildVendorLibs, :includes, :publicTargets ] do |t|
#    end


