//
//  PlatformNode.m
//  spriteKitTutorial
//
//  Created by Larry Williamson on 4/7/15.
//  Copyright (c) 2015 Larry Williamson Inc. All rights reserved.
//

#import "PlatformNode.h"

@implementation PlatformNode

- (BOOL) collisionWithPlayer:(SKNode *)player
{
    
    
    // Only bounce the player if he's falling
    if (player.physicsBody.velocity.dy < 0) {
        
        float player_velocity = 250.0;

        if (_platformType == PLATFORM_SNOWY) {
            
            player_velocity = 250.0;
            [self removeFromParent];
            
        }
        player.physicsBody.velocity = CGVectorMake(player.physicsBody.velocity.dx, player_velocity);



    }
    
    // No stars for platforms
    return NO;
}

@end
