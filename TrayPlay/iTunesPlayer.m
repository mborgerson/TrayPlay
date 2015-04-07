// Copyright (C) 2015  Matt Borgerson
// 
// This file is part of TrayPlay.
// 
// TrayPlay is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// TrayPlay is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with TrayPlay.  If not, see <http://www.gnu.org/licenses/>.

#import "iTunesPlayer.h"
#import "iTunes.h"

@interface iTunesPlayer ()

@property (strong) iTunesApplication *itunes;
@property NSInteger lastUpdateTrack;
@property (strong) NSTimer *timer;

-(void)update;

@end

@implementation iTunesPlayer

- (id) init
{
    self = [super init];
    if (self) {
        self.lastUpdateTrack = -1;
        self.itunes = [SBApplication applicationWithBundleIdentifier:@"com.Apple.iTunes"];
        
        // Using a timer here because, sadly, it's the only way to get updates from
        // iTunes using the scripting bridge...
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self
                                                    selector:@selector(update)
                                                    userInfo:nil
                                                     repeats:YES];
        
        return self;
    }
    return self;
}

- (void) next
{
    [self.itunes nextTrack];
    [self update];
}

- (void) previous
{
    [self.itunes previousTrack];
    [self update];
}

- (void) pause
{
    [self.itunes pause];
    [self update];
}

- (void) play
{
    [self.itunes playOnce:NO];
    [self update];
}

- (void)update
{
    switch (self.itunes.playerState)
    {
        case iTunesEPlSStopped:
            self.state = PlayerStateStopped;
            break;
        case iTunesEPlSPaused:
            self.state = PlayerStatePaused;
            break;
        case iTunesEPlSPlaying:
            self.state = PlayerStatePlaying;
            break;
        default:
            self.state = PlayerStateStopped;
            break;
    }

    if (self.itunes.currentTrack.id == self.lastUpdateTrack)
    {
        // Same track. Do nothing.
        return;
    }
    
    self.lastUpdateTrack = self.itunes.currentTrack.id;
    
    Track *track = nil;
    if (self.itunes.currentTrack != nil)
    {
        NSImage *artwork = nil;
        if ([self.itunes.currentTrack.artworks count] > 0)
        {
            iTunesArtwork *itart = [self.itunes.currentTrack.artworks objectAtIndex:0];
            artwork = [[NSImage alloc] initWithData:itart.rawData];
        }
        
        track = [[Track alloc] initWithArtist:self.itunes.currentTrack.artist
                                        track:self.itunes.currentTrack.name
                                      artwork:artwork];
    }
    self.currentTrack = track;
}

- (void) openPlayerApplication
{
    [[NSWorkspace sharedWorkspace] openFile:nil withApplication:@"itunes"];
}

-(void) prepareForDealloc
{
    [self.timer invalidate];
}

@end
