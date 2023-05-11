
myDir = File.expand_path(File.dirname(__FILE__));
require "#{myDir}/../build-options.rb"
require "rakish/GitModule"

depends=[
]

Rakish.Project(
    :includes=>[Rakish::CppProjectModule, Rakish::GitModule ],
    :id          => "",
	:name 		 => "google-depot-tools",
	:dependsUpon => [ depends ]
) do

	libSource = "#{projectDir}/depot_tools";

    setSourceSubdir(libSource);

    # readme on building
    # https://dawn.googlesource.com/dawn/+/refs/heads/chromium-gpu-experimental/README.md
    
	file libSource do |t|
#        if(targetPlatform =~ /Windows/ )
#            system("curl \"https://storage.googleapis.com/chrome-infra/depot_tools.zip\" -o dptools.zip");
#            system("unzip -q dptools.zip -d #{t.name}");
#        elsif(targetPlatform =~ /MacOS/)
	        git.clone("https://chromium.googlesource.com/chromium/tools/depot_tools.git", t.name );
#        end
	end

    export task :vendorLibs => [ libSource ] do |t|
    end

end

