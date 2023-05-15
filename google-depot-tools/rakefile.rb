
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

        opath = ENV['PATH'];

        if(targetPlatform =~ /Windows/ )

	        #  git.clone("https://chromium.googlesource.com/chromium/tools/depot_tools.git", t.name );

            system("cp -a #{projectDir}/dptools.orig #{t.name}");

            ENV['PATH'] = "#{t.name}#{pathSeparator}#{opath}";
            ENV['DEPOT_TOOLS_UPDATE']="1";

            system("bash -c gclient");

	        FileUtils.cd(t.name) do
			STDOUT.flush;
                system("bash -c \"./python.bat -m pip install pywin32\"");
            end

#            system("curl \"https://storage.googleapis.com/chrome-infra/depot_tools.zip\" -o dptools.zip");
#            system("unzip -q dptools.zip -d #{t.name}");

        elsif(targetPlatform =~ /MacOS/)

	        git.clone("https://chromium.googlesource.com/chromium/tools/depot_tools.git", t.name );
            ENV['PATH'] = "#{t.name}#{pathSeparator}#{opath}";

        end

        ENV['PATH'] = opath;

	end

    export task :vendorLibs => [ libSource ] do |t|
    end

end

