TrayPlay
========

An app for OS X that lives in your menu bar and lets you easily control iTunes or Spotify, without interrupting your workflow.

![demo](https://github.com/mborgerson/TrayPlay/raw/master/demo.gif)

How to Build
------------

First, you'll need Xcode. You can download this at the [Mac App Store](https://itunes.apple.com/us/app/xcode/id497799835?mt=12).

Now, use [Git](http://git-scm.com/) to clone the repository and clone the submodules.

    git clone https://github.com/mborgerson/TrayPlay.git
    cd TrayPlay
    git submodule init
    git submodule update

Finally, open up the TrayPlay Xcode project. Set the "Scheme" to build the TrayPlay target for "My Mac". Then Product > Run (or the shortcut ⌘R).