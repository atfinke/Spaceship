//
//  MyScene.h
//  SpaceMultiplayer
//

//  Copyright (c) 2014 ATFinke Productions. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ControlSprite.h"
#import "EnemyNode.h"

@protocol SceneDelegate
- (void) gameOverWithAttributes:(NSMutableDictionary*)dictionary;
@end

@interface GameScene : SKScene <ControlSpriteDelegate>

@property (nonatomic, strong) SKSpriteNode *localPlayer;
@property (nonatomic) BOOL isUserTouchingDown;
@property (nonatomic) BOOL isUserTouchingButton;
@property (nonatomic) BOOL canFireBullet;

@property (nonatomic) NSInteger currentScore;

@property (nonatomic, assign) id <SceneDelegate> delegate;

@end
