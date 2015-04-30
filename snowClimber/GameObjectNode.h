//
//  GameObjectNode.h
//  spriteKitTutorial
//
//  Created by Larry Williamson on 4/6/15.
//  Copyright (c) 2015 Larry Williamson Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameObjectNode : SKNode

// Called when a player physics body collides with the game object's physics body
- (BOOL) collisionWithPlayer:(SKNode *)player;

// Called every frame to see if the game object should be removed from the scene
- (void) checkNodeRemoval:(CGFloat)playerY;

@end
