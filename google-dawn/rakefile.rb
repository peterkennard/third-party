
myDir = File.expand_path(File.dirname(__FILE__));
require "#{myDir}/../build-options.rb"
require "rakish/GitModule"

depends=[
    "../google-depot-tools"
]

Rakish.Project(
    :includes=>[Rakish::CppProjectModule, Rakish::GitModule ],
    :id          => "",
	:name 		 => "google-dawn",
	:dependsUpon => [ depends ]
) do

	libSource = "#{projectDir}/dawn";

    setSourceSubdir(libSource);

    # readme on building
    # https://dawn.googlesource.com/dawn/+/refs/heads/chromium-gpu-experimental/README.md

	file libSource do |t|
	    git.clone("https://dawn.googlesource.com/dawn", t.name );
	    git.checkout("chromium/4473);
	end

if(false)
    export task :cleanAll => sourceSubdir do |t|
        FileUtils.rm_rf(vendorBuildDir);  # remove recursive
        FileUtils.cd sourceSubdir do
            system('git reset --hard');  # Maybe delete and re-download - though a bit slow
        end
    end
end
    export task :vendorLibs => [ libSource ] do |t|
    end

end

