myDir = File.dirname(__FILE__);
require "#{myDir}/../build-options.rb"


module Rakish

	cfg = BuildConfig("root");

	dependsList = [
	#	'./zlib',
		'./oss-glm',
		'./oss-volk',
	#	'./freetype'
	];


	if(cfg.targetPlatform =~ /MacOS/ )
		dependsList << './oss-glfw';
        dependsList << './molten-vk';
	end

	Rakish.Project(:dependsUpon=>dependsList) do
	end

end