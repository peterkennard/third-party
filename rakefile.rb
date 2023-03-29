myDir = File.dirname(__FILE__);
require "#{myDir}/../build-options.rb"


module Rakish

	cfg = BuildConfig("root");

	dependsList = [
		'./oss-zlib',
		'./oss-libpng',
		'./oss-glm',
		'./oss-volk',
		'./vk-spirv-reflect',
		'./oss-glfw'
	];

	if(cfg.targetPlatform =~ /MacOS/ )

        dependsList << './molten-vk';
        dependsList << './vulkan-sdk-macos';

	elsif(cfg.targetPlatform =~ /Windows/ )

        dependsList << './vulkan-sdk-windows';
	end


    log.debug("depends #{dependsList}");

	Rakish.Project(:dependsUpon=>dependsList) do
	end

end