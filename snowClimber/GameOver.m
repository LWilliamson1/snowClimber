//
//  GameOver.m
//  snowClimber
//
//  Created by Larry Williamson on 4/18/15.
//  Copyright (c) 2015 Larry Williamson Inc. All rights reserved.
//

#import "GameOver.h"
#import "SaveState.h"
#import "GameScene.h"

@implementation GameOver

- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        // Stars
        SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"Star"];
        star.position = CGPointMake(25, self.size.height-30);
        [self addChild:star];
        SKLabelNode *starLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
        starLabel.fontSize = 30;
        starLabel.fontColor = [SKColor whiteColor];
        starLabel.position = CGPointMake(50, self.size.height-40);
        starLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        [starLabel setText:[NSString stringWithFormat:@"X %d", [SaveState savedInstance].stars]];
        [self addChild:starLabel];
        
        // Score
        SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
        scoreLabel.fontSize = 60;
        scoreLabel.fontColor = [SKColor whiteColor];
        scoreLabel.position = CGPointMake(160, 300);
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        [scoreLabel setText:[NSString stringWithFormat:@"%d", [SaveState savedInstance].score]];
        [self addChild:scoreLabel];
        
        // High Score
        SKLabelNode *highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
        highScoreLabel.fontSize = 30;
        highScoreLabel.fontColor = [SKColor cyanColor];
        highScoreLabel.position = CGPointMake(160, 150);
        highScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        [highScoreLabel setText:[NSString stringWithFormat:@"High Score: %d", [SaveState savedInstance].highScore]];
        [self addChild:highScoreLabel];
        
        // Try again
        SKLabelNode *tryAgainLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
        tryAgainLabel.fontSize = 30;
        tryAgainLabel.fontColor = [SKColor whiteColor];
        tryAgainLabel.position = CGPointMake(160, 50);
        tryAgainLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        [tryAgainLabel setText:@"Tap To Try Again"];
        [self addChild:tryAgainLabel];
    }
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Transition back to the Game
    SKScene *gameScene = [[GameScene alloc] initWithSize:self.size];
    SKTransition *reveal = [SKTransition fadeWithDuration:0.5];
    [self.view presentScene:gameScene transition:reveal];
}


@end
