//
//  SaveState.m
//  snowClimber
//
//  Created by Larry Williamson on 4/17/15.
//  Copyright (c) 2015 Larry Williamson Inc. All rights reserved.
//

#import "SaveState.h"
#import "GameScene.h"

@implementation SaveState

+ (instancetype) savedInstance{
    static dispatch_once_t pred = 0;
    static  SaveState *_savedInstance = nil;
    
    dispatch_once( &pred, ^{
        _savedInstance = [[super alloc] init];
    });
    return _savedInstance;
}

- (id) init
{
    if (self = [super init]) {
        // Init
        _score = 0;
        _highScore = 0;
        _stars = 0;
        
        // Load game state
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id highScore = [defaults objectForKey:@"highScore"];
        if (highScore) {
            _highScore = [highScore intValue];
        }
        id stars = [defaults objectForKey:@"stars"];
        if (stars) {
            _stars = [stars intValue];
        }
        
    }
    return self;
}

- (void) saveState
{
    // Update highScore
    _highScore = MAX(_score, _highScore);
    
    // Store in user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:_highScore] forKey:@"highScore"];
    [defaults setObject:[NSNumber numberWithInt:_stars] forKey:@"stars"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
