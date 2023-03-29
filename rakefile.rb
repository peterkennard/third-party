myDir = File.dirname(__FILE__);
require "#{myDir}/../build-options.rb"


module Rakish

	cfg = BuildConfig("root");

	dependsList = [
		'./oss-zlib',
		'./oss-libpng',
		'./oss-glm',
		'./oss-volk',
		'./oss-glfw'
		'./vk-spirv-reflect'
	];

	if(cfg.targetPlatform =~ /MacOS/ )

        dependsList << './molten-vk';
        dependsList << './vulkan-sdk-macos';

	elsif(cfg.targetPlatform =~ /Windows/ )

        dependsList << './vulkan-sdk-windows';
		dependsList << './vk-spirv-reflect'
	end


    log.debug("depends #{dependsList}");

	Rakish.Project(:dependsUpon=>dependsList) do
	end

end