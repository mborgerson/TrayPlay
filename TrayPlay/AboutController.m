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

#import "AboutController.h"
#import "version.h"

@implementation AboutController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Load the icon
    self.icon.image = [NSImage imageNamed:@"AppIcon"];
    self.version.stringValue = [NSString stringWithFormat:@"Version %s (%s)", VERSION_ID, BUILD_ID];
}

- (IBAction)showLicenses:(id)sender
{
    // Load the credits
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Credits" withExtension:@"rtf"];
    NSAttributedString *str = [[NSAttributedString alloc] initWithURL:url documentAttributes:NULL];
    [self.textView.textStorage setAttributedString:str];
    [self.licensesWindow makeKeyAndOrderFront:self.licensesWindow];
}

- (IBAction)openWebsite:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://mborgerson.com/trayplay"]];
}

- (void) windowDidResignKey:(NSNotification *)notification
{
    [self.window close];
}


@end
