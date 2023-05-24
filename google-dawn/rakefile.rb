
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
    # git log -n 1 --pretty=format:"%H" dawn  #To get only hash value

	file libSource do |t|
	    git.clone("https://github.com/eliemichel/WebGPU-distribution.git", t.name );

        # fb6de4001817debc150bab255dc073e3eb506589
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

                flist = nil;

                if(targetPlatform =~ /Windows/ )
                    # list of files to copy to main build lib and bin areas
                    flist = createCopyTasks("#{buildDir}",
                                            "#{vendorBuildDir}/lib/Debug/*.lib",
                                            "#{vendorBuildDir}/lib/Debug/*.lib",
                                            :basedir => "#{vendorBuildDir}"
                                            )
                elsif(targetPlatform =~ /MacOS/)
                    flist=[]
                end

                pubTargs.addDependencies(flist); # add dependencies to :publicTargets
            end

            if(targetPlatform =~ /Windows/)
                incfiles = addPublicIncludes(
                   "#{vendorBuildDir}/_deps/dawn-build/gen/include/dawn/*.h",
                   "#{vendorBuildDir}/_deps/dawn-src/include/dawn/*.h",
                   :destdir => "dawn"
                );
                incfiles << addPublicIncludes(
                    "#{vendorBuildDir}/_deps/dawn-src/include/webgpu/webgpu.h",
                    :destdir => "dawn"
                );
                incfiles << addPublicIncludes(
                    "#{vendorBuildDir}/_deps/dawn-src/include/webgpu/webgpu.h",
                    "#{libSource}/include/webgpu/webgpu.hpp",
                    :destdir => "webgpu"
                );
                incfiles << addPublicIncludes(
                    "#{vendorBuildDir}/_deps/dawn-src/include/dawn/native/*.h",
                    :destdir => "dawn/native"
                );
                incfiles << addPublicIncludes(
                    "#{vendorBuildDir}/_deps/dawn-src/include/dawn/platform/*.h",
                    :destdir => "dawn/platform"
                );
                pubTargs.addDependencies(incfiles);

                cfg.addExportedLibs("#{buildDir}/lib/Release/absl_*.lib");
                cfg.addExportedLibs("#{buildDir}/lib/Release/dawn_*.lib");
                cfg.addExportedLibs("#{buildDir}/lib/Release/dawncpp*.*");
                cfg.addExportedLibs("#{buildDir}/lib/Release/tint*.*");
                cfg.addExportedLibs("#{buildDir}/lib/Release/webgpu*.*");

            end
        end

        export task :vendorLibs => [ libSource, :buildVendorLibs, :publicTargets ] do |t|
        end

    end

end  # project
