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

#import "SpotifyPlayer.h"
#import "Spotify.h"

#import "AFNetworking.h"

@interface SpotifyPlayer ()

@property (strong) SpotifyApplication *spotify;
@property (strong) NSString *lastUpdateTrack;
@property (strong) NSTimer *timer;

-(void)update;

@end

@implementation SpotifyPlayer

- (id) init
{
    self = [super init];
    if (self) {
        self.lastUpdateTrack = nil;
        self.spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
        
        // Using a timer here because, sadly, it's the only way to get updates from
        // Spotify using the scripting bridge...
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
    [self.spotify nextTrack];
    [self update];
}

- (void) previous
{
    [self.spotify previousTrack];
    [self update];
}

- (void) pause
{
    [self.spotify pause];
    [self update];
}

- (void) play
{
    [self.spotify play];
    [self update];
}

- (void)update
{
    switch (self.spotify.playerState)
    {
        case SpotifyEPlSStopped:
            self.state = PlayerStateStopped;
            break;
        case SpotifyEPlSPaused:
            self.state = PlayerStatePaused;
            break;
        case SpotifyEPlSPlaying:
            self.state = PlayerStatePlaying;
            break;
    }
    
    if ([self.spotify.currentTrack.id isEqualToString:self.lastUpdateTrack])
    {
        // This is the same track.
        
        // No updates.
        return;
    }
    
    self.lastUpdateTrack = [self.spotify.currentTrack.id copy];
    
    Track *track = nil;
    if (self.spotify.currentTrack != nil)
    {
        track = [[Track alloc] initWithArtist:[self.spotify.currentTrack.artist copy]
                                        track:[self.spotify.currentTrack.name copy]
                                      artwork:[self.spotify.currentTrack.artwork copy]];
        [self getTrackInfo];
    }
    
    self.currentTrack = track;
}

- (void) openPlayerApplication
{
    [[NSWorkspace sharedWorkspace] openFile:nil withApplication:@"Spotify"];
}

-(void) prepareForDealloc
{
    [self.timer invalidate];
}

-(void) getTrackInfo
{
    // Make a request for the track info
    NSString *trackId = [self.spotify.currentTrack.spotifyUrl substringFromIndex:14]; // Trim spotify:track: part...
    NSMutableString *url = [[NSMutableString alloc] initWithString:@"https://api.spotify.com/v1/tracks/"];
    [url appendString:trackId];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        bool response_good = true;
        
        id images, image0, imageurl;
        
        id album = [responseObject objectForKey:@"album"];
        response_good = [album isKindOfClass:[NSDictionary class]];
        
        if (response_good)
        {
            images = [album objectForKey:@"images"];
            response_good &= [images isKindOfClass:[NSArray class]] && [images count] > 0;
        }
        
        if (response_good)
        {
            image0 = [images objectAtIndex:0];
            response_good &= [image0 isKindOfClass:[NSDictionary class]];
        }
        
        if (response_good)
        {
            imageurl = [image0 objectForKey:@"url"];
            response_good &= [imageurl isKindOfClass:[NSString class]];
        }
        
        if (response_good)
        {
            [self loadArtworkFromUrl:[[NSURL alloc] initWithString:imageurl]];
        }
        else
        {
            NSLog(@"Error getting track details from Spotify for URL:%@", url);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

-(void) loadArtworkFromUrl: (NSURL *) url
{
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    
    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.currentTrack.artwork = responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [requestOperation start];

    
}

@end
