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

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    PlayerStateStopped = 0,
    PlayerStatePaused,
    PlayerStatePlaying,
} PlayerState;

@interface Track : NSObject

@property (nonatomic) NSString *artistName;
@property (nonatomic) NSString *trackName;
@property (nonatomic) NSImage  *artwork;

- (id) initWithArtist:(NSString *)artistName track:(NSString *)trackName artwork:(NSImage *)artwork;

@end

@interface Player : NSObject
{
@protected
    PlayerState _state;
    Track *_currentTrack;
}

@property PlayerState state;
@property Track *currentTrack;

- (void) next;
- (void) previous;
- (void) pause;
- (void) play;
- (void) openPlayerApplication;
- (void) prepareForDealloc;

@end
