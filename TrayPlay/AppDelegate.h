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

#import "AboutController.h"
#import "PlayerController.h"
#import "ColorIconButton.h"

#import "SFBPopover.h"
#import "ITSwitch.h"
#import <Sparkle/Sparkle.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong) NSView *mainView;
@property (strong) NSStatusItem *statusItem;
@property (strong) SFBPopover *popover;
@property (strong) AboutController *aboutController;
@property (weak) IBOutlet PlayerController *playerController;
@property (weak) IBOutlet NSView *settingsView;
@property (weak) IBOutlet ITSwitch *launchAtLoginToggle;
@property (weak) IBOutlet ITSwitch *autoUpdateToggle;
@property (weak) IBOutlet ColorIconButton *closeButton;
@property (weak) IBOutlet ColorIconButton *backButton;
@property (weak) IBOutlet ColorIconButton *settingsButton;
@property (weak) IBOutlet SUUpdater *updater;
@property (weak) IBOutlet NSSegmentedControl *selectedPlayer;

-(IBAction)toggleLaunchAtLogin:(id)sender;
-(IBAction)showSettingsView:(id)sender;
-(IBAction)hideSettingsView:(id)sender;
-(IBAction)quitApplication:(id)sender;
-(IBAction)showAbout:(id)sender;
- (IBAction)toggleAutoUpdate:(id)sender;
- (IBAction)currentPlayerChanged:(id)sender;

@end
