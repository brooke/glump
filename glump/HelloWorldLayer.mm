//
//  HelloWorldLayer.mm
//  glump
//
//  Created by Brooke Costa on 4/8/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import "HelloWorldLayer.h"
#import "PlatformSprite.h"
#import "Globals.h"
#import <stdlib.h>

@implementation HelloWorldLayer

+ (id)scene {
    
    CCScene *scene = [CCScene node];
    HelloWorldLayer *layer = [HelloWorldLayer node];
    [scene addChild:layer];
    return scene;
    
}

- (id)init {
    
    if ((self=[super init])) {
        [self setTouchEnabled:YES];
        screen = [CCDirector sharedDirector].winSize;
        
        // Create sprite and add it to the layer
//        m_jumpingTexture = [[CCTextureCache sharedTextureCache] addImage:@"ball_jumping.png"];
//        m_walkingTexture = [[CCTextureCache sharedTextureCache] addImage:@"ball_walking.png"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"prance.plist"];
        NSMutableArray *walkAnimFrames = [NSMutableArray array];
        for(int i = 0; i < 8; ++i) {
            [walkAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"prance_%d.png", i]]];
        }
        
        CCAnimation *prance = [CCAnimation animationWithSpriteFrames:walkAnimFrames delay:0.1f];
        [[CCAnimationCache sharedAnimationCache] addAnimation:prance name:@"prance"];
        CCAnimate *animate = [CCAnimate actionWithAnimation:prance restoreOriginalFrame:NO];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"roll.plist"];
        NSMutableArray *dieAnimFrames = [NSMutableArray array];
        for(int i = 0; i < 6; ++i) {
            [dieAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"roll_%d.png", i]]];
        }
        
        CCAnimation *roll = [CCAnimation animationWithSpriteFrames:dieAnimFrames delay:0.1f];
        [[CCAnimationCache sharedAnimationCache] addAnimation:roll name:@"roll"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"tumble.plist"];
        NSMutableArray *jumpAnimFrames = [NSMutableArray array];
        for(int i = 0; i < 8; ++i) {
            [jumpAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"tumble_%d.png", i]]];
        }
        
        CCAnimation *tumble = [CCAnimation animationWithSpriteFrames:jumpAnimFrames delay:0.1f];
        [[CCAnimationCache sharedAnimationCache] addAnimation:tumble name:@"tumble"];
        
        m_player = [CCSprite spriteWithSpriteFrameName:@"prance_0.png"];
        [m_player runAction:[CCRepeatForever actionWithAction:animate]];
        m_player.position = ccp(100, 100);
        m_player.scale = SPRITE_RATIO;
        [self addChild:m_player];
        
        m_itemsTexture = [[CCTextureCache sharedTextureCache] addImage:@"blocks.png"];
        
        // Create a world
        b2Vec2 gravity = b2Vec2(0.0f, -20.0f);
        m_world = new b2World(gravity);
        m_listener = new ContactListener();
        
        // Create ball body and shape
        b2BodyDef ballBodyDef;
        ballBodyDef.type = b2_dynamicBody;
        ballBodyDef.position.Set(100/PTM_RATIO, 100/PTM_RATIO);
        ballBodyDef.userData = m_player;
        ballBodyDef.linearDamping = 1.0;
        m_body = m_world->CreateBody(&ballBodyDef);
        
        //[self generatePlatforms];
        m_platformLength = 20;
        m_platform = [self addPlatformOfLength:m_platformLength withPosX:10 posY:1];
        
        // Create edges around the entire screen
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0,0);
        
        b2Body *groundBody = m_world->CreateBody(&groundBodyDef);
        b2EdgeShape groundEdge;
        b2FixtureDef boxShapeDef;
        
        jumping = false;
        boxShapeDef.shape = &groundEdge;
        
        //wall definitions
        groundEdge.Set(b2Vec2(0,0), b2Vec2(screen.width/PTM_RATIO, 0));
        groundBody->CreateFixture(&boxShapeDef);
        
        b2CircleShape circle;
        circle.m_radius = 1;
        
        m_ballUD = new BallFixtureUD();
        m_ballUD->jumpCount = 0;
        
        b2FixtureDef ballShapeDef;
        ballShapeDef.shape = &circle;
        ballShapeDef.density = 1.0f;
        ballShapeDef.friction = 0.0f;
        ballShapeDef.restitution = 0.0f;
        ballShapeDef.userData = m_ballUD;
        m_body->CreateFixture(&ballShapeDef);
        
        m_world->SetContactListener(m_listener);
        
        [self schedule:@selector(tick:)];
    }
    return self;
}

- (void)generatePlatforms {
    int platformLength = 20;
    int platformYPos = 1;
    int distanceToNext = 3;
    int platformXPos = 10;
    int good = 1;
    
    for (int i = 0; i < 20; i++) {
        int height = 3 + arc4random() % 3;
        int distance = 2 + arc4random() % (platformLength - 3);
        [self addPlatformOfLength:platformLength withPosX:platformXPos posY:platformYPos];
        [self addItemWithPosX:(platformXPos - platformLength/2 + distance)*2 posY:(platformYPos + height)*2 andGoodness:good];
        
        platformXPos = platformLength + platformXPos + distanceToNext;
        platformLength = (3 + (arc4random() % 4))*2;
        distanceToNext = (4 + (arc4random() % 2));
        platformYPos = 1 + (arc4random() % 3);
        good = arc4random() % 2;
    }
}

- (b2Body *)addPlatformOfLength:(int)platformLength withPosX:(int)platformXPos posY:(int)platformYPos {
    PlatformSprite *platform = [PlatformSprite platformWithTiles:platformLength];
    platform.position = ccp(platformXPos*PTM_RATIO, platformYPos*PTM_RATIO);
    [self addChild:platform];
    
    // Create ball body and shape
    b2BodyDef platformBodyDef;
    platformBodyDef.type = b2_kinematicBody;
    platformBodyDef.position.Set(platformXPos, platformYPos);
    platformBodyDef.userData = platform;
    b2Body *platformBody = m_world->CreateBody(&platformBodyDef);
    
    b2PolygonShape rectangle;
    rectangle.SetAsBox(platformLength/2, 0.5);
    
    PlatformFixtureUD *platformUD = new PlatformFixtureUD;
    
    b2FixtureDef platformShapeDef;
    platformShapeDef.shape = &rectangle;
    platformShapeDef.density = 1.0f;
    platformShapeDef.friction = 0.0f;
    platformShapeDef.restitution = 0.0f;
    platformShapeDef.userData = platformUD;
    platformBody->CreateFixture(&platformShapeDef);
    
    b2Vec2 force = b2Vec2(-8, 0);
    platformBody->SetLinearVelocity(force);
    return platformBody;
}

- (void)addItemWithPosX:(int)itemXPos posY:(int)itemYPos andGoodness:(int)good {
    CCSprite *itemSprite = [CCSprite spriteWithTexture:m_itemsTexture rect:CGRectMake(good*32, 32, 32, 32)];
    itemSprite.position = ccp(itemXPos*PTM_RATIO, itemYPos*PTM_RATIO);
    [self addChild:itemSprite];
    
    b2BodyDef itemBodyDef;
    itemBodyDef.type = b2_kinematicBody;
    itemBodyDef.position.Set(itemXPos, itemYPos);
    itemBodyDef.userData = itemSprite;
    b2Body *itemBody = m_world->CreateBody(&itemBodyDef);
    
    b2PolygonShape rectangle;
    rectangle.SetAsBox(0.5, 0.5);
    
    ItemFixtureUD *itemUD = new ItemFixtureUD;
    itemUD->good = good;
    
    b2FixtureDef itemShapeDef;
    itemShapeDef.shape = &rectangle;
    itemShapeDef.density = 1.0;
    itemShapeDef.friction = 0.0f;
    itemShapeDef.restitution = 0.0f;
    itemShapeDef.userData = itemUD;
    itemBody->CreateFixture(&itemShapeDef);
    
    b2Vec2 force = b2Vec2(-8, 0);
    itemBody->SetLinearVelocity(force);
}

- (void)jump {
    if (m_ballUD->jumpCount < 2) {
        [m_player stopAllActions];
        [self unschedule:@selector(bounce)];
//        b2Vec2 force = b2Vec2(0, 8);
//        m_body->SetLinearVelocity(force);
        m_ballUD->jumpCount++;
        jumping = true;
        [self scheduleOnce:@selector(endJump) delay:0.3f];
        
        CCAnimation *tumble = [[CCAnimationCache sharedAnimationCache] animationByName:@"tumble"];
        CCRepeatForever *jump = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:tumble]];
        [m_player runAction:jump];
        walkAcknowledged = false;
        m_ballUD->walking = false;
    }
}

- (void)endJump {
    jumping = false;
}

- (void)walk {
    [m_player stopAllActions];
    CCAnimation *prance = [[CCAnimationCache sharedAnimationCache] animationByName:@"prance"];
    CCRepeatForever *walk = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:prance]];
    [m_player runAction:walk];

}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self jump];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endJump];
}

- (void)deleteBody:(b2Body *)body {
    [((CCNode *)body->GetUserData()) removeFromParentAndCleanup:YES];
    for (b2Fixture *f=body->GetFixtureList(); f; f=f->GetNext()) {
        delete f->GetUserData();
    }
    m_world->DestroyBody(body);
}

- (void)restart {
    b2Body *b = m_world->GetBodyList();
    while (b) {
        b2Body *bn = b->GetNext();
        if (b != m_body) {
            [self deleteBody:b];
        }
        b = bn;
    }
    [m_player removeAllChildrenWithCleanup:YES];
    [m_player setVisible:YES];
    [m_player setOpacity:255];
    
    [m_player stopAllActions];
    CCAnimation *prance = [[CCAnimationCache sharedAnimationCache] animationByName:@"prance"];
    CCRepeatForever *walk = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:prance]];
    [m_player runAction:walk];
    
    // Create edges around the entire screen
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0,0);
    
    b2Body *groundBody = m_world->CreateBody(&groundBodyDef);
    b2EdgeShape groundEdge;
    b2FixtureDef boxShapeDef;
    
    jumping = false;
    m_ballUD->jumpCount = 0;
    m_ballUD->dead = false;
    boxShapeDef.shape = &groundEdge;
    
    //wall definitions
    groundEdge.Set(b2Vec2(0,0), b2Vec2(screen.width/PTM_RATIO, 0));
    groundBody->CreateFixture(&boxShapeDef);
    
    m_body->SetTransform(b2Vec2(100/PTM_RATIO, 300/PTM_RATIO), 0.0f);
    //[self generatePlatforms];
    m_platformLength = 20;
    m_platform = [self addPlatformOfLength:m_platformLength withPosX:10 posY:1];
    [self schedule:@selector(tick:)];
}

- (void)die {
    [m_player removeAllChildren];
    m_body->SetLinearVelocity(b2Vec2(0, 0));
    CCSprite *explosionSprite = [CCSprite spriteWithFile:@"Flare.png"];
    explosionSprite.scale = 0.1f;
    CGSize ballSize = [m_player contentSize];
    explosionSprite.position = ccp(ballSize.width/2,ballSize.height/2);
    [m_player addChild:explosionSprite];
    CCScaleTo *scaleFlare = [CCScaleTo actionWithDuration:0.3f scale:1.0f];
    CCFadeOut *fadeFlare = [CCFadeOut actionWithDuration:0.05f];
    CCSequence *explosionSequence = [CCSequence actionOne:scaleFlare two:fadeFlare];
    [explosionSprite runAction:explosionSequence];
    [m_player stopAllActions];
    CCAnimation *roll = [[CCAnimationCache sharedAnimationCache] animationByName:@"roll"];
    CCRepeatForever *die = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:roll]];
    [m_player runAction:die];
    [self scheduleOnce:@selector(restart) delay:1.0];
}

- (void)tick:(ccTime) dt {
    if (jumping) {
        b2Vec2 force = b2Vec2(0, 8);
        m_body->SetLinearVelocity(force);
    }
    if (!walkAcknowledged && m_ballUD->walking) {
        walkAcknowledged = true;
        [self walk];
    }
    
    if (m_body->GetLinearVelocity().x < 0) {
        float y = m_body->GetLinearVelocity().y;
        m_body->SetLinearVelocity(b2Vec2(0,y));
    }

    m_world->Step(dt, 10, 10);
    
    // can't iterate with for loop - body may be deleted
    b2Body *b = m_world->GetBodyList();
    while (b) {
        b2Body *bn = b->GetNext();
        if (b->GetUserData() != NULL) {
            CCNode *spriteData = (CCNode *)b->GetUserData();
            spriteData.position = ccp(b->GetPosition().x * PTM_RATIO,
                                      b->GetPosition().y * PTM_RATIO);
            if (b->GetPosition().x + m_platformLength < 0) {
                [self deleteBody:b];
            }
        }
        b=bn;
    }
    
    if (m_platform->GetPosition().x + m_platformLength/2 < screen.width/PTM_RATIO + 1) {
        NSLog(@"posX: %f platLength: %d screenWidth: %f", m_platform->GetPosition().x, m_platformLength, screen.width);
        m_platformLength = (3 + arc4random() % 4)*2;
        int posX = screen.width/PTM_RATIO + m_platformLength/2 + 3 + arc4random()%4;
        m_platform = [self addPlatformOfLength:m_platformLength withPosX:posX posY:1 + arc4random()%3];
    }
    
    if (((BallFixtureUD *)m_body->GetFixtureList()->GetUserData())->dead) {
        [self die];
        ((BallFixtureUD *)m_body->GetFixtureList()->GetUserData())->dead = false;
        [self unschedule:@selector(tick:)];
    }
}

- (void)dealloc {
    delete m_world;
    delete m_listener;
    delete m_ballUD;
    m_body = NULL;
    m_world = NULL;
    m_listener = NULL;
    m_ballUD = NULL;
    
    [super dealloc];
}

@end