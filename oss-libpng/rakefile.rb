myDir = File.expand_path(File.dirname(__FILE__));
require "#{myDir}/../build-options.rb"
require "rakish/GitModule"

depends=[
    "../oss-zlib"
]

Rakish.Project(
    :includes=>[Rakish::CppProjectModule, Rakish::GitModule ],
	:name 		 => "oss-libpng",
	:dependsUpon => [ depends ]
) do

	libSource = "#{projectDir}/libpng";

    setSourceSubdir(libSource);

	file libSource do |t|

        if(targetPlatform =~ /Windows/ )
            git.clone('https://github.com/emscripten-ports/libpng.git', t.name );
            git.checkout("libpng16", :dir=>libSource );
        elsif(targetPlatform =~ /MacOS/)
            # git.clone("https://github.com/glennrp/libpng.git", t.name );
            # git.checkout("libpng16", :dir=>libSource );
        end
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
        cfg.targetName = 'libpng';

        pubTargs = task :publicTargets;

        cfg.cmakeExport = true;

        task :buildVendorLibs => [sourceSubdir] do |t|
            FileUtils.mkdir_p(vendorBuildDir);  # make sure it is there
            FileUtils::cd(vendorBuildDir) do

                cmd = nil;

                if(targetPlatform =~ /Windows/ )

                    cmd = "#{cmakeCommand} -G \"#{cMakeGenerator}\" -B \"#{vendorBuildDir}\""
                    cmd += " \"-DBUILD_SHARED_LIBS=1\""
                    cmd += " \"-DZLIB_LIBRARY=#{buildDir}/lib/Debug/zlib.lib\""
                    cmd += " \"-DZLIB_INCLUDE_DIR=#{buildDir}/include\""

                    cmd += " .."
                    system(cmd);

                 elsif(targetPlatform =~ /MacOS/)

#                     cmd = "#{cmakeCommand} -G \"#{cMakeGenerator}\" -B \"#{vendorBuildDir}\""
#                     # cmd = "#{cmakeCommand} -G \"Unix Makefiles\" -B \"#{vendorBuildDir}\""
#                     cmd += " \"-DPNG_SHARED=1\""
#                     cmd += " \"-DPNG_STATIC=1\""
#                     cmd += " \"-DPNG_FRAMEWORK=1\""
#                     cmd += " \"-DPNG_EXECUTABLES=0\""
#                     cmd += " \"-DPNG_TESTS=0\""
#                     cmd += " \"-DPNG_DEBUG=0\""
#                     cmd += " \"-DPNG_HARDWARE_OPTIMIZATIONS=0\""
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
                                            "#{vendorBuildDir}/bin/Release/libpng*.dll",
                                            "#{vendorBuildDir}/bin/Debug/libpng*.dll",
                                            :basedir => "#{vendorBuildDir}/bin"
                                           )

                    flist << createCopyTasks("#{buildDir}/lib",
                                            "#{vendorBuildDir}/lib/Release/libpng*.lib",
                                            "#{vendorBuildDir}/lib/Debug/libpng*.lib",
                                            :basedir => "#{vendorBuildDir}/lib"
                                           )
                    # necessary - hope it works
                    flist << createCopyTask("#{sourceSubdir}/scripts/pnglibconf.h.prebuilt", "#{buildIncludeDir()}/pnglibconf.h" );

                elsif(targetPlatform =~ /MacOS/)

#                    flist = createCopyTasks("#{nativeLibDir}",
#                                            "#{vendorBuildDir}/libpng/libpng#{cfg.dllExt}",
#                                            :basedir => "#{vendorBuildDir}/libpng"
#                                           )
#                    flist << createCopyTask("#{sourceSubdir}/scripts/pnglibconf.h.prebuilt", "#{buildIncludeDir()}/pnglibconf.h" );
                end

                task pubTargs.addDependencies(flist); # add dependencies to :publicTargets
            end

            explibs = nil
            if(targetPlatform =~ /Windows/)

                ifiles = addPublicIncludes("#{libSource}/png*.h",
                                            :destdir=> "" );

                pubTargs.addDependencies(ifiles);
                explibs = "#{nativeLibDir}/libpng16d#{cfg.libExt}";
            elsif(targetPlatform =~ /MacOS/)
                explibs = "/opt/homebrew/lib/libpng.dylib";
            end
            cfg.addExportedLibs(explibs);
        end

        export task :vendorLibs => [ :buildVendorLibs, :includes, :publicTargets ] do
        end
    end

end

