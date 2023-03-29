myDir = File.expand_path(File.dirname(__FILE__));
require "#{myDir}/../build-options.rb"
require "rakish/GitModule"

depends=[
]

Rakish.Project(
    :includes=>[Rakish::CppProjectModule, Rakish::GitModule ],
	:name 		 => "vk-spir-reflect",
	:dependsUpon => [ depends ]
) do

	libSource = "#{projectDir}/SPIRV-reflect";

    setSourceSubdir(libSource);

	file libSource do |t|
        git.clone('https://github.com/KhronosGroup/SPIRV-Reflect.git', t.name);
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
                cmd = nil;
                cmd = "#{cmakeCommand} -G \"#{cMakeGenerator}\" -B \"#{vendorBuildDir}\""

                if(targetPlatform =~ /Windows/ )
                    cmd += " \"-DSPIRV_REFLECT_EXECUTABLE=ON\""        #   "Build spirv-reflect executable" ON)
                elsif(targetPlatform =~ /MacOS/)
                    cmd += " \"-DSPIRV_REFLECT_EXECUTABLE=OFF\""        #   "Build spirv-reflect executable" ON)
                end

                cmd += " \"-DSPIRV_REFLECT_EXAMPLES=OFF\""         #   "Build stripper examples" ON)
                cmd += " \"-DSPIRV_REFLECT_STRIPPER=OFF\""         #   "Build stripper utility" OFF)
                cmd += " \"-DSPIRV_REFLECT_STATIC_LIB=ON\""        #   "Build a SPIRV-Reflect static library" OFF)
                cmd += " \"-DSPIRV_REFLECT_BUILD_TESTS=OFF\""      #    "Build the SPIRV-Reflect test suite" OFF)
                cmd += " \"-DSPIRV_REFLECT_ENABLE_ASSERTS=OFF\""   # "Enable asserts for debugging" OFF)

                cmd += " ..";
                system(cmd);
            end

            FileUtils::cd(projectDir) do

                # list of files to copy to main build lib and bin areas
                flist = [];

                cmd = "#{cmakeCommand} --build build --config RELEASE";
                system(cmd);
                cmd = "#{cmakeCommand} --build build --config DEBUG";
                system(cmd);

                flist << createCopyTasks("#{buildDir}/bin",
                                        "#{vendorBuildDir}/bin/Release/spirv-reflect-*",
                                        "#{vendorBuildDir}/bin/Debug/spirv-reflect-*",
                                        :basedir => "#{vendorBuildDir}/bin"
                                       )

                if(targetPlatform =~ /Windows/ )
                    flist << createCopyTasks("#{buildDir}/lib",
                                            "#{vendorBuildDir}/lib/Release/spirv-reflect-*",
                                            "#{vendorBuildDir}/lib/Debug/spirv-reflect-*",
                                            :basedir => "#{vendorBuildDir}/lib"
                                           )
                elsif(targetPlatform =~ /MacOS/)
                    flist << createCopyTasks("#{buildDir}/lib",
                                            "#{vendorBuildDir}/lib/Release/libspirv-reflect-*",
                                            "#{vendorBuildDir}/lib/Debug/libspirv-reflect-*",
                                            :basedir => "#{vendorBuildDir}/lib"
                                           )
                end

                task pubTargs.addDependencies(flist); # add dependencies to :publicTargets
            end

            ifiles = addPublicIncludes("#{libSource}/include/spirv/unified1/spirv.h",
                                         :destdir=> "spirv/unified1" );

            ifiles << addPublicIncludes("#{libSource}/spirv_reflect.h",
                                        :destdir=> "" );

            pubTargs.addDependencies(ifiles);

            explibs = []
            if(targetPlatform =~ /Windows/ )
                explibs << "#{buildDir}/lib/Debug/spirv-reflect-static#{cfg.libExt}";
            elsif(targetPlatform =~ /MacOS/)
                explibs << "#{buildDir}/lib/Debug/libspirv-reflect-static#{cfg.libExt}";
            end

            cfg.addExportedLibs(explibs);
        end

        export task :vendorLibs => [ :buildVendorLibs, :includes, :publicTargets, "#{projectDir}/CMakeExports.raked" ] do
        end
    end

end

