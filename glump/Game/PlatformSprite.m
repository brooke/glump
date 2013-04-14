//
//  PlatformSprite.m
//  glump
//
//  Created by Brooke Costa on 4/10/13.
//  Copyright (c) 2013 Brooke Costa. All rights reserved.
//

#import "PlatformSprite.h"
#import "Globals.h"

@implementation PlatformSprite

+ (PlatformSprite *)platformWithTiles:(int)tiles {
    PlatformSprite *platform = [[[PlatformSprite alloc] initWithTiles:tiles] autorelease];
    return platform;
}

- (PlatformSprite *)initWithTiles:(int)tiles {
    self = [super init];
    float posX = 0-(tiles * PTM_RATIO)/2;
    if (self && tiles > 0) {
        CCSprite *firstSprite = [CCSprite spriteWithFile:@"platformLeft.png"];
        firstSprite.scale = SPRITE_RATIO;
        firstSprite.position = CGPointMake(posX, 0.0f);
        firstSprite.anchorPoint = CGPointMake(0.0f, 0.5f);
        posX += PTM_RATIO;
        [self addChild:firstSprite];
        for (int i=1; i < tiles-1; i++) {
            CCSprite *midSprite = [CCSprite spriteWithFile:(i%2==1 ? @"platformCenter1.png" : @"platformCenter2.png")];
            midSprite.scale = SPRITE_RATIO;
            midSprite.position = CGPointMake(posX, 0.0f);
            midSprite.anchorPoint = CGPointMake(0.0f, 0.5f);
            posX += PTM_RATIO;
            [self addChild:midSprite];
        }
        CCSprite *lastSprite = [CCSprite spriteWithFile:@"platformRight.png"];
        lastSprite.scale = SPRITE_RATIO;
        lastSprite.position = CGPointMake(posX, 0.0f);
        lastSprite.anchorPoint = CGPointMake(0.0f, 0.5f);
        [self addChild:lastSprite];
    }
    return self;
}

@end
