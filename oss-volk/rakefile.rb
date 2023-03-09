myDir = File.expand_path(File.dirname(__FILE__));
require "#{myDir}/../build-options.rb"
require "rakish/GitModule"

depends=[
]

Rakish.Project(
    :includes=>[Rakish::CppProjectModule, Rakish::GitModule ],
	:name 		 => "oss-volk",
	:dependsUpon => [ depends ]
) do

	libSource = "#{projectDir}/volk";

    setSourceSubdir(libSource);

	file libSource do |t|
        git.clone( "https://github.com/zeux/volk.git", t.name );
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
        elsif(targetPlatform =~ /MacOS/)
        end

        task :buildVendorLibs => [sourceSubdir] do |t|
            FileUtils.mkdir_p(vendorBuildDir);  # make sure it is there
            FileUtils::cd(vendorBuildDir) do

                cmd = nil;

                if(targetPlatform =~ /Windows/ )
                    cmd=" echo \"build not implemented for Windows\""
                elsif(targetPlatform =~ /MacOS/)
                    cmd = "python3 generate.py"
                end
#                system(cmd);
            end

            FileUtils::cd(projectDir) do
#              cmd = "#{cmakeCommand} --build build --config RELEASE";
#              system(cmd);
#                cmd = "#{cmakeCommand} --build build --config DEBUG";
#                 system(cmd);
#
                # list of files to copy to main build lib and bin areas
                flist = nil;
                if(targetPlatform =~ /Windows/ )
                    flist = [];
                elsif(targetPlatform =~ /MacOS/)
                    frlist = [];
 #                   flist = createCopyTasks("#{nativeLibDir}",
 #                                           "#{vendorBuildDir}/lib/libglfw*#{cfg.dllExt}",
 #                                           :basedir => "#{vendorBuildDir}/lib"
 #                                          )
                end

                task pubTargs.addDependencies(flist); # add dependencies to :publicTargets
            end

#            ifiles = addPublicIncludes("#{libSource}/include/GLFW/*.h",
#                                       :destdir=> "GLFW" );

#            pubTargs.addDependencies(ifiles);

#             cfg.addExportedLibs(
#                 "#{nativeLibDir}/libglfw#{cfg.dllExt}"
#             );

        end

        export task :vendorLibs => [ :buildVendorLibs, :includes, :publicTargets ] do
        end
    end

end

