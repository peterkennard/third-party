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
	    # git.clone("https://github.com/glennrp/libpng.git", t.name );
        git.clone('https://github.com/emscripten-ports/libpng.git', t.name );
	    git.checkout("libpng16", :dir=>libSource );
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

        task :buildVendorLibs => [sourceSubdir] do |t|
            FileUtils.mkdir_p(vendorBuildDir);  # make sure it is there
            FileUtils::cd(vendorBuildDir) do

                cmd = nil;

                if(targetPlatform =~ /Windows/ )

                    cmd = "#{cmakeCommand} -G \"#{cMakeGenerator}\" -B \"#{vendorBuildDir}\""
                    cmd += " \"-DBUILD_SHARED_LIBS=1\""
                    cmd += " \"-DZLIB_LIBRARY=#{buildDir}/lib/Debug/zlib.lib\""
                    cmd += " \"-DZLIB_INCLUDE_DIR=#{buildDir}/include\""

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
                flist = [];

                if(targetPlatform =~ /Windows/ )

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

                elsif(targetPlatform =~ /MacOS/)
if false
                    flist = createCopyTasks("#{nativeLibDir}",
                                            "#{vendorBuildDir}/lib/libglfw*#{cfg.dllExt}",
                                            :basedir => "#{vendorBuildDir}/lib/Debug"
                                           )
end
                end

                task pubTargs.addDependencies(flist); # add dependencies to :publicTargets
            end

            ifiles = addPublicIncludes("#{libSource}/png*.h",
                                        :destdir=> "" );

            pubTargs.addDependencies(ifiles);

            explibs = nil
            if(targetPlatform =~ /Windows/ )
                 explibs = "#{nativeLibDir}/libpng16d#{cfg.libExt}";
            elsif(targetPlatform =~ /MacOS/)
#                 explibs = "#{nativeLibDir}/libglfw#{cfg.dllExt}";
            end
            cfg.addExportedLibs(explibs);
        end

        export task :vendorLibs => [ :buildVendorLibs, :includes, :publicTargets ] do
        end
    end

end

