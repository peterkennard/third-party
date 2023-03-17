myDir = File.expand_path(File.dirname(__FILE__));
require "#{myDir}/../build-options.rb"
require "rakish/GitModule"

depends=[
]

Rakish.Project(
    :includes=>[Rakish::CppProjectModule, Rakish::GitModule ],
	:name 		 => "vulkan-sdk",
	:dependsUpon => [ depends ]
) do

    vendorBuildDir = ensureDirectoryTask("#{projectDir}/build");

#    task :includes => libSource;

#    export task :cleanAll => sourceSubdir do |t|
#        FileUtils.rm_rf(vendorBuildDir);  # remove recursive
#        FileUtils.cd sourceSubdir do
#            system('git reset --hard');  # Maybe delete and re-download - though a bit slow
#        end
#    end

    setupCppConfig :targetType=>'DLL' do |cfg|
        cfg.targetName = 'vulkan-sdk';

        pubTargs = task :publicTargets;

        cfg.cmakeExport = true;

        task :buildVendorLibs => [sourceSubdir] do |t|
#            FileUtils::cd(projectDir) do
#                flist = [];
#                if(targetPlatform =~ /Windows/ )
#                elsif(targetPlatform =~ /MacOS/)
#                end
#                task pubTargs.addDependencies(flist);
#            end

#            ifiles = addPublicIncludes("#{libSource}/include/GLFW/*.h",
#                                       :destdir=> "GLFW" );

#            pubTargs.addDependencies(ifiles);

if(false)
            explibs = nil;
            if(targetPlatform =~ /Windows/ )
                explibs = "#{vendorBuildDir}/lib/Debug/glfw3dll.lib";
            elsif(targetPlatform =~ /MacOS/)
                 explibs = "#{nativeLibDir}/libglfw#{cfg.dllExt}";
            end
            cfg.addExportedLibs(explibs);
end
        end

        export task :vendorLibs => [ :buildVendorLibs, :includes, :publicTargets ] do
        end
    end

end

