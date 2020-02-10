//
//  ControlSprite.m
//  SpaceShooter
//
//  Created by Andrew on 12/4/13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "ControlSprite.h"

@implementation ControlSprite

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.delegate controlSpriteTouchDown:self];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   [self.delegate controlSpriteTouchUp:self];
}

@end
