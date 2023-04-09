myDir = File.dirname(__FILE__);
require "#{myDir}/../build-options.rb"


module Rakish

    dependsList=[]

    unless inSetupTask()

        cfg = BuildConfig("root");
        dependsList = [
            './oss-zlib',
            './oss-libpng',
            './oss-glm',
            './oss-glfw'
        ];

        if(cfg.targetPlatform =~ /MacOS/ )
            dependsList << './molten-vk';
        elsif(cfg.targetPlatform =~ /Windows/ )
        end


        log.debug("depends #{dependsList}");
    end

	Rakish.Project(:dependsUpon=>dependsList) do
	    export task :setup do 
	    end
	end

end