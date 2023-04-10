myDir = File.expand_path(File.dirname(__FILE__));
require "#{myDir}/../build-options.rb"
require "rakish/GitModule"

depends=[
]

Rakish.Project(
    :includes=>[Rakish::CppProjectModule, Rakish::GitModule ],
	:name 		 => "oss-libsdl",
	:dependsUpon => [ depends ]
) do

	libSource = "#{projectDir}/SDL2";

    setSourceSubdir(libSource);
	file libSource do |t|
       git.clone('https://github.com/libsdl-org/SDL.git', t.name );
	end

    vendorBuildDir = ensureDirectoryTask("#{projectDir}/build");

    task :includes => libSource;

    export task :cleanAll => sourceSubdir do |t|
        FileUtils.rm_rf(vendorBuildDir);  # remove recursive
#         FileUtils.cd sourceSubdir do
#             system('git reset --hard');  # Maybe delete and re-download - though a bit slow
#         end
    end

    setupCppConfig :targetType=>'DLL' do |cfg|
        cfg.targetName = 'libsdl';

        pubTargs = task :publicTargets;

        cfg.cmakeExport = true;

        task :buildVendorLibs => [sourceSubdir] do |t|
            FileUtils.mkdir_p(vendorBuildDir);  # make sure it is there
            FileUtils::cd(vendorBuildDir) do

                cmd = nil;

                # option(SDL_SHARED "Build a shared version of the library" ${SDL_SHARED_ENABLED_BY_DEFAULT})
                # option(SDL_STATIC "Build a static version of the library" ${SDL_STATIC_ENABLED_BY_DEFAULT})
                # option(SDL_TEST   "Build the SDL3_test library" ON)
                if(targetPlatform =~ /Windows/ )
                    cmd = "#{cmakeCommand} -G \"Visual Studio 16 2019\" \"-B#{vendorBuildDir}\" .. "
                    system(cmd);
                elsif(targetPlatform =~ /MacOS/)
                end
            end

            FileUtils::cd(projectDir) do

                # list of files to copy to main build lib and bin areas
                flist = [];

                if(targetPlatform =~ /Windows/ )

                    cmd = "#{cmakeCommand} --build build --config RELEASE";
                    system(cmd);
                    cmd = "#{cmakeCommand} --build build --config DEBUG";
                    system(cmd);

                    flist << createCopyTasks("#{buildDir}/bin",
                                            "#{vendorBuildDir}/bin/Release/*.*",
                                            "#{vendorBuildDir}/bin/Debug/*.*",
                                            :basedir => "#{vendorBuildDir}/bin"
                                           )

                    flist << createCopyTasks("#{buildDir}/lib",
                                            "#{vendorBuildDir}/lib/Release/*.*",
                                            "#{vendorBuildDir}/lib/Debug/*.*",
                                            :basedir => "#{vendorBuildDir}/lib"
                                           )
                    # necessary - hope it works
                    # flist << createCopyTask("#{sourceSubdir}/scripts/pnglibconf.h.prebuilt", "#{buildIncludeDir()}/pnglibconf.h" );

                elsif(targetPlatform =~ /MacOS/)

#                    flist = createCopyTasks("#{nativeLibDir}",
#                                            "#{vendorBuildDir}/libpng/libpng#{cfg.dllExt}",
#                                            :basedir => "#{vendorBuildDir}/libpng"
#                                           )
#                    flist << createCopyTask("#{sourceSubdir}/scripts/pnglibconf.h.prebuilt", "#{buildIncludeDir()}/pnglibconf.h" );
                end

                task pubTargs.addDependencies(flist); # add dependencies to :publicTargets
            end

            explibs = [];
            if(targetPlatform =~ /Windows/)
#                 ifiles = addPublicIncludes("#{libSource}/png*.h",
#                                             :destdir=> "" );
#
#                 pubTargs.addDependencies(ifiles);
                explibs = "#{nativeLibDir}/SDL3#{cfg.libExt}";
            elsif(targetPlatform =~ /MacOS/)
#                 explibs = "/opt/homebrew/lib/libpng.dylib";
            end
            log.debug("############# #{explibs}");
            cfg.addExportedLibs(explibs);
        end

        export task :vendorLibs => [ :buildVendorLibs, :includes, :publicTargets ] do
        end
    end

end

