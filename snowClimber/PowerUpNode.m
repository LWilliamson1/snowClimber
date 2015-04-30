//
//  PowerUpNode.m
//  snowClimber
//
//  Created by Larry Williamson on 4/21/15.
//  Copyright (c) 2015 Larry Williamson Inc. All rights reserved.
//

#import "PowerUpNode.h"
#import "GameScene.h"


@import AVFoundation;

@interface PowerUpNode ()
{
    SKAction * _growSound;
    SKAction *_shrinkSound;
    SKAction *_blinkSequence;
}

@end

@implementation PowerUpNode

- (id) init
{
    if (self = [super init]) {
        _growSound = [SKAction playSoundFileNamed:@"grow.wav" waitForCompletion:NO];
        _shrinkSound = [SKAction playSoundFileNamed:@"shrink.wav" waitForCompletion:NO];
        _blinkSequence = [SKAction sequence:@[
                                              [SKAction fadeAlphaTo:0.0 duration:0.1],
                                              [SKAction fadeAlphaTo:1.0 duration:0.1]
                                                       
                                                       ]];
        
    }
    return self;
}

- (BOOL) collisionWithPlayer:(SKNode *)player
{
    player.physicsBody.velocity = CGVectorMake(player.physicsBody.velocity.dx, 450.0f);
    
    if (_powerUpType == LARGER)
    {
        
        [self.parent runAction:_growSound];
        //[self.parent runAction:_shrinkSound];
        player.xScale = 1.2;
        player.yScale = 1.2;
        
        [player runAction:[SKAction repeatAction:_blinkSequence count:5]];
        
        [NSTimer scheduledTimerWithTimeInterval:4.0
                                         target:self selector:@selector(removePowerUp:)
                                       userInfo:player  repeats:NO];

    }
    else{
        [self.parent runAction: _shrinkSound];
        [player runAction:[SKAction repeatAction:_blinkSequence count:5]];
        player.xScale = 0.8;
        player.yScale = 0.8;
        [NSTimer scheduledTimerWithTimeInterval:4.0
                                         target:self selector:@selector(removeDebuff:)
                                       userInfo:player  repeats:NO];
        
    }

    
    [self removeFromParent];
    
    return YES;
    
}



- (void) removePowerUp: (NSTimer*) timer{

    SKNode * player = [timer userInfo];
    
    [player.parent runAction:_shrinkSound];
    
    [player runAction:[SKAction repeatAction:_blinkSequence count:5] withKey:@"blink"];
    
    
    //player.alpha = 0;
    
    player.xScale = 1;
    player.yScale = 1;

}

- (void) removeDebuff: (NSTimer*) timer{
    SKNode * player = [timer userInfo];
    [player.parent runAction:_growSound];
    
    [player runAction:[SKAction repeatAction:_blinkSequence count:10]];
    
    player.alpha = 1;
    
    player.xScale = 1;
    player.yScale = 1;
}

@end
