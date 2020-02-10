//
//  MyScene.m
//  SpaceMultiplayer
//
//  Created by Andrew Finke on 6/26/14.
//  Copyright (c) 2014 ATFinke Productions. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene {
    ControlSprite *currentControlSprite;
    ControlSprite *leftControl;
    ControlSprite *rightControl;
    
    SKEmitterNode *jetFire;
    
    NSMutableArray *currentBullets;
    NSMutableArray *currentMeteors;
    
    SKLabelNode *currentScoreLabel;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        [self configureScene];
        [self loadPlayer];
        [self loadControls];
        [self loadParticles];
        [self loadScoreLabel];
    }
    return self;
}

- (void) configureScene {
    self.backgroundColor = [UIColor blackColor];
    self.canFireBullet = YES;
    
    currentBullets = [NSMutableArray array];
    currentMeteors = [NSMutableArray array];
   
    [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(spawnNewMeteor) userInfo:nil repeats:YES];
}

- (void) loadPlayer {
    _localPlayer = [[SKSpriteNode alloc]initWithImageNamed:@"Local Player"];
    _localPlayer.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame) + 100);
    [self addChild:_localPlayer];
}

- (void) loadScoreLabel {
    currentScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"SquareFont"];
    
    currentScoreLabel.text = @"0000";
    currentScoreLabel.fontSize = 50;
    currentScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame) + 22.5);
    
    [self addChild:currentScoreLabel];
}

- (void) loadParticles {
    
    SKEmitterNode * stars = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"SpaceSquareStars" ofType:@"sks"]];
    stars.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame));
    [self addChild:stars];
    
    jetFire = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"JetEngine" ofType:@"sks"]];
    jetFire.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame) + 80);
    jetFire.particlePosition = CGPointMake(0,0);
    
    [self addChild:jetFire];
}

- (void) loadControls {
    leftControl = [[ControlSprite alloc]initWithImageNamed:@"Left Control"];
    [self configureControlSprite:leftControl];
    leftControl.position = CGPointMake(40,40);
    leftControl.controlButtonType = ControlSpriteTypeLeft;
    [self addChild:leftControl];
    
    rightControl = [[ControlSprite alloc]initWithImageNamed:@"Right Control"];
    [self configureControlSprite:rightControl];
    rightControl.position = CGPointMake(CGRectGetMaxX(self.frame)-40,40);
    rightControl.controlButtonType = ControlSpriteTypeRight;
    [self addChild:rightControl];
}

- (void) configureControlSprite:(ControlSprite*)sprite {
    sprite.xScale = .5;
    sprite.yScale = .5;
    sprite.delegate = self;
    sprite.userInteractionEnabled = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    self.isUserTouchingDown = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.isUserTouchingDown = NO;
}

- (void) controlSpriteTouchDown:(id)sender {
    self.isUserTouchingButton = YES;
    currentControlSprite = sender;
}

- (void) controlSpriteTouchUp:(id)sender {
    self.isUserTouchingButton = NO;
}

- (void)update:(CFTimeInterval)currentTime {
    if (self.isUserTouchingDown && self.canFireBullet) {
        SKSpriteNode *bullet = [[SKSpriteNode alloc]initWithImageNamed:@"Square Bullet"];
        bullet.position = CGPointMake(_localPlayer.position.x, _localPlayer.position.y + 40);
        [self addChild:bullet];
        [currentBullets addObject:bullet];
        [bullet runAction:[SKAction sequence:@[[SKAction moveByX:0 y:600 duration:1]]] completion:^{
            [currentBullets removeObject:bullet];
            [bullet removeFromParent];
        }];
        
        self.canFireBullet = NO;
        [NSTimer scheduledTimerWithTimeInterval:.05 target:self selector:@selector(resetReloadTime) userInfo:nil repeats:NO];
    }
    
    if (self.isUserTouchingButton) {
        if (currentControlSprite.controlButtonType == ControlSpriteTypeLeft) {
            if (self.localPlayer.position.x > 45) {
                self.localPlayer.position = CGPointMake(self.localPlayer.position.x-5, self.localPlayer.position.y);
            }
            
        }
        else if (currentControlSprite.controlButtonType == ControlSpriteTypeRight) {
            if (self.localPlayer.position.x < 275) {
                self.localPlayer.position = CGPointMake(self.localPlayer.position.x+5, self.localPlayer.position.y);
            }
        }
        jetFire.particlePosition = CGPointMake(self.localPlayer.position.x-160,0);
    }
    
    NSMutableArray *bulletsToRemove = [NSMutableArray array];
    NSMutableArray *meteorsToRemove = [NSMutableArray array];
    
    for (EnemyNode *meteor in currentMeteors) {
        for (SKSpriteNode *bullet in currentBullets) {
            if (CGRectIntersectsRect(meteor.frame, bullet.frame)) {
                meteor.livesLeft--;
                if (meteor.livesLeft == 0) {
                    [meteorsToRemove addObject:meteor];
                    self.currentScore = self.currentScore + 5;
                }
                else {
                    self.currentScore ++;
                    SKEmitterNode * explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"CollisionExplosion" ofType:@"sks"]];
                    explosion.position = bullet.position;
                    
                    [self addChild:explosion];
                }
                [bulletsToRemove addObject:bullet];
                [self updateCurrentScoreLabel];
            }
        }
        if (CGRectIntersectsRect(meteor.frame, self.localPlayer.frame))  {
            [meteorsToRemove addObject:meteor];
            [self playerLostActions];
        }
        
        if (meteor.frame.origin.y < 80) {
            [meteorsToRemove addObject:meteor];
            [self playerLostActions];
        }
    }
    
    for (SKSpriteNode *meteor in meteorsToRemove) {
        SKEmitterNode * explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"MeteorExplosion" ofType:@"sks"]];
        explosion.position = meteor.position;
        [self addChild:explosion];
        
        [meteor removeFromParent];
        [currentMeteors removeObject:meteor];
    }
    
    for (SKSpriteNode *bullet in bulletsToRemove) {
        [bullet removeFromParent];
        [currentBullets removeObject:bullet];
    }
}

- (void)fadeHUD {
    [leftControl runAction:[SKAction fadeOutWithDuration:3]];
    [rightControl runAction:[SKAction fadeOutWithDuration:3]];
    [currentScoreLabel runAction:[SKAction fadeOutWithDuration:3]];
    
    [self runAction:[SKAction fadeOutWithDuration:4] completion:^{
        NSMutableDictionary *dict = [@{@"Score": [NSNumber numberWithInteger:self.currentScore]} mutableCopy];
        [self.delegate gameOverWithAttributes:dict];
    }];
    
    leftControl.userInteractionEnabled = NO;
    rightControl.userInteractionEnabled = NO;
    
    self.userInteractionEnabled = NO;
    
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(removeMeteor) userInfo:nil repeats:YES];
}

- (void) playerLostActions {
    [self.localPlayer removeFromParent];
    
    SKEmitterNode * explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"PlayerExplosion" ofType:@"sks"]];
    explosion.position = self.localPlayer.position;
    
    [self addChild:explosion];
    
    jetFire.numParticlesToEmit = 5;
    [self fadeHUD];
}

- (void) removeMeteor {
    if (currentMeteors.count != 0) {
        SKSpriteNode *meteor = currentMeteors[0];
        
        SKEmitterNode * explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"MeteorExplosion" ofType:@"sks"]];
        explosion.position = meteor.position;
        
        [self addChild:explosion];
        
        
        [meteor removeFromParent];
        [currentMeteors removeObject:meteor];
    }
}

- (void)updateCurrentScoreLabel {
    if (self.currentScore >= 1000) {
        currentScoreLabel.text = [NSString stringWithFormat:@"%li",(long)self.currentScore];
    }
    else if (self.currentScore >= 100) {
        currentScoreLabel.text = [NSString stringWithFormat:@"0%li",(long)self.currentScore];
    }
    else if (self.currentScore >= 10) {
        currentScoreLabel.text = [NSString stringWithFormat:@"00%li",(long)self.currentScore];
    }
    else {
        currentScoreLabel.text = [NSString stringWithFormat:@"000%li",(long)self.currentScore];
    }
}

- (void) resetReloadTime {
    self.canFireBullet = YES;
}

- (void)spawnNewMeteor {
    
    EnemyNode *meteor = [[EnemyNode alloc]initWithImageNamed:@"Meteorite"];
    
    NSInteger randomNumber = arc4random() % 130;
    if (arc4random() % 2 == 0) {
        randomNumber = -randomNumber;
    }
    
    meteor.livesLeft = 3;
    meteor.position = CGPointMake(CGRectGetMidX(self.frame)+randomNumber, CGRectGetMaxY(self.frame) + 100);
    [currentMeteors addObject:meteor];
    
    [meteor runAction:[SKAction moveByX:0 y:-1000 duration:15] completion:^{
        [currentMeteors removeObject:meteor];
        [meteor removeFromParent];
    }];
    
    [self addChild:meteor];
}

@end
