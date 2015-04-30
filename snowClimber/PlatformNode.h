//
//  PlatformNode.h
//  spriteKitTutorial
//
//  Created by Larry Williamson on 4/7/15.
//  Copyright (c) 2015 Larry Williamson Inc. All rights reserved.
//

#import "GameObjectNode.h"

typedef NS_ENUM(int, PlatformType) {
    PLATFORM_NORMAL,
    PLATFORM_SNOWY,
};


@interface PlatformNode : GameObjectNode

@property (nonatomic, assign) PlatformType platformType;

@end
