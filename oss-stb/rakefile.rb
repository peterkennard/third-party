myDir = File.expand_path(File.dirname(__FILE__));
require "#{myDir}/../build-options.rb"
require "rakish/GitModule"

depends=[
]

Rakish.Project(
    :includes=>[Rakish::CppProjectModule, Rakish::GitModule ],
	:name 		=> "oss-stb",
	:dependsUpon => [ depends ]
) do

    setSourceSubdir("#{projectDir}/stb");

	file sourceSubdir do |t|
		git.clone('https://github.com/nothings/stb.git', t.name );
	end

    pubIncs = task :publicIncludes;
    task :includeDependencies => sourceSubdir do
        pubIncs.addDependencies(addPublicIncludes("#{sourceSubdir}/*.h"))
    end

    # note when dependencies are added to the end of the list they happen AFTER the prior task
    # this is to ensure the sourceSubdir is downloaded first before theincludeDependencies are created.
    # and it is done before the task :includes is execured.
    export task :vendorLibs => [ sourceSubdir, :includeDependencies, :publicIncludes ] do
    end

    export task :genProject => :vendorLibs

    export task :cleanAll => sourceSubdir do |t|
        FileUtils.cd sourceSubdir do
            system('git reset --hard');  # Maybe delete and re-download - though a bit slow
        end
    end

end

