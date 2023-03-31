myDir = File.expand_path(File.dirname(__FILE__));
require "#{myDir}/../build-options.rb"
require "rakish/GitModule"

depends=[
]

Rakish.Project(
    :includes=>[Rakish::CppProjectModule, Rakish::GitModule ],
    :id         => "1AB1C320-9110-4A2A-B191-525213903EA2",
	:name 		=> "oss-glm",
	:dependsUpon => [ depends ]
) do

    setSourceSubdir("#{projectDir}/glm");

	file sourceSubdir do |t|
		git.clone('https://github.com/g-truc/glm.git', t.name );
		# git.checkout("master", :dir=>t.name);
	end

    vendorBuildDir = ensureDirectoryTask("#{projectDir}/build");

    pubTargs = task :publicTargets;

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

    log.debug(" ########################################## #{ifiles}");

    export task :includes => [ sourceSubdir, ifiles ] do
    end

    export task :vendorLibs => [ sourceSubdir, :includes ] do
    end

    export task :cleanAll => sourceSubdir do |t|
        FileUtils.rm_rf("#{buildDir}/include/glm");  # remove recursive
        FileUtils.cd sourceSubdir do
            system('git reset --hard');  # Maybe delete and re-download - though a bit slow
        end
    end

end

