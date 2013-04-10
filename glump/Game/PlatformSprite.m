//
//  PlatformSprite.m
//  glump
//
//  Created by Brooke Costa on 4/10/13.
//  Copyright (c) 2013 Brooke Costa. All rights reserved.
//

#import "PlatformSprite.h"

@implementation PlatformSprite

+ (PlatformSprite *)platformWithTiles:(int)tiles {
    PlatformSprite *platform = [[[PlatformSprite alloc] initWithTiles:tiles] autorelease];
    return platform;
}

- (PlatformSprite *)initWithTiles:(int)tiles {
    self = [super init];
    if (self && tiles > 0) {
        CCSprite *firstSprite = [CCSprite spriteWithFile:@"platformLeft.png"];
        firstSprite.position = CGPointMake(64.0f*(0.0f - (float)tiles / 2.0f), 0.0f);
        firstSprite.anchorPoint = CGPointMake(0.0f, 0.5f);
        [self addChild:firstSprite];
        for (int i=1; i < tiles-1; i++) {
            CCSprite *midSprite = [CCSprite spriteWithFile:(i%2==1 ? @"platformCenter1.png" : @"platformCenter2.png")];
            midSprite.position = CGPointMake(64.0f*((float)i - (float)tiles / 2.0f), 0.0f);
            midSprite.anchorPoint = CGPointMake(0.0f, 0.5f);
            [self addChild:midSprite];
        }
        CCSprite *lastSprite = [CCSprite spriteWithFile:@"platformRight.png"];
        lastSprite.position = CGPointMake(64.0f*((float)(tiles-1) - (float)tiles / 2.0f), 0.0f);
        lastSprite.anchorPoint = CGPointMake(0.0f, 0.5f);
        [self addChild:lastSprite];
    }
    return self;
}

@end
