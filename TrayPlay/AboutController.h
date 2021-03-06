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

@interface AboutController : NSWindowController

@property (weak) IBOutlet NSImageView *icon;
@property (strong) IBOutlet NSWindow *licensesWindow;
@property (assign) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSTextField *version;
- (IBAction)showLicenses:(id)sender;
- (IBAction)openWebsite:(id)sender;

@end
