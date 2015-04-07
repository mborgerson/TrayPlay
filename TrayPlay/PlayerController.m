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

#import "PlayerController.h"

@interface PlayerController ()
@property (strong) NSImage *playImage;
@property (strong) NSImage *pauseImage;
@end

@implementation PlayerController

- (void)awakeFromNib {
    self.player           = [[Player alloc] init];
    self.pauseImage       = [NSImage imageNamed:@"pause"];
    self.playImage        = [NSImage imageNamed:@"play"];
    self.playButton.image = self.playImage;
    self.prevButton.image = [NSImage imageNamed:@"prev"];
    self.nextButton.image = [NSImage imageNamed:@"next"];
    self.artistLabel.fontSize = 12.f;
}

-(void)setPlayer:(Player *)player
{
    if (self.player != nil)
    {
        // Unregister observers
        [self.player removeObserver:self forKeyPath:@"currentTrack"];
        [self.player removeObserver:self forKeyPath:@"currentTrack.artwork"];
        [self.player removeObserver:self forKeyPath:@"state"];
        [self.player prepareForDealloc];
    }
    
    _player = player;
    
    if (self.player != nil)
    {
        // Register observers
        [self.player addObserver:self forKeyPath:@"currentTrack" options:NSKeyValueObservingOptionInitial context:NULL];
        [self.player addObserver:self forKeyPath:@"currentTrack.artwork" options:NSKeyValueObservingOptionInitial context:NULL];
        [self.player addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionInitial context:NULL];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // Current track has changed.
    if (object == self.player && [keyPath isEqualToString:@"currentTrack"])
    {
        if (self.player.currentTrack == nil)
        {
            self.artistLabel.stringValue = @"No Artist Name";
            self.songLabel.stringValue = @"No Track Name";
            self.songImage.image = nil;
        }
        else
        {
            self.artistLabel.stringValue = self.player.currentTrack.artistName;
            self.songLabel.stringValue = self.player.currentTrack.trackName;
            self.songImage.image = self.player.currentTrack.artwork;
        }
        
        
        return;
    }
    
    // The artwork of the current song has been loaded.
    if (object == self.player && [keyPath isEqualToString:@"currentTrack.artwork"])
    {
        self.songImage.image = self.player.currentTrack.artwork;
        return;
    }
    
    // The state of the player has changed.
    if (object == self.player && [keyPath isEqualToString:@"state"])
    {
        switch (self.player.state)
        {
            case PlayerStateStopped:
            case PlayerStatePaused:
                self.playButton.image = self.playImage;
                break;
            case PlayerStatePlaying:
                self.playButton.image = self.pauseImage;
                break;
            default:
                break;
        }
    }
}

- (IBAction)albumArtWasClicked:(id)sender
{
    [self.player openPlayerApplication];
}

- (IBAction)playButtonWasClicked:(id)sender
{
    switch (self.player.state)
    {
        case PlayerStateStopped:
        case PlayerStatePaused:
            [self.player play];
            break;
        case PlayerStatePlaying:
            [self.player pause];
        default:
            break;
    }
}

- (IBAction)nextButtonWasClicked:(id)sender
{
    [self.player next];
}

- (IBAction)prevButtonWasClicked:(id)sender
{
    [self.player previous];
}

@end
