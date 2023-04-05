myDir = File.expand_path(File.dirname(__FILE__));
require "#{myDir}/../build-options.rb"
require "rakish/GitModule"

depends=[
]

Rakish.Project(
    :includes=>[Rakish::CppProjectModule, Rakish::GitModule ],
	:name 		=> "oss-glm",
	:dependsUpon => [ depends ]
) do

    setSourceSubdir("#{projectDir}/glm");

    pubTargs = task :publicTargets;


	file sourceSubdir do |t|
		git.clone('https://github.com/g-truc/glm.git', t.name );
	end

    iTask = task :includes => [ sourceSubdir ] do
    end

    task :includeDependencies do

        glmDirs = [
            '.',
            'detail',
            'ext',
            'gtc',
            'gtx',
            'gtx',
            'simd'
        ];

        ifiles = [];

        glmDirs.each do |dir|
            ifiles << createCopyTasks("#{buildDir}/include/glm/#{dir}",
                                                "#{sourceSubdir}/glm/#{dir}/*.*",
                                                :baseDir => sourceSubdir                                            );
        end
        iTask.addDependencies(ifiles)

    end

    # note when dependencies are added to the end of the list they happen AFTER the prior task
    # this is to ensure the sourceSubdir is downloaded first before the dependencies are created.
    export task :vendorLibs => [ sourceSubdir, :includeDependencies, :includes ] do
    end

    export task :genProject => :vendorLibs

    export task :cleanAll => sourceSubdir do |t|
        FileUtils.rm_rf("#{buildDir}/include/glm");  # remove recursive
        FileUtils.cd sourceSubdir do
            system('git reset --hard');  # Maybe delete and re-download - though a bit slow
        end
    end

end

