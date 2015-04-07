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

#import <QuartzCore/CAAnimation.h>
#import "AppDelegate.h"
#import "MXLoginItemManager.h"
#import "iTunesPlayer.h"
#import "SpotifyPlayer.h"

@interface AppDelegate ()

    @property (strong) CATransition *transition;

@end


@implementation AppDelegate

void notification_callback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    AppDelegate *appDelegate = (__bridge AppDelegate *)observer;
    [appDelegate setStatusItemImages];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Create Status Item
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    self.statusItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.highlightMode = YES;
    
    // Set up Target-Action Mechanism for the Status Item
    self.statusItem.target = self;
    self.statusItem.action = @selector(statusItemWasClicked:);
    [self.statusItem sendActionOn:NSLeftMouseDownMask];
    [self setStatusItemImages];
    
    // Add an observer to detect when the interface theme changes
    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDistributedCenter(),
        (__bridge const void *)(self),
        &notification_callback,
        (CFStringRef)@"AppleInterfaceThemeChangedNotification",
        NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately);
    
    // Create the main view
    self.mainView = [[NSView alloc] initWithFrame:self.playerController.view.frame];
    self.mainView.wantsLayer = YES;
    [self.mainView addSubview:self.playerController.view];
    
    // Setup Settings, Back, and Close buttons
    self.settingsButton.image = [NSImage imageNamed:@"hamburger"];
    self.closeButton.image = [NSImage imageNamed:@"close"];
    self.backButton.image = [NSImage imageNamed:@"arrow_right"];
    
    // Create the Popover
    self.popover = [[SFBPopover alloc] initWithContentView:self.mainView];
    self.popover.borderColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
    self.popover.backgroundColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
    self.popover.borderWidth = 0;
    self.popover.cornerRadius = 0;
    self.popover.viewMargin = 5;
    
    self.transition = [CATransition animation];
    self.mainView.animations = [NSDictionary dictionaryWithObject:self.transition
                                                           forKey:@"subviews"];
    
    // Allow popover to go into any space
    self.popover.popoverWindow.collectionBehavior = NSWindowCollectionBehaviorMoveToActiveSpace;
  
    // Setup Settings
    [self.launchAtLoginToggle setOn:[MXLoginItemManager isAppInLoginItems]];
    [self.updater addObserver:self forKeyPath:@"automaticallyChecksForUpdates" options:NSKeyValueObservingOptionInitial context:NULL];
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"preferredPlayer" options:NSKeyValueObservingOptionInitial context:NULL];

}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // Handle Updates to automaticallyChecksForUpdates
    if ([keyPath isEqualToString:@"automaticallyChecksForUpdates"])
    {
        self.autoUpdateToggle.on = self.updater.automaticallyChecksForUpdates;
    }
    else if ([keyPath isEqualToString:@"preferredPlayer"])
    {
        NSString *preferredPlayer = [[NSUserDefaults standardUserDefaults] objectForKey:@"preferredPlayer"];
        if (preferredPlayer == nil)
        {
            // Select iTunes
            [[NSUserDefaults standardUserDefaults] setObject:@"iTunes" forKey:@"preferredPlayer"];
        }
        else if ([preferredPlayer isEqualToString:@"iTunes"])
        {
            self.playerController.player = [[iTunesPlayer alloc] init];
            self.selectedPlayer.selectedSegment = 0;
        }
        else if ([preferredPlayer isEqualToString:@"Spotify"])
        {
            self.playerController.player = [[SpotifyPlayer alloc] init];
            self.selectedPlayer.selectedSegment = 1;
        }
        else
        {
            // Select iTunes as the preferred player
            [[NSUserDefaults standardUserDefaults] setObject:@"iTunes" forKey:@"preferredPlayer"];
        }
    }
}

-(void)setStatusItemImages {
    NSString *osxMode = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"];
    
    if ([osxMode isEqualToString:@"Dark"])
    {
        // Dark Mode
        // Set Status Item image
        self.statusItem.image = [NSImage imageNamed:@"status_on"];
        self.statusItem.alternateImage = [NSImage imageNamed:@"status_on"];
    }
    else
    {
        // Light Mode
        // Set Status Item image
        self.statusItem.image = [NSImage imageNamed:@"status_off"];
        self.statusItem.alternateImage = [NSImage imageNamed:@"status_on"];
    }
}

-(void)statusItemWasClicked:(id)sender {
    if (self.popover.isVisible)
    {
        /* Popover was already visible when user clicked the status item.
         * Assume user wants to close the popover.
         */
        [self.popover closePopover:self];
        return;
    }

    // Get Status Item Coordinates
    // <hack>
    NSRect frame = [[self.statusItem valueForKey:@"window"] frame];
    // </hack>
    
    NSPoint popoverPoint;
    popoverPoint.y = frame.origin.y;
    popoverPoint.x = frame.origin.x + frame.size.width/2.0f;

    [self.popover displayPopoverInWindow:nil atPoint:popoverPoint];
    [self.popover.popoverWindow orderFrontRegardless];
    [self.popover.popoverWindow makeKeyWindow];
    self.popover.closesWhenPopoverResignsKey = YES;
}

-(IBAction)showSettingsView:(id)sender
{
    self.transition.type = kCATransitionPush;
    self.transition.subtype = kCATransitionFromLeft;
    [[self.mainView animator] replaceSubview:self.playerController.view
                                        with:self.settingsView];
}

-(IBAction)hideSettingsView:(id)sender
{
    self.transition.type = kCATransitionPush;
    self.transition.subtype = kCATransitionFromRight;
    [[self.mainView animator] replaceSubview:self.settingsView
                                        with:self.playerController.view];
}

-(IBAction)quitApplication:(id)sender
{
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
}


-(IBAction)toggleLaunchAtLogin:(id)sender
{
    if (self.launchAtLoginToggle.isOn)
    {
        [MXLoginItemManager addAppToLoginItems];
    }
    else
    {
        [MXLoginItemManager removeAppFromLoginItems];
    }
}

-(IBAction)showAbout:(id)sender
{
    if (self.aboutController == nil)
    {
        self.aboutController = [[AboutController alloc] initWithWindowNibName:@"AboutController"];
    }
    
    [self.aboutController.window makeKeyAndOrderFront:self.aboutController.window];
}

- (IBAction)toggleAutoUpdate:(id)sender {
    self.updater.automaticallyChecksForUpdates = self.autoUpdateToggle.isOn;
}

- (IBAction)currentPlayerChanged:(id)sender {
    // TODO: Make this more elegant. Right now this function expects the view
    // to organize the contents of the segment selector.
    switch ([self.selectedPlayer selectedSegment])
    {
        case 0:
            /* iTunes Selected */
            [[NSUserDefaults standardUserDefaults] setObject:@"iTunes" forKey:@"preferredPlayer"];
            break;
        case 1:
            /* Spotify Selected */
            [[NSUserDefaults standardUserDefaults] setObject:@"Spotify" forKey:@"preferredPlayer"];
            break;
        default:
            /* Unknown player selected */
            break;
    }
}

@end
