//
//  PlatformSprite.h
//  glump
//
//  Created by Brooke Costa on 4/10/13.
//  Copyright (c) 2013 Brooke Costa. All rights reserved.
//

#import "CCSprite.h"

@interface PlatformSprite : CCNode

+ (PlatformSprite *)platformWithTiles:(int)tiles;
- (PlatformSprite *)initWithTiles:(int)tiles;

@end
