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

#import "Player.h"

@implementation Track

- (id) initWithArtist:(NSString *)artistName track:(NSString *)trackName artwork:(NSImage *)artwork
{
    self.artistName = artistName;
    self.trackName = trackName;
    self.artwork = artwork;
    return self;
}

@end

@implementation Player

- (id) init
{
    self = [super init];
    if (self) {
        _currentTrack = nil;
        _state = PlayerStateStopped;
    }
    return self;
}

- (void) next
{
}

- (void) previous
{
}

- (void) pause
{
}

- (void) play
{
}

- (void) openPlayerApplication
{
}

- (void) prepareForDealloc
{
}

@end
