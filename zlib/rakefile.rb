myDir = File.expand_path(File.dirname(__FILE__));
require "#{myDir}/../build-options.rb"
require "rakish/GitModule"

depends=[
]


Rakish.Project(
    :includes=>[Rakish::CppProjectModule, Rakish::GitModule ],
    :id         => "163EC60B-474F-4AF0-9347-00B476171A9C",
	:name 		=> "oss-zlib",
	:dependsUpon => [ depends ]
) do

    setSourceSubdir("#{projectDir}/zlib");

	file sourceSubdir do |t|
		# git.clone('https://github.com/emscripten-ports/zlib.git', t.name );
		git.clone("git.livingwork.com:/home/didi/oss-vendor/zlib.git", t.name );
		git.checkout("master", :dir=>t.name);
	end

    vendorBuildDir = ensureDirectoryTask("#{projectDir}/build");

    pubTargs = task :publicTargets;

    setupCppConfig :targetType=>'DLL' do |cfg|

       cfg.targetName = 'zlib';
       cfg.cmakeExport = true;

       if(targetPlatform =~ /Windows/)
           cfg.addThirdPartyLibs(
               "#{vendorBuildDir}/lib/Release/zlib#{cfg.dllExt()}",
               "#{vendorBuildDir}/bin/Release/zlib#{cfg.dllExt()}"
           );
       elsif(targetPlatform =~ /MacOS/)
           cfg.addThirdPartyLibs(
               "#{vendorBuildDir}/lib/libz#{cfg.dllExt()}",
               "#{vendorBuildDir}/lib/libz#{cfg.libExt()}"
           );
       end

       task :buildVendorLibs => [sourceSubdir] do |t|
            FileUtils.mkdir_p(vendorBuildDir);  # make sure it is there
            FileUtils::cd(vendorBuildDir) do
                cmd = "#{cmakeCommand} -G \"#{cMakeGenerator}\""
                cmd += " ..";
                system(cmd);
            end

            FileUtils::cd(projectDir) do
                cmd = "#{cmakeCommand} --build build --config RELEASE";
                system(cmd);
                cmd = "#{cmakeCommand} --build build --config DEBUG";
                system(cmd);

                # list of files to copy to main build lib and bin areas

                flist = [];
                if(targetPlatform =~ /Windows/)
#                    log.debug("################## \n #{flist} \n\n #########")

                    flist = createCopyTasks("#{buildDir}",
                                            "#{vendorBuildDir}/bin/Debug/zlib*.*",
                                            "#{vendorBuildDir}/bin/Release/zlib*.*",
                                            "#{vendorBuildDir}/lib/Debug/zlib*.*",
                                            "#{vendorBuildDir}/lib/Release/zlib*.*",
                                            :basedir => "#{vendorBuildDir}"
                                            )
                elsif(targetPlatform =~ /MacOS/)
                    flist = createCopyTasks("#{buildDir}",
                                            "#{vendorBuildDir}/lib/libz*#{cfg.dllExt}",
                                            "#{vendorBuildDir}/lib/libz*#{cfg.libExt}",
                                            :basedir => "#{vendorBuildDir}"
                                            )
                end

                task pubTargs.addDependencies(flist); # add dependencies to :publicTargets
            end

            incfiles = addPublicIncludes(
                "#{vendorBuildDir}/zlib/*.h",
                "#{sourceSubdir}/zlib.h"
            );
            pubTargs.addDependencies(incfiles);
        end
    end

    export task :vendorLibs => [ :buildVendorLibs, :includes, :publicTargets ] do
    end

    export task :cleanAll => sourceSubdir do |t|
        FileUtils.rm_rf(vendorBuildDir);  # remove recursive
        FileUtils.cd sourceSubdir do
            system('git reset --hard');  # Maybe delete and re-download - though a bit slow
        end
    end

if(false) ##########################################################
    export task :includes => sourceSubdir;

    file "#{sourceSubdir}/zlib.h" => sourceSubdir;


    task :cmakeGen => sourceSubdir do |t|

        FileUtils.cd libSource do
            if(false && ENV['EMSDK'])
                system("emcmake cmake . \"-B#{t.name}\" -DCMAKE_BUILD_TYPE=Release");
                # system("cmake . \"-B#{t.name}\" -DCMAKE_BUILD_TYPE=Release");
            elsif(Rakish::HostIsWindows_)
                system("cmake . \"-B#{t.name}\""); # -DCMAKE_BUILD_TYPE=Release");
            end
        end
    end

    export task :cleanAll => sourceSubdir do |t|
        FileUtils::cd sourceSubdir do
            system('git pull');
        end
    end

    task :configure => genconfig;

    sources = [
        'adler32.c',
        'compress.c',
        'crc32.c',
        'deflate.c',
        'gzclose.c',
        'gzlib.c',
        'gzread.c',
        'gzwrite.c',
        'inflate.c',
        'infback.c',
        'inftrees.c',
        'inffast.c',
        'trees.c',
        'uncompr.c',
        'zutil.c',
    ].map { |s| "#{sourceSubdir}/#{s}"; }

    addSourceFiles(sources);

    addPublicIncludes(
        "#{genconfig}/zconf.h",
        "#{sourceSubdir}/zlib.h"
    );
end # false ######################################################

end

