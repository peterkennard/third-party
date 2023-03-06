myDir = File.dirname(__FILE__);
require "#{myDir}/build-options.rb"


module Rakish

	dependsList = [
	#	'./zlib',
		'./oss-glm',
	#	'./freetype'
	];

	cfg = BuildConfig("root");

	if(cfg.targetPlatform =~ /MacOS/ )
		dependsList << './oss-glfw';
	end

	#
	# TODO: Add library dependencies ... this thing tries to add google-angle as a library
	# But there is no library called that.  We need generally speaking:
	# 
	# Presumably we need all libangle* libraries
	#
	# In addition, the OS has to find a bunch of other libraries, see below:
	#
	# if(ANGLE_ENABLE_GL)
	# 	if(APPLE)
	# 		find_library(COCOA_LIB Cocoa)
	# 		find_library(IOSURFACE_LIB IOSurface)
	# 		find_library(QUARTZCORE_LIB QuartzCore)
	# 		find_library(CORE_FOUNDATION_LIB CoreFoundation)
	# 		find_library(CORE_GRAPHICS_LIB CoreGraphics)
	# 		find_library(IOKIT_LIB IOKit)
	# 		list(APPEND ANGLE_OS_LIBS ${COCOA_LIB} ${IOSURFACE_LIB} ${QUARTZCORE_LIB})
	# 		list(APPEND ANGLE_OS_LIBS ${CORE_FOUNDATION_LIB} ${CORE_GRAPHICS_LIB})
	# 		list(APPEND ANGLE_OS_LIBS ${IOKIT_LIB} ${OPENGL_LIB})
	# 		if(ANGLE_LINK_GLX)
	# 		find_library(OPENGL_LIB OpenGL)
	# 		list(APPEND ANGLE_OS_LIBS ${OPENGL_LIB})
	# 		endif()
	# 		add_definitions(-DANGLE_ENABLE_OPENGL)
	# 	elseif(UNIX)
	# 		find_library(X11_LIB X11)
	# 		find_library(XINPUT_LIB Xi)
	# 		find_library(XEXT_LIB Xext)
	# 		find_library(JSONCPP_LIB jsoncpp)
	# 		find_library(PCI_LIB pci)
	# 		find_package(Threads REQUIRED)
	# 		include_directories(/usr/include/jsoncpp)
	# 		list(APPEND ANGLE_OS_LIBS ${X11_LIB} ${XINPUT_LIB} ${XEXT_LIB})
	# 		list(APPEND ANGLE_OS_LIBS ${JSONCPP_LIBRARY} ${PCI_LIB})
	# 		list(APPEND ANGLE_OS_LIBS Threads::Threads dl)
	# 		if(ANGLE_LINK_GLX)
	# 		find_library(OPENGL_LIB GL)
	# 		list(APPEND ANGLE_OS_LIBS ${OPENGL_LIB})
	# 		endif()
	# 		add_definitions(-DANGLE_ENABLE_OPENGL -DANGLE_USE_X11)
	# 	elseif(WIN32)
	# 		find_library(OPENGL_LIB OpenGL32)
	# 		add_definitions(-DANGLE_ENABLE_OPENGL)
	# 		list(APPEND ANGLE_OS_LIBS ${OPENGL_LIB})
	# 	endif()
	# 	if(ANGLE_ENABLE_OPENGL_NULL)
	# 		add_definitions(-DANGLE_ENABLE_OPENGL_NULL)
	# 	endif()
	# endif()

	Rakish.Project(:dependsUpon=>dependsList) do
	end

end