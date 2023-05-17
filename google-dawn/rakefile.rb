
myDir = File.expand_path(File.dirname(__FILE__));
require "#{myDir}/../build-options.rb"
require "rakish/GitModule"

depends=[
    # "../google-depot-tools"
];

Rakish.Project(
    :includes=>[Rakish::CppProjectModule, Rakish::GitModule ],
    :id          => "",
	:name 		 => "google-dawn",
	:dependsUpon => [ depends ]
) do

    tools_path = File.expand_path("../google-depot-tools/depot_tools");

	libSource = "#{projectDir}/dawn-dist";

    vendorBuildDir = ensureDirectoryTask("#{projectDir}/build");
    setSourceSubdir(libSource);

    # readme on building
    # https://github.com/eliemichel/LearnWebGPU

	file libSource do |t|
	    git.clone("https://github.com/eliemichel/WebGPU-distribution.git", t.name );
	    FileUtils.cd(t.name) do
	        git.checkout("dawn");
	    end
	end

    setupCppConfig :targetType=>'DLL' do |cfg|

        cfg.targetName = 'google-dawn';

        pubTargs = task :publicTargets;

        task :buildVendorLibs => [libSource] do |t|
            FileUtils.mkdir_p(vendorBuildDir);  # make sure it is there

            FileUtils.cd(vendorBuildDir) do

                if(targetPlatform =~ /Windows/)
                    cmd = "#{cmakeCommand} -B \"#{vendorBuildDir}\"";
                    cmd += " -DWEBGPU_BACKEND=DAWN";
                    cmd += " ..";
                    system(cmd);
                elsif(targetPlatform =~ /MacOS/)
                end
            end

            cfg.cmakeExport = true;

            FileUtils::cd(projectDir) do
                if(targetPlatform =~ /Windows/)
                    cmd = "#{cmakeCommand} --build build --config RELEASE";
                    system(cmd);
                    cmd = "#{cmakeCommand} --build build --config DEBUG";
                    system(cmd);
                elsif(targetPlatform =~ /MacOS/)
                end
            end

            if(targetPlatform =~ /Windows/)
                incfiles = addPublicIncludes(
                   "#{vendorBuildDir}/_deps/dawn-src/include/dawn/*.h",
                   :destdir => "dawn"
                );
                incfiles << addPublicIncludes(
                    "#{libSource}/include/webgpu/*.hpp",
                    :destdir => "webgpu"
                );
                pubTargs.addDependencies(incfiles);

                cfg.addExportedLibs("#{vendorBuildDir}/lib/Release/*.lib");

            end
        end

        export task :vendorLibs => [ libSource, :buildVendorLibs, :publicTargets ] do |t|
        end

    end

end  # project
