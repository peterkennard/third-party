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

    dependsList << './oss-glfw';

	if(cfg.targetPlatform =~ /MacOS/ )
        dependsList << './molten-vk';
	end

	Rakish.Project(:dependsUpon=>dependsList) do
	end

end