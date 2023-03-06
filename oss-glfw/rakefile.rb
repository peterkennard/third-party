myDir = File.expand_path(File.dirname(__FILE__));
require "#{myDir}/../build-options.rb"
require "rakish/GitModule"

depends=[
]

Rakish.Project(
    :includes=>[Rakish::CppProjectModule, Rakish::GitModule ],
	:name 		 => "oss-glfw",
	:dependsUpon => [ depends ]
) do

	libSource = "#{projectDir}/glfw";

    setSourceSubdir(libSource);

	file libSource do |t|
	    git.clone("https://github.com/glfw/glfw.git", t.name );
		# git.clone("git.didi.co:/home/didi/oss-vendor/freetype2.git", t.name );
		git.checkout("master", :dir=>t.name);
	end

    vendorBuildDir = ensureDirectoryTask("#{projectDir}/build");

    task :includes => libSource;

    export task :cleanAll => sourceSubdir do |t|
        FileUtils.rm_rf(vendorBuildDir);  # remove recursive
        FileUtils.cd sourceSubdir do
            system('git reset --hard');  # Maybe delete and re-download - though a bit slow
        end
    end

    setupCppConfig :targetType=>'DLL' do |cfg|
        cfg.targetName = 'glfw';

        pubTargs = task :publicTargets;

        cfg.cmakeExport = true;

        if(targetPlatform =~ /Windows/ )
#             cfg.addThirdPartyLibs(
#                 "#{vendorBuildDir}/bin/Debug/libpng16d.dll",
#                 "#{vendorBuildDir}/lib/Debug/libpng16d.lib"
#             );
        elsif(targetPlatform =~ /MacOS/)
        end

        task :buildVendorLibs => [sourceSubdir] do |t|
            FileUtils.mkdir_p(vendorBuildDir);  # make sure it is there
            FileUtils::cd(vendorBuildDir) do

                cmd = nil;

                if(targetPlatform =~ /Windows/ )
                    cmd=" echo \"build not implemented for Windows\""
                elsif(targetPlatform =~ /MacOS/)
                    cmd = "#{cmakeCommand} -G \"Unix Makefiles\""
                    cmd += " \"-DBUILD_SHARED_LIBS=1\""
                    cmd += " \"-DGLFW_BUILD_TESTS=0\""
                    cmd += " \"-DGLFW_BUILD_DOCS=0\""
                    cmd += " \"-DGLFW_INSTALL=0\""
                end
                cmd += " .."
                system(cmd);
            end
            FileUtils::cd(projectDir) do
              cmd = "#{cmakeCommand} --build build --config RELEASE";
              system(cmd);
#                cmd = "#{cmakeCommand} --build build --config DEBUG";
#                 system(cmd);
#
                # list of files to copy to main build lib and bin areas
                flist = nil;
                if(targetPlatform =~ /Windows/ )
                    flist = [];
#                     createCopyTasks("#{buildDir}",
#                                             "#{vendorBuildDir}/bin/Debug/libpng*.*",
#                                             "#{vendorBuildDir}/bin/Release/libpng*.*",
#                                             "#{vendorBuildDir}/lib/Debug/libpng*.*",
#                                             "#{vendorBuildDir}/lib/Release/libpng*.*",
#                                             :basedir => "#{vendorBuildDir}"
#                                             )
                elsif(targetPlatform =~ /MacOS/)
                    flist = createCopyTasks("#{nativeLibDir}",
                                            "#{vendorBuildDir}/lib/libglfw*#{cfg.dllExt}",
                                            :basedir => "#{vendorBuildDir}/lib"
                                           )
                end

                task pubTargs.addDependencies(flist); # add dependencies to :publicTargets
            end

            ifiles = addPublicIncludes("#{libSource}/include/GLFW/*.h",
                                       :destdir=> "GLFW" );

            pubTargs.addDependencies(ifiles);

             cfg.addExportedLibs(
                 "#{nativeLibDir}/libglfw#{cfg.dllExt}"
             );

        end

        export task :vendorLibs => [ :buildVendorLibs, :includes, :publicTargets ] do
        end
    end

end

