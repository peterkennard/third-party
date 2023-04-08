myDir = File.expand_path(File.dirname(__FILE__));
require "#{myDir}/../build-options.rb"
require "rakish/GitModule"

depends=[
]

Rakish.Project(
    :includes=>[Rakish::CppProjectModule, Rakish::GitModule ],
	:name 		=> "vk-memory-allocator",
	:dependsUpon => [ depends ]
) do

    setSourceSubdir("#{projectDir}/vk-allocator");

	file sourceSubdir do |t|
		git.clone('https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator.git', t.name );
	end

    pubIncs = task :publicIncludes;

    task :includeDependencies do
        ifiles = addPublicIncludes("#{sourceSubdir}/include/*.h");
        pubIncs.addDependencies(ifiles)
    end

    export task :includes => [ :includeDependencies, pubIncs ];
    export task :vendorLibs => [ sourceSubdir, :includes ];
    export task :genProject => :vendorLibs;

    export task :cleanAll => sourceSubdir do |t|
        FileUtils.cd sourceSubdir do
            system('git reset --hard');  # Maybe delete and re-download - though a bit slow
        end
    end

end

