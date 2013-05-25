# Overview

Basically, these are scripts I've written over the years to scratch various itches I've had. All parts of all scripts were written by me, unless otherwise stated. I don't really care how you make use of them, but it would be nice if you could give some type of attribution to me and/or my site ([http://dovfrankel.com](http://dovfrankel.com)).

# Installation

All of the scripts are intended to be installed in the `~/Library` directory (copied in there), with the same relative path I use in the repository. That's where they'll get picked up by FastScripts, iTunes, and the various apps they're meant to interact with.

# Libraries

Many scripts use libraries I've written for certain common functions. Those are located in the `Scripts/Libraries` directory. To load them, you'll see code like the following:

    property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
    property StringsLib : LibLoader's loadScript("Libraries:Strings.applescript")

The first line creates a reference to the library responsible for loading the other ones. That script has to be a compiled scripts (with the `.scpt` extension), whereas all other scripts are in the plaintext `.applescript` format. I've committed the `Library Loader` script in both formats, so the plain-text version can be searched and diff'ed, but the compiled version can be loaded as a property. Each library script contains a comment at the top of the file, which can be copied and pasted into a script that wishes to refer to it.

Any scripts loaded with `Library Loader` can be compiled or plain-text, and plain-text files can be encoded in Mac format (which AppleScript Editor uses) or UTF-8, but only in those two.

# Tests

I've got a basic suite of custom-built tests in `Scripts/Libraries/Library Tests.applescript`, which you can run, and observe its log output for failures. I plan to someday move it to [ASUnit](http://nirs.freeshell.org/asunit/) instead ([Issue #1](https://github.com/abbeycode/AppleScripts/issues/1)).

# iTunes Script Menu

Some iTunes scripts don't work from the Script Menu at all, such as [Re-import Lossless Tracks.applescript](https://github.com/abbeycode/AppleScripts/blob/master/iTunes/Scripts/Re-import%20Lossless%20Tracks.applescript), and others, such as [Upgrade Tracks.applescript](https://github.com/abbeycode/AppleScripts/blob/master/iTunes/Scripts/Upgrade%20Tracks.applescript) need to be compiled into `.scpt` format to work.

# Automator Service Scripts

Some scripts are intended to be run as Automator "Run ApplesScript" actions within a [service](http://www.macosxautomation.com/services/), though they don't provide much utility as a standalone script. These are in the [Services](https://github.com/abbeycode/AppleScripts/blob/master/Services) folder. You can use these in your own services by using the following text in the Automator workflow (as I described in [a blog post](http://dovfrankel.com/post/49510291962/running-applescripts-from-automator)):

    on run {input, parameters}
    
        run script file "<git checkout path>:AppleScripts:Services:Encode With HandBrake.applescript" with parameters {input, parameters}
    
    end run

# Disclaimer

These scripts work for me, and I hope they will either work for you as-is, or at least lead you to a workable solution. Please review the scripts before you attempt to run them. I can't guarantee they don't have weird side effects I haven't encountered yet. If you do find issues, though, please send me a pull request and I'll try to incorporate any fixes you come up with.