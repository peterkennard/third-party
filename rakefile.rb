myDir = File.dirname(__FILE__);
require "#{myDir}/../build-options.rb"


module Rakish

dependsList=[]
unless (ARGV.length > 0 && (ARGV[0] =~ /setup/))

	cfg = BuildConfig("root");
	dependsList = [
		'./oss-zlib',
		'./oss-libpng',
		'./oss-glm',
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
end

	Rakish.Project(:dependsUpon=>dependsList) do
	end

end