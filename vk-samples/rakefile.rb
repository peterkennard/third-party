myDir = File.expand_path(File.dirname(__FILE__));
require "#{myDir}/../build-options.rb"
require "rakish/GitModule"

depends=[
]

Rakish.Project(
    :includes=>[Rakish::CppProjectModule, Rakish::GitModule ],
	:name 		 => "vk-samples",
	:dependsUpon => [ depends ]
) do

	setSourceSubdir("#{projectDir}/Vulkan-Samples");

	file sourceSubdir do |t|
	    git.clone("https://github.com/KhronosGroup/Vulkan-Samples.git", t.name );
	end

    vendorBuildDir = ensureDirectoryTask("#{projectDir}/build");

    task :includes => sourceSubdir;

    export task :cleanAll => sourceSubdir do |t|
        # FileUtils.rm_rf(vendorBuildDir);  # remove recursive
        FileUtils.cd sourceSubdir do
            system('git reset --hard');  # Maybe delete and re-download - though a bit slow
        end
    end

    setupCppConfig :targetType=>'DLL' do |cfg|
        cfg.targetName = 'glfw';

        pubTargs = task :publicTargets;

        if(targetPlatform =~ /Windows/ )
        elsif(targetPlatform =~ /MacOS/)
        end

        task :buildVendorLibs => [sourceSubdir] do |t|
            FileUtils.mkdir_p(vendorBuildDir);  # make sure it is there
            FileUtils::cd(vendorBuildDir) do

                cmd = nil;

                if(targetPlatform =~ /Windows/ )
                    cmd = "#{cmakeCommand} -G \"Visual Studio 16 2019\""
                    cmd += " \"-DBUILD_SHARED_LIBS=1\""
                    cmd += " \"-DGLFW_BUILD_TESTS=0\""
                    cmd += " \"-DGLFW_BUILD_DOCS=0\""
                    cmd += " \"-DGLFW_INSTALL=0\""
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

                # list of files to copy to main build lib and bin areas
                flist = nil;


#                 if(targetPlatform =~ /Windows/ )
#
#                     cmd = "#{cmakeCommand} --build build --config DEBUG";
#                     system(cmd);
#
#                     flist = [];
#
#                     flist << createCopyTasks("#{binDir}",
#                                             "#{vendorBuildDir}/bin/Debug/glfw3.dll",
#                                             "#{vendorBuildDir}/bin/Debug/glfw3.pdb",
#                                             :basedir => "#{vendorBuildDir}/bin/Debug"
#                                            )
#                     flist << createCopyTasks("#{nativeLibDir}",
#                                             "#{vendorBuildDir}/lib/Debug/glfw3dll.lib",
#                                             :basedir => "#{vendorBuildDir}/lib/Debug"
#                                            )
#                 elsif(targetPlatform =~ /MacOS/)
#
#                     flist = createCopyTasks("#{nativeLibDir}",
#                                             "#{vendorBuildDir}/lib/libglfw*#{cfg.dllExt}",
#                                             :basedir => "#{vendorBuildDir}/lib/Debug"
#                                            )
#                 end
#
#                 task pubTargs.addDependencies(flist); # add dependencies to :publicTargets
            end

#             ifiles = addPublicIncludes("#{libSource}/include/GLFW/*.h",
#                                        :destdir=> "GLFW" );
#
#             pubTargs.addDependencies(ifiles);

#             explibs = nil;
#             if(targetPlatform =~ /Windows/ )
#                  explibs = "#{nativeLibDir}/glfw3dll#{cfg.libExt}";
#             elsif(targetPlatform =~ /MacOS/)
#                  explibs = "#{nativeLibDir}/libglfw#{cfg.dllExt}";
#             end
#             cfg.addExportedLibs(explibs);

        end

        export task :vendorLibs => [ sourceSubdir ] do # :buildVendorLibs, :includes, :publicTargets ] do
        end
    end

end

