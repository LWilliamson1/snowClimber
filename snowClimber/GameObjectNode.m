//
//  GameObjectNode.m
//  spriteKitTutorial
//
//  Created by Larry Williamson on 4/6/15.
//  Copyright (c) 2015 Larry Williamson Inc. All rights reserved.
//

#import "GameObjectNode.h"

@implementation GameObjectNode

- (BOOL) collisionWithPlayer:(SKNode *)player
{
    return NO;
}

- (void) checkNodeRemoval:(CGFloat)playerY
{
    if (playerY > self.position.y + 300.0f) {
        [self removeFromParent];
    }
}

@end
