#swift-libimobiledevice
swift-libimobiledevice is a proof-of-concept of a Swift project embedding libimobiledevice, so the app can be run even if libimobiledevice isn't installed.

## Default project

The default project is a simple CLI that will display the amount of iDevices connected to the computer, and their names.

It has been built with the version 1.0.6 of libimobiledevice.


## Embedding libimobiledevice into your project

Since libimobiledevice is a C library, there is some work to do for it to work with Swift.

To embed libimobiledevice into your own app/project, you will have to install it (you could uninstall it later). To do so, follow the instructions here: [https://gist.github.com/soheilbm/32d67c3aaad30cf57300d0ad4fd4775c](https://gist.github.com/soheilbm/32d67c3aaad30cf57300d0ad4fd4775c)

### Import libraries in the project

First, we need to add the libimobiledevice library and its dependencies to Xcode.
Basically, there are 5 libraries to add:

 * libimobiledevice
 * libusbmuxd
 * libplist
 * libssl
 * libcrypto

To do so, follow those steps:

1. Open your project in Xcode
2. Create a new group on the top hiearchical level named "libimobiledevice"
3. Open the Finder, and go to the folder "/usr/local/opt/openssl/lib"
4. Find the "libcrypto.(version).dylib", and drag it to your Xcode project, in the recently created "libimobiledevice" group.
5. When you drop them, a sheet pops up. Ensure the "Copy items if needed" checkbox is ticked, and your target is selected. Press "Finish".
6. Repeat step 4 with the following files:
 * /usr/local/opt/openssl/lib/libssl.(version).dylib
 * /usr/local/opt/libimobiledevice/lib/libimobiledevice-(version).dylib
 * /usr/local/opt/libusbmuxd/lib/libusbmuxd-(version).dylib
 * /usr/local/opt/libplist/lib/libplist-(version).dylib

 Your libimobiledevice should now contains 5 dylib files.
 
### Add headers to the project
 
 Now that the libraries are embedded in your project, you'll need to add the headers so you could use them with Swift.
 
 1. In the libimobiledevice group of your project, add a new group named "includes".
 2. Open the Finder, and go to the folder "/usr/local/opt/libimobiledevice/include"
 3. Drag the folder "libimobiledevice" into the "includes" group of your Xcode project.
 4. When you drop it, a sheet pops up. Ensure the "Copy items if needed" checkbox is ticked, as well as the "Create groups" checkbox. Press "Finish".
 5. Open the Finder, and go to the folder "/usr/local/opt/libplist/plist"
 6. Drag the folder "libplist" into the "includes" group of your Xcode project.
 7. Same as step 4

 8. In the target's Build Phases, add a new Headers Phase. In the Headers Phase section, press the "+" button, and add all the libimobiledevices/includes/plist .h files, as well as the libimobiledevices/includes/libimobiledevice .h files.


 9. If you don't already have a Bridging-Header file for your target, create one
 
 10. Open your Bridging-Header file in Xcode, and add the following to the top:
 

```
#include "libimobiledevice/libimobiledevice.h"
#include "libimobiledevice/lockdown.h"
```


 
### "Patch" dylibs to work as standalone
The dylibs we imported depend on each other. But, the problem is, those dependencies are known as absolute paths. To check dependencies for a dylib, execute this command in the terminal.

`otool -L <dylib path>`

For the libimobiledevice.dylib, it returns something like that:

```
libimobiledevice-1.0.6.dylib:
	/usr/local/opt/libimobiledevice/lib/libimobiledevice-1.0.6.dylib (compatibility version 7.0.0, current version 7.0.0)
	/usr/local/opt/openssl@1.1/lib/libssl.1.1.dylib (compatibility version 1.1.0, current version 1.1.0)
	/usr/local/opt/openssl@1.1/lib/libcrypto.1.1.dylib (compatibility version 1.1.0, current version 1.1.0)
	/usr/local/opt/libusbmuxd/lib/libusbmuxd-2.0.6.dylib (compatibility version 7.0.0, current version 7.0.0)
	/usr/local/opt/libplist/lib/libplist-2.0.3.dylib (compatibility version 7.0.0, current version 7.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1292.0.0)
```
As we can see, the dependencies paths start with "/usr/local/opt" to refear to other dylibs, which is not what we want, since we included all dylibs to the Xcode project.

To fix this, open your Xcode project main folder in the Finder, and copy to it the Python file you can download here(TODO).

Open a terminal, and execute those commands:

```
cd (your project dir path)
python rpathDylibs.py
```

If you have "Permissions denied" errors, re-execute the python command with sudo.

You can now try the otool command again, the paths should now be all relative (starting with @rpath), except for the libSystem.B.dylib file.
For the libimobiledevice.dylib, it should return something like that:

```
libimobiledevice/libimobiledevice-1.0.6.dylib:
	@rpath/libimobiledevice-1.0.6.dylib (compatibility version 7.0.0, current version 7.0.0)
	@rpath/libssl.1.1.dylib (compatibility version 1.1.0, current version 1.1.0)
	@rpath/libcrypto.1.1.dylib (compatibility version 1.1.0, current version 1.1.0)
	@rpath/libusbmuxd-2.0.6.dylib (compatibility version 7.0.0, current version 7.0.0)
	@rpath/libplist-2.0.3.dylib (compatibility version 7.0.0, current version 7.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1292.0.0)
```

### Configure the Xcode project

Open the target's General settings.
In the "Frameworks and Libraries" section, add all the dylibs if they are not already there. Set them as "Embed Without Signing"

Open the target's Build settings

 * Search for "Header Search Paths". Add this line:

 `$(PROJECT_DIR)/libimobiledevice/includes`
 
 * Search for "Library Search Paths". Add this line if not already present:

 `$(PROJECT_DIR)/libimobiledevice`
 
 * Search for "Dynamic Library Install Name". Add this line if not already present:

 `$(DYLIB_INSTALL_NAME_BASE:standardizepath)/$(EXECUTABLE_PATH)`
 
 * Search for "Dynamic Library Install Base". Add this line if not already present:

 `@rpath`
 
 
### Test 
 
 It should now be OK.
 
 Execute the command `brew unlink libimobiledevice` to "uninstall" libimobiledevice without really removing it.
 
 Try running your app. If it runs without error, then everything is ok.
 
 If you want, you can now totally uninstall libimobiledevice, your app should be working anyway.
 
 
## Links
 * Install libimobiledevice on OSX: [https://gist.github.com/soheilbm/32d67c3aaad30cf57300d0ad4fd4775c](https://gist.github.com/soheilbm/32d67c3aaad30cf57300d0ad4fd4775c)
 * libimobiledevice GitHub: [https://github.com/libimobiledevice/libimobiledevice](https://github.com/libimobiledevice/libimobiledevice)
 * libimobiledevice API Documentation: [https://libimobiledevice.org/docs/libimobiledevice/latest/annotatedstructs.html](https://libimobiledevice.org/docs/libimobiledevice/latest/annotatedstructs.html)
 * Getting device list in Swift using libimobiledevice (needs to be updated): [https://gist.github.com/michaelmcguire/25ae4d84d9bb139495cf](https://gist.github.com/michaelmcguire/25ae4d84d9bb139495cf)
 * iMobileDevice (Old framework wrapping libimobiledevice in ObjC): [https://github.com/4eleven7/iMobileDevice](https://github.com/4eleven7/iMobileDevice)