//
//  PowerUpNode.h
//  snowClimber
//
//  Created by Larry Williamson on 4/21/15.
//  Copyright (c) 2015 Larry Williamson Inc. All rights reserved.
//

#import "GameObjectNode.h"

typedef NS_ENUM(int, PowerUpType){
    LARGER,
    SMALLER
};

@interface PowerUpNode : GameObjectNode

@property (nonatomic, assign) PowerUpType powerUpType;


@end
