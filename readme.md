# Overview

Basically, these are scripts I've written over the years to scratch various itches I've had. All parts of all scripts were written by me, unless otherwise stated. I don't really care how you make use of them, but it would be nice if you could give some type of attribution to me and/or my site ([http://dovfrankel.com](http://dovfrankel.com)).

# Installation

All of the scripts are intended to be installed in the `~/Library` directory (copied in there), with the same relative path I use in the repository. That's where they'll get picked up by FastScripts, iTunes, and the various apps they're meant to interact with.

# Libraries

Many scripts use libraries I've written for certain common functions. Those are located in the `Scripts/Libraries` directory. To load them, you'll see code like the following:

    property LibLoader : load script file ((path to scripts folder from user domain as text) & "Libraries:Library Loader.scpt")
    property StringsLib : LibLoader's loadScript("Libraries:Strings.applescript")

The first line creates a reference to the library responsible for loading the other ones. That script has to be a compiled scripts (with the `.scpt` extension), whereas all other scripts are in the plaintext `.applescript` format. I've committed the `Library Loader` script in both formats, so the plain-text version can be searched and diff'ed, but the compiled version can be loaded as a property. Each library script contains a comment at the top of the file, which can be copied and pasted into a script that wishes to refer to it.

Any scripts loaded with `Library Loader` can be compiled or plain-text, but plain-text ones must be encoded as UTF-8, since that's what it is expecting when decoding them.

# Tests

I've got a basic suite of custom-built tests in `Scripts/Libraries/Library Tests.applescript`, which you can run, and observe its log output for failures. I plan to someday move it to [ASUnit](http://nirs.freeshell.org/asunit/) instead.

# Disclaimer

These scripts work for me, and I hope they will either work for you as-is, or at least lead you to a workable solution. Please review the scripts before you attempt to run them. I can't guarantee they don't have weird side effects I haven't encountered yet. If you do find issues, though, please send me a pull request and I'll try to incorporate any fixes you come up with.