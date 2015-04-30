//
//  StarNode.h
//  spriteKitTutorial
//
//  Created by Larry Williamson on 4/6/15.
//  Copyright (c) 2015 Larry Williamson Inc. All rights reserved.
//

#import "GameObjectNode.h"

typedef NS_ENUM(int, StarType){
    STAR_NORMAL,
    STAR_SPECIAL,
};

@interface StarNode : GameObjectNode

@property (nonatomic, assign) StarType starType;

@end
