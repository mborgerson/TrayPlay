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

#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CALayer.h>

#import "ColorIconButton.h"

@interface ColorIconButton ()

@property CALayer *colorLayer;
@property CALayer *iconLayer;

-(void)setupLayers;

@end

@implementation ColorIconButton
{
    NSImage *_image;
}

-(void)awakeFromNib
{
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setupLayers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupLayers];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayers];
    }
    return self;
}

-(void)setupLayers
{
    [self setWantsLayer:YES];
    
    //self.layer.backgroundColor = [[NSColor redColor] CGColor];
    
    self.colorLayer = [CALayer layer];
    self.colorLayer.frame = self.layer.bounds;
    self.colorLayer.layoutManager = [CAConstraintLayoutManager layoutManager];
    [self.layer addSublayer:self.colorLayer];
    
    self.iconLayer = [CALayer layer];
    self.iconLayer.frame = self.colorLayer.bounds;
    self.iconLayer.layoutManager = [CAConstraintLayoutManager layoutManager];
    [self.colorLayer setMask:self.iconLayer];
    
    // Setup icon layer constraints
    CAConstraint *horizontalConstraint = [CAConstraint constraintWithAttribute:kCAConstraintMidX relativeTo:@"superlayer" attribute:kCAConstraintMidX];
    CAConstraint *verticalConstraint = [CAConstraint constraintWithAttribute:kCAConstraintMidY relativeTo:@"superlayer" attribute:kCAConstraintMidY];
    [self.iconLayer setConstraints:[NSArray arrayWithObjects:verticalConstraint, horizontalConstraint, nil]];

    // Setup defaults
    self.color = [NSColor blackColor];
    self.image = nil;
    
    //self.layer.backgroundColor = [[NSColor redColor] CGColor];
    self.padding = 5.f;
}

-(void)setColor:(NSColor *)color
{
    _color = color;
    self.colorLayer.backgroundColor = [self.color CGColor];
}

-(void)setImage:(NSImage *)image
{
    _image = image;
    
    if (image == nil)
    {
        self.iconLayer.contents = nil;
        return;
    }
    
    // Scale the image down to fit, and center it
    NSRect frame;
    frame.origin = CGPointMake(0.f, 0.f);
    
    if (self.image.size.width > self.image.size.height)
    {
        // Scale height
        frame.size.width = floorf(self.colorLayer.frame.size.width-self.padding*2.f);
        frame.size.height = floorf(frame.size.width*image.size.height/image.size.width);
        self.iconLayer.bounds = frame;
    }
    else
    {
        // Scale width
        frame.size.height = floorf(self.colorLayer.frame.size.height-self.padding*2.f);
        frame.size.width = floorf(image.size.width/image.size.height*frame.size.height);
        self.iconLayer.bounds = frame;
    }
    
    frame = self.iconLayer.frame;

    CGImageRef image_ref;
    image_ref = [self.image CGImageForProposedRect:&frame context:nil hints:nil];
    self.iconLayer.contents = (__bridge id)image_ref;
}

- (void)viewDidChangeBackingProperties
{
    if (_image != nil)
    {
        self.image = _image;
    }
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

-(void)mouseUp:(NSEvent *)theEvent
{
    if (self.target == nil) return;
    
    NSMethodSignature *signature = [[self.target class] instanceMethodSignatureForSelector:self.action];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self.target];
    [invocation setSelector:self.action];
    [invocation setArgument:(void *)&self atIndex:2];
    [invocation invoke];
}

@end

