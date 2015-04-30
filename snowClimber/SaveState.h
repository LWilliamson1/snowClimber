//
//  SaveState.h
//  snowClimber
//
//  Created by Larry Williamson on 4/17/15.
//  Copyright (c) 2015 Larry Williamson Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SaveState : NSObject

@property (nonatomic, assign) int highScore;
@property (nonatomic, assign) int score;
@property (nonatomic, assign) int stars;

+ (instancetype) savedInstance;
- (void) saveState;

@end
