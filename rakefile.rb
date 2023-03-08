myDir = File.dirname(__FILE__);
require "#{myDir}/build-options.rb"


module Rakish

	dependsList = [
	#	'./zlib',
		'./oss-glm',
		'./oss-volk'
	#	'./freetype'
	];

	cfg = BuildConfig("root");

	if(cfg.targetPlatform =~ /MacOS/ )
		dependsList << './oss-glfw';
	end

	Rakish.Project(:dependsUpon=>dependsList) do
	end

end