myDir = File.expand_path(File.dirname(__FILE__));
require "#{myDir}/../build-options.rb"
require "rakish/GitModule"

depends=[
]

Rakish.Project(
    :includes=>[Rakish::CppProjectModule, Rakish::GitModule ],
	:name 		 => "tinyobjloader",
	:dependsUpon => [ depends ]
) do

	libSource = "#{projectDir}/tinyobjloader";

    setSourceSubdir(libSource);

	file libSource do |t|
        git.clone('https://github.com/tinyobjloader/tinyobjloader.git', t.name);
	end

    vendorBuildDir = ensureDirectoryTask("#{projectDir}/build");

    task :includes => libSource;

    export task :cleanAll => sourceSubdir do |t|
        FileUtils.rm_rf(vendorBuildDir);  # remove recursive
    end

    setupCppConfig :targetType=>'DLL' do |cfg|
        cfg.targetName = 'SPIRV-Reflect';

        pubTargs = task :publicTargets;

        cfg.cmakeExport = true;

        task :buildVendorLibs => [sourceSubdir] do |t|
            FileUtils.mkdir_p(vendorBuildDir);  # make sure it is there

            FileUtils::cd(vendorBuildDir) do

                cmd = "#{cmakeCommand} -G \"#{cMakeGenerator}\" -B \"#{vendorBuildDir}\""

                cmd += " \"-DTINYOBJLOADER_USE_DOUBLE=OFF\"" # "Build library with double precision instead of single (float)" OFF)
                cmd += " \"-DTINYOBJLOADER_BUILD_TEST_LOADER=OFF\"" # "Build Example Loader Application" OFF)
                cmd += " \"-DTINYOBJLOADER_BUILD_OBJ_STICHER=OFF\"" # "Build OBJ Sticher Application" OFF)

                cmd += " ..";
                system(cmd);
            end

            FileUtils::cd(projectDir) do

                # list of files to "install" in main build
                flist = [];

                cmd = "#{cmakeCommand} --build build --config RELEASE";
                system(cmd);
                cmd = "#{cmakeCommand} --build build --config DEBUG";
                system(cmd);

                if(targetPlatform =~ /Windows/ )
                    flist << createCopyTasks("#{buildDir}/lib",
                                            "#{vendorBuildDir}/lib/Release/*.*",
                                            "#{vendorBuildDir}/lib/Debug/*.*",
                                            :basedir => "#{vendorBuildDir}/lib"
                                           )
                elsif(targetPlatform =~ /MacOS/)
#                     flist << createCopyTasks("#{buildDir}/lib",
#                                             "#{vendorBuildDir}/lib/Release/libspirv-reflect-*",
#                                             "#{vendorBuildDir}/lib/Debug/libspirv-reflect-*",
#                                             :basedir => "#{vendorBuildDir}/lib"
#                                            )
                 end
                 task pubTargs.addDependencies(flist); # add dependencies to :publicTargets
            end

            ifiles = addPublicIncludes( "#{libSource}/*.h",
                                         :destdir=> "" );
            ifiles << addPublicIncludes(  "#{libSource}/mapbox/*.hpp",
                                         :destdir=> "mapbox" );

            pubTargs.addDependencies(ifiles);

            explibs = []
            if(targetPlatform =~ /Windows/ )
                explibs << "#{buildDir}/lib/Debug/*.lib"; # to do debug and release ? depending on config
            elsif(targetPlatform =~ /MacOS/)
#                explibs << "#{buildDir}/lib/Debug/libspirv-reflect-static#{cfg.libExt}";
            end

            cfg.addExportedLibs(explibs);
        end

        export task :vendorLibs => [ :buildVendorLibs, :includes, :publicTargets ] do
        end
    end

end

