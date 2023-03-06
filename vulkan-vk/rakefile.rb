#

myDir = File.expand_path(File.dirname(__FILE__));
require "#{myDir}/../build-options.rb"
require "rakish/GitModule"

depends=[
]

Rakish.Project(
    :includes=>[Rakish::CppProjectModule, Rakish::GitModule ],
    :id          => "",
	:name 		 => "vulkan-vk",
	:dependsUpon => [ depends ]
) do

	libSource = "#{projectDir}/MoltenVK";

    setSourceSubdir(libSource);

	file libSource do |t|
	    git.clone("https://github.com/KhronosGroup/MoltenVK.git", t.name );
	end

    export task :cleanAll => sourceSubdir do |t|
        FileUtils.rm_rf(vendorBuildDir);  # remove recursive
        FileUtils.cd sourceSubdir do
            system('git reset --hard');  # Maybe delete and re-download - though a bit slow
        end
    end

    export task :vendorLibs => [ libSource ] do |t|
    end

end

