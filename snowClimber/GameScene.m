//
//  GameScene.m
//  spriteKitTutorial
//
//  Created by Larry Williamson on 4/5/15.
//  Copyright (c) 2015 Larry Williamson Inc. All rights reserved.
//

#import "GameScene.h"
#import "StarNode.h"
#import "GameObjectNode.h"
#import "PlatformNode.h"
#import "SaveState.h"
#import "GameOver.h"
#import "PowerUpNode.h"

@import CoreMotion;

@import AVFoundation;

typedef NS_OPTIONS(uint32_t, CollisionCategory) {
    CollisionCategoryPlayer   = 0x1 << 0,
    CollisionCategoryStar     = 0x1 << 1,
    CollisionCategoryPlatform = 0x1 << 2,
    CollisionCategoryPowerUp  = 0x1 << 3,
};

// Motion manager for accelerometer
CMMotionManager *_motionManager;

// Acceleration value from accelerometer
CGFloat _xAcceleration;

// HUD labels
SKLabelNode *_scoreLabel;
SKLabelNode *_starLabel;

bool _gameOver;

int _maxPlayerHeight;

int _level = 0;

int _currentScore = 0;



@interface GameScene () <SKPhysicsContactDelegate>
{
    // Layered Nodes
    SKNode *_backgroundNode;
    SKNode *_midgroundNode;
    SKNode *_foregroundNode;
    SKNode *_hudNode;
    
    // Player Node
    SKNode *_player;
    
    // Tap To Start node
    SKSpriteNode *_tapToStartNode;
    
    // Welcome Sign node
    SKSpriteNode *_welcomeSignNode;
    
    
    
    // Height at which level ends
    int _endLevelY;
}
@end


@implementation GameScene

-(id) initWithSize:(CGSize)size
{
    
    if (self = [super initWithSize:size]){
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // Add Physics
        self.physicsWorld.gravity = CGVectorMake(0.0f, -2.0f);
        
        // Set contact delegate
        self.physicsWorld.contactDelegate = self;
        
        // Create the game nodes
        // Background
        _backgroundNode = [self createBackgroundNode];
        [self addChild:_backgroundNode];
        
        // Midground
        _midgroundNode = [self createMidgroundNode];
        [self addChild:_midgroundNode];
        
        // Foreground
        _foregroundNode = [SKNode node];
        [self addChild:_foregroundNode];
        
        
        
        // HUD
        _hudNode = [SKNode node];
        [self addChild:_hudNode];
        
        // Add the player
        _player = [self createPlayer];
        [_foregroundNode addChild:_player];
        
        // Tap to Start
        _tapToStartNode = [SKSpriteNode spriteNodeWithImageNamed:@"TapToStart"];
        _tapToStartNode.position = CGPointMake(160, 180.0f);
        [_hudNode addChild:_tapToStartNode];
        
        // Welcome Sign
        _welcomeSignNode = [SKSpriteNode spriteNodeWithImageNamed:@"welcome"];
        _welcomeSignNode.position = CGPointMake(200, 0.0f);
        //[_hudNode addChild:_welcomeSignNode];
        
        // Reset if needed
        _maxPlayerHeight = 80;
        //[SaveState savedInstance].score = 0;
        _gameOver = NO;
        
        [SaveState savedInstance].score = _currentScore;
        
        // Remove bellow if stars are currency
        [SaveState savedInstance].stars = 0;
        
        
        
        // Build the HUD
        
        // Stars
        SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"Star"];
        star.position = CGPointMake(25, self.size.height-30);
        [_hudNode addChild:star];
        
        _starLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
        _starLabel.fontSize = 30;
        _starLabel.fontColor = [SKColor whiteColor];
        _starLabel.position = CGPointMake(50, self.size.height-40);
        _starLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        
        [_starLabel setText:[NSString stringWithFormat:@"X %d", [SaveState savedInstance].stars]];
        [_hudNode addChild:_starLabel];
        
        // Score

        _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
        _scoreLabel.fontSize = 30;
        _scoreLabel.fontColor = [SKColor whiteColor];
        _scoreLabel.position = CGPointMake(self.size.width-20, self.size.height-40);
        _scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
        
        //[_scoreLabel setText:@"0"];
        [_scoreLabel setText:[[NSString alloc] initWithFormat: @"%d", _currentScore]];
        [_hudNode addChild:_scoreLabel];
        
        
        
        // CoreMotion
        _motionManager = [[CMMotionManager alloc] init];
        
        _motionManager.accelerometerUpdateInterval = 0.2;
        
        [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 CMAcceleration acceleration = accelerometerData.acceleration;
                                                 _xAcceleration = (acceleration.x * 1) + (_xAcceleration * 0.25);
                                             }];
        
        
        NSArray * levelNames = @[@"Level01", @"Level02", @"Level03"];
        // Load the level
        NSString *levelPlist = [[NSBundle mainBundle] pathForResource: levelNames[_level] ofType: @"plist"];
        NSDictionary *levelData = [NSDictionary dictionaryWithContentsOfFile:levelPlist];
        
        // Height at which the player ends the level
        _endLevelY = [levelData[@"EndY"] intValue];
        
        // Add powerups
        NSDictionary *powerUps = levelData[@"PowerUps"];
        NSArray *powerUpPositions = powerUps[@"Positions"];
        for (NSDictionary *powerUpPosition in powerUpPositions) {
            CGFloat x = [powerUpPosition[@"x"] floatValue];
            CGFloat y = [powerUpPosition[@"y"] floatValue];
            PowerUpType type = [powerUpPosition[@"type"] intValue];
            
            PowerUpNode *powerUpNode = [self createPowerUpAtPosition: CGPointMake(x, y) ofType: type];
            [_foregroundNode addChild:powerUpNode];
        }
        
        // Add the stars
        NSDictionary *stars = levelData[@"Stars"];
        NSDictionary *starPatterns = stars[@"Patterns"];
        NSArray *starPositions = stars[@"Positions"];
        for (NSDictionary *starPosition in starPositions) {
            CGFloat patternX = [starPosition[@"x"] floatValue];
            CGFloat patternY = [starPosition[@"y"] floatValue];
            NSString *pattern = starPosition[@"pattern"];
            
            // Look up the pattern
            NSArray *starPattern = starPatterns[pattern];
            for (NSDictionary *starPoint in starPattern) {
                CGFloat x = [starPoint[@"x"] floatValue];
                CGFloat y = [starPoint[@"y"] floatValue];
                StarType type = [starPoint[@"type"] intValue];
                
                StarNode *starNode = [self createStarAtPosition:CGPointMake(x + patternX, y + patternY) ofType:type];
                [_foregroundNode addChild:starNode];
            }
        }
        
        
        // Add the platforms
        NSDictionary *platforms = levelData[@"Platforms"];
        NSDictionary *platformPatterns = platforms[@"Patterns"];
        NSArray *platformPositions = platforms[@"Positions"];
        for (NSDictionary *platformPosition in platformPositions) {
            CGFloat patternX = [platformPosition[@"x"] floatValue];
            CGFloat patternY = [platformPosition[@"y"] floatValue];
            NSString *pattern = platformPosition[@"pattern"];
            
            // Look up the pattern
            NSArray *platformPattern = platformPatterns[pattern];
            for (NSDictionary *platformPoint in platformPattern) {
                CGFloat x = [platformPoint[@"x"] floatValue];
                CGFloat y = [platformPoint[@"y"] floatValue];
                PlatformType type = [platformPoint[@"type"] intValue];
                
                PlatformNode *platformNode = [self createPlatformAtPosition:CGPointMake(x + patternX, y + patternY)
                                                                     ofType:type];
                [_foregroundNode addChild:platformNode];
            }
        }
    }
    return self;
}


- (SKNode *) createBackgroundNode
{
   
    SKNode *backgroundNode = [SKNode node];
    

    // Go through images until the entire background is built
    for (int nodeCount = 0; nodeCount < 20; nodeCount++) {
      
        NSString *backgroundImageName = [NSString stringWithFormat:@"Mountain%02d", nodeCount+1];
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:backgroundImageName];

        node.anchorPoint = CGPointMake(0.5f, 0.0f);
        node.position = CGPointMake(160.0f, nodeCount*64.0f);

        [backgroundNode addChild:node];
    }

    // Return the completed background node
    return backgroundNode;
}

- (SKNode *)createMidgroundNode
{
    SKNode *midgroundNode = [SKNode node];
    
    // Add assets
    for (int i=0; i<10; i++) {
        NSString *spriteName;
        // 2
        int r = arc4random() % 2;
        if (r > 0) {
            spriteName = @"BranchRight";
        } else {
            spriteName = @"BranchLeft";
        }
        
        SKSpriteNode *branchNode = [SKSpriteNode spriteNodeWithImageNamed:spriteName];
        branchNode.position = CGPointMake(160.0f, 500.0f * i);
        [midgroundNode addChild:branchNode];
    }
  
    return midgroundNode;	
}

- (SKNode *) createPlayer
{
    SKNode *playerNode = [SKNode node];
    [playerNode setPosition:CGPointMake(160.0f, 30.0f)];
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"hero"];
    [playerNode addChild:sprite];
    
    
    playerNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
    
    playerNode.physicsBody.dynamic = NO;
    
    playerNode.physicsBody.allowsRotation = YES;
    
    playerNode.physicsBody.restitution = 1.0f;
    playerNode.physicsBody.friction = 0.0f;
    playerNode.physicsBody.angularDamping = 0.0f;
    playerNode.physicsBody.linearDamping = 0.0f;
    
    playerNode.physicsBody.usesPreciseCollisionDetection = YES;
    
    playerNode.physicsBody.categoryBitMask = CollisionCategoryPlayer;
    
    playerNode.physicsBody.collisionBitMask = 0;
    
    playerNode.physicsBody.contactTestBitMask = CollisionCategoryStar | CollisionCategoryPlatform | CollisionCategoryPowerUp;
    
    return playerNode;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // if playing return
    if (_player.physicsBody.dynamic) return;
    
    // Remove the Tap to Start node
    [_tapToStartNode removeFromParent];
    
    // Make physics dynamic
    _player.physicsBody.dynamic = YES;

    //initial thurst
    [_player.physicsBody applyImpulse:CGVectorMake(0.0f, 40.0f)];
}

- (StarNode *) createStarAtPosition:(CGPoint)position ofType:(StarType)type
{

    StarNode *node = [StarNode node];
    [node setPosition:position];
    [node setName:@"NODE_STAR"];
    
    
    [node setStarType:type];
    SKSpriteNode *sprite;
    
    //set different star images. Possibly remove special stars and add power ups
    if (type == STAR_SPECIAL) {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"StarSpecial"];
    } else {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Star"];
    }
    [node addChild:sprite];

    //set contact size
    node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
    
    node.physicsBody.dynamic = NO;
    
    node.physicsBody.categoryBitMask = CollisionCategoryStar;
    node.physicsBody.collisionBitMask = 0;
    
    return node;
}

-(PowerUpNode*) createPowerUpAtPosition:(CGPoint)position ofType:(PowerUpType)type
{
    PowerUpNode * node = [PowerUpNode node];
    [node setPosition:position];
    [node setName:@"NODE_POWERUP"];
    
    [node setPowerUpType:type];
    SKSpriteNode *sprite;
    
    if (type == LARGER) {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"red_pill"];
    }
    else{
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"yellow_pill"];
    }
    
    [node addChild:sprite];
    
    //set contact size
    node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
    
    node.physicsBody.dynamic = NO;
    node.physicsBody.categoryBitMask = CollisionCategoryPowerUp;
    node.physicsBody.collisionBitMask = 0;
    
    
    return node;
}


- (void) didBeginContact:(SKPhysicsContact *)contact
{
    BOOL updateHUD = NO;

    SKNode *other = (contact.bodyA.node != _player) ? contact.bodyA.node : contact.bodyB.node;
    
    if ([other.name isEqual: @"NODE_POWERUP"]){
        [(GameObjectNode *)other collisionWithPlayer:_player];
        //SEL selector = NSSelectorFromString(@"removePowerUp:other:");

    }
    else{
    
        updateHUD = [(GameObjectNode *)other collisionWithPlayer:_player];

    
        // Update HUD
        if (updateHUD) {
            [_starLabel setText:[NSString stringWithFormat:@"X %d", [SaveState savedInstance].stars]];
            [_scoreLabel setText:[NSString stringWithFormat:@"%d", [SaveState savedInstance].score]];
        
        }
    }
}
/*
- (void) removePowerUp:(PowerUpNode *) other
{
    [(GameObjectNode*)other playSound];
    _player.xScale = 1;
    _player.yScale = 1;
    
     //[(PowerUpNode *)node playSound:_player];
}
*/
- (PlatformNode *) createPlatformAtPosition:(CGPoint)position ofType:(PlatformType)type
{

    PlatformNode *node = [PlatformNode node];
    [node setPosition:position];
    [node setName:@"NODE_PLATFORM"];
    [node setPlatformType:type];
    
    SKSpriteNode *sprite;
    if (type == PLATFORM_SNOWY) {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Platform_snowy"];
    } else {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Platform"];
    }
    [node addChild:sprite];
    
    node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
    node.physicsBody.dynamic = NO;
    node.physicsBody.categoryBitMask = CollisionCategoryPlatform;
    node.physicsBody.collisionBitMask = 0;
    
    return node;
}

- (void) update:(CFTimeInterval)currentTime {
    
    if (_gameOver) return;

    
    if ((int)_player.position.y > _maxPlayerHeight) {
        [SaveState savedInstance].score += (int)_player.position.y - _maxPlayerHeight;
        _maxPlayerHeight = (int)_player.position.y;
        [_scoreLabel setText:[NSString stringWithFormat:@"%d", [SaveState savedInstance].score]];
    }

    // Remove game objects that have passed by
    [_foregroundNode enumerateChildNodesWithName:@"NODE_PLATFORM" usingBlock:^(SKNode *node, BOOL *stop) {
        [((PlatformNode *)node) checkNodeRemoval:_player.position.y];
    }];
    [_foregroundNode enumerateChildNodesWithName:@"NODE_STAR" usingBlock:^(SKNode *node, BOOL *stop) {
        [((StarNode *)node) checkNodeRemoval:_player.position.y];
    }];
    
    // Calculate player y offset
    if (_player.position.y > 200.0f) {
        _backgroundNode.position = CGPointMake(0.0f, -((_player.position.y - 200.0f)/10));
        _midgroundNode.position = CGPointMake(0.0f, -((_player.position.y - 200.0f)/4));
        _foregroundNode.position = CGPointMake(0.0f, -(_player.position.y - 200.0f));
    }
    
    if (_player.position.y > _endLevelY) {
        [self levelComplete];
        return;
    }
    
    // fallen
    if (_player.position.y < (_maxPlayerHeight - 400)) {
        [self gameOver];
    }
    
    
}

- (void) didSimulatePhysics
{
    
    // Set velocity based on x-axis acceleration
    _player.physicsBody.velocity = CGVectorMake(_xAcceleration * 400.0f, _player.physicsBody.velocity.dy);
    
    // Check x bounds
    if (_player.position.x < -20.0f) {
        _player.position = CGPointMake(340.0f, _player.position.y);
    } else if (_player.position.x > 340.0f) {
        _player.position = CGPointMake(-20.0f, _player.position.y);
    }
    return;
}

- (void) gameOver
{
    //[_player removeActionForKey:@"blink"];
    [_player removeFromParent];
    _gameOver = YES;
    _level = 0;
    _currentScore = 0;
    // Save stars and high score
    [[SaveState savedInstance] saveState];
    
    SKScene *gameOver = [[GameOver alloc] initWithSize:self.size];
    SKTransition *reveal = [SKTransition fadeWithDuration:0.5];
    [self.view presentScene:gameOver transition:reveal];
}

- (void) levelComplete
{
    _gameOver = YES;
    _level++;
    
    _currentScore = [SaveState savedInstance].score;
    [[SaveState savedInstance] saveState];
    [SaveState savedInstance].score = _currentScore;
    SKScene *nextLevel = [[GameOver alloc] initWithSize:self.size];
    SKTransition *reveal = [SKTransition fadeWithDuration:0.5];
    [self.view presentScene:nextLevel transition:reveal];
    
}

@end
