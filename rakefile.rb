myDir = File.dirname(__FILE__);
require "#{myDir}/../build-options.rb"


module Rakish

	cfg = BuildConfig("root");

	dependsList = [
	#	'./zlib',
		'./oss-glm',
		'./oss-volk',
		'./oss-glfw',
	#	'./freetype'
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