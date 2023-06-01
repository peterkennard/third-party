myDir = File.expand_path(File.dirname(__FILE__));
require "#{myDir}/../build-options.rb"
require "rakish/GitModule"

depends=[
    "#{myDir}/../oss-zlib",
    "#{myDir}/../oss-libpng",
]

Rakish.Project(
    :includes=>[Rakish::CppProjectModule, Rakish::GitModule ],
    :id          => "A1348BD5-3D94-4BD2-80D4-D52F7C124C59",
	:name 		 => "oss-freetype",
	:dependsUpon => [ depends ]
) do

	libSource = "#{projectDir}/freetype2";

    setSourceSubdir(libSource);

	file libSource do |t|
	    git.clone("https://git.savannah.gnu.org/git/freetype/freetype2.git", t.name );
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
        cfg.targetName = 'freetype';

        pubTargs = task :publicTargets;

        task :buildVendorLibs => [sourceSubdir] do |t|

            FileUtils::mkdir_p(vendorBuildDir);  # make sure it is there
            FileUtils::cd(vendorBuildDir) do

                if(targetPlatform =~ /Windows/ )
                    cmd = "#{cmakeCommand} -G \"#{cMakeGenerator}\""
                    cmd += " \"-DBUILD_SHARED_LIBS=FALSE\""  # shared lib not supported ?
                    cmd += " \"-DSKIP_INSTALL_ALL=TRUE\""

                    cmd += " \"-DZLIB_LIBRARY=#{buildDir}/lib/Debug/zlibd#{cfg.libExt}\""
                    cmd += " \"-DZLIB_INCLUDE_DIR=#{buildIncludeDir}\""

                    cmd += " \"-DPNG_LIBRARY=#{buildDir}/lib/Debug/libpng16d#{cfg.libExt}\""
                    cmd += " \"-DPNG_PNG_INCLUDE_DIR=#{buildIncludeDir}\""

                    cmd += " \"-DFT_DISABLE_HARFBUZZ=TRUE\""
                    cmd += " \"-DFT_DISABLE_BROTLI=TRUE\""
                    cmd += " ..";
                elsif(targetPlatform =~ /MacOS/)
                    cmd = "#{cmakeCommand} -G \"Unix Makefiles\""
                    cmd += " \"-DBUILD_SHARED_LIBS=TRUE\""  # shared lib not supported ?
                    cmd += " \"-DSKIP_INSTALL_ALL=TRUE\""

                    cmd += " \"-DZLIB_LIBRARY=#{buildDir}/lib/libz#{cfg.dllExt}\""
                    cmd += " \"-DZLIB_INCLUDE_DIR=#{buildIncludeDir}\""

                    cmd += " \"-DPNG_LIBRARY=#{buildDir}/lib/libpng16#{cfg.dllExt}\""
                    cmd += " \"-DPNG_PNG_INCLUDE_DIR=#{buildIncludeDir}\""

                    cmd += " \"-DFT_DISABLE_HARFBUZZ=TRUE\""
                    cmd += " \"-DFT_DISABLE_BROTLI=TRUE\""
                    cmd += " ..";
                end

                system(cmd);

            end

            FileUtils::cd(projectDir) do
                cmd = "#{cmakeCommand} --build build --config RELEASE";
                system(cmd);
                cmd = "#{cmakeCommand} --build build --config DEBUG";
                system(cmd);

                flist = nil;

                if(targetPlatform =~ /Windows/ )
                    # list of files to copy to main build lib and bin areas
                    flist = createCopyTasks("#{buildDir}",
                                            "#{vendorBuildDir}/bin/Debug/freetype*.*",
                                            "#{vendorBuildDir}/bin/Release/freetype*.*",
                                            "#{vendorBuildDir}/lib/Debug/freetype*.*",
                                            "#{vendorBuildDir}/lib/Release/freetype*.*",
                                            :basedir => "#{vendorBuildDir}"
                                            )
                elsif(targetPlatform =~ /MacOS/)
                    flist = createCopyTasks("#{buildDir}",
                                            "#{vendorBuildDir}/lib/libfreetype*#{cfg.dllExt}",
                                            :basedir => "#{vendorBuildDir}"
                                            )
                end

                pubTargs.addDependencies(flist); # add dependencies to :publicTargets
            end
            ifiles = addPublicIncludes(
                 "#{libSource}/include/freetype/*.h",
                :destdir => "freetype"
            );
            ifiles << addPublicIncludes(
                 "#{vendorBuildDir}/freetype2/include/freetype/config/*.h",
                :destdir => "freetype/config"
            );
            pubTargs.addDependencies(ifiles);
        end

        export task :vendorLibs => [ :buildVendorLibs, :includes, :publicTargets ] do |t|
        end

    end

end

