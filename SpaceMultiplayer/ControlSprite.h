//
//  ControlSprite.h
//  SpaceShooter
//
//  Created by Andrew on 12/4/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#define ControlSpriteTypeLeft 1
#define ControlSpriteTypeRight 2

@protocol ControlSpriteDelegate
- (void) controlSpriteTouchDown:(id)sender;
- (void) controlSpriteTouchUp:(id)sender;
@end

@interface ControlSprite : SKSpriteNode

@property (nonatomic, assign) id <ControlSpriteDelegate> delegate;
@property (nonatomic) NSInteger controlButtonType;

@end
