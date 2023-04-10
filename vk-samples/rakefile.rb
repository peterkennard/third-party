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


    source2 = file "#{projectName}/vulkan-guide" do |t|
	    git.clone("https://github.com/vblanco20-1/vulkan-guide.git", t.name );
	end

	file sourceSubdir do |t|
	    git.clone("https://github.com/KhronosGroup/Vulkan-Samples.git", t.name, :args=>"--recurse-submodules" );
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

            FileUtils::cd(sourceSubdir) do

                cmd = nil;

                #     VKB_<sample_name>
                #     Choose whether to include a sample at build time.
                #
                #     ON - Build Sample
                #     OFF - Exclude Sample
                #     Default: ON
                #
                #     VKB_BUILD_SAMPLES
                #     Choose whether to build the samples.
                #
                #     ON - Build All Samples
                #     OFF - Skip building Samples
                #     Default: ON
                #
                #     VKB_BUILD_TESTS
                #     Choose whether to build the tests
                #
                #     ON - Build All Tests
                #     OFF - Skip building Tests
                #     Default: OFF
                #
                #     VKB_VALIDATION_LAYERS
                #     Enable Validation Layers
                #
                #     Default: OFF
                #
                #     VKB_VALIDATION_LAYERS_GPU_ASSISTED
                #     Enable GPU assisted Validation Layers, used primarily for VK_EXT_descriptor_indexing.
                #
                #     Default: OFF
                #
                #     VKB_VULKAN_DEBUG
                #     Enable VK_EXT_debug_utils or VK_EXT_debug_marker, if supported. This enables debug names for Vulkan objects, and markers/labels in command buffers.
                #     See the debug utils sample for more information.
                #
                #     Default: ON
                #
                #     VKB_WARNINGS_AS_ERRORS
                #     Treat all warnings as errors
                #
                #     Default: ON


                if(targetPlatform =~ /Windows/ )
#                    cmd = "\"#{cmakeCommand}\" -G\"Visual Studio 16 2019\" -S\"#{sourceSubdir}\" \"-B#{sourceSubdir}/build/windows\"";
                    cmd = "\"#{cmakeCommand}\" -G\"Visual Studio 16 2019\" -A x64 -S\"#{sourceSubdir}\" \"-B#{sourceSubdir}/build/windows\"";
                elsif(targetPlatform =~ /MacOS/)
                end
                log.debug("##### \"\n#{cmd}\"\n");
                # cmd += " .."
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

        export task :genProject => [ sourceSubdir, :buildVendorLibs ] do
        end

        export task :vendorLibs => [ source2, sourceSubdir ] do
        end
    end

end

