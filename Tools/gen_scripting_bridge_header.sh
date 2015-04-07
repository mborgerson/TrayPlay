#!/usr/bin/env sh
pushd TrayPlay
sdef /Applications/Spotify.app | sdp -fh --basename Spotify
sdef /Applications/iTunes.app | sdp -fh --basename iTunes
popd