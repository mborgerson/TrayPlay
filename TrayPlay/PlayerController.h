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

#import <Cocoa/Cocoa.h>
#import "Player.h"
#import "AlbumImageView.h"
#import "MXMarqueeText.h"
#import "ColorIconButton.h"


@interface ColorIconView : NSImageView

@property (nonatomic) NSColor *color;
-(void)animateNewColor:(NSColor *) theColor;

@end

@protocol PlayerDelegate <NSObject>

@end

@interface PlayerController : NSViewController

@property (strong, nonatomic) Player *player;
@property (weak) IBOutlet AlbumImageView *songImage;
@property (weak) IBOutlet MXMarqueeText *artistLabel;
@property (weak) IBOutlet MXMarqueeText *songLabel;
@property (weak) IBOutlet ColorIconButton *playButton;
@property (weak) IBOutlet ColorIconButton *nextButton;
@property (weak) IBOutlet ColorIconButton *prevButton;

- (IBAction)albumArtWasClicked:(id)sender;
- (IBAction)playButtonWasClicked:(id)sender;
- (IBAction)nextButtonWasClicked:(id)sender;
- (IBAction)prevButtonWasClicked:(id)sender;

@end
