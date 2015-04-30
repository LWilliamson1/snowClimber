//
//  StarNode.m
//  spriteKitTutorial
//
//  Created by Larry Williamson on 4/6/15.
//  Copyright (c) 2015 Larry Williamson Inc. All rights reserved.
//

#import "StarNode.h"
#import "SaveState.h"

@import AVFoundation;

@interface StarNode ()
{
    SKAction *_starSound;
}
@end

@implementation StarNode

- (id) init
{
    if (self = [super init]) {
        // Sound for when a star is collected
        _starSound = [SKAction playSoundFileNamed:@"StarPing.wav" waitForCompletion:NO];
    }
    
    return self;
}

- (BOOL) collisionWithPlayer:(SKNode *)player
{
    // Boost the player up
    player.physicsBody.velocity = CGVectorMake(player.physicsBody.velocity.dx, 400.0f);
    
    // Play sound
    [self.parent runAction:_starSound];
    
    // Remove this star
    [self removeFromParent];
    
    // Inc star count/score
    [SaveState savedInstance].score += (_starType == STAR_NORMAL ? 20 : 100);
    [SaveState savedInstance].stars += (_starType == STAR_NORMAL ? 1 : 5);
    
    // The HUD needs updating to show the new stars and score
    return YES;
}



@end
