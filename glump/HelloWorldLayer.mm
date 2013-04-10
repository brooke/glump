//
//  HelloWorldLayer.mm
//  glump
//
//  Created by Brooke Costa on 4/8/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import "HelloWorldLayer.h"
#import "PlatformSprite.h"
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
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        // Create sprite and add it to the layer
        m_player = [CCSprite spriteWithFile:@"ball.png" rect:CGRectMake(0, 0, 52, 52)];
        m_player.position = ccp(100, 300);
        [self addChild:m_player];
        
        // Create a world
        b2Vec2 gravity = b2Vec2(0.0f, -50.0f);
        m_world = new b2World(gravity);
        m_listener = new ContactListener();
        
        // Create ball body and shape
        b2BodyDef ballBodyDef;
        ballBodyDef.type = b2_dynamicBody;
        ballBodyDef.position.Set(100/PTM_RATIO, 300/PTM_RATIO);
        ballBodyDef.userData = m_player;
        ballBodyDef.linearDamping = 1.0;
        m_body = m_world->CreateBody(&ballBodyDef);
        
        [self generatePlatforms];
        
        // Create edges around the entire screen
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0,0);
        
        b2Body *groundBody = m_world->CreateBody(&groundBodyDef);
        b2EdgeShape groundEdge;
        b2FixtureDef boxShapeDef;
        
        jumpCount[0] = 0;
        jumping = false;
        boxShapeDef.shape = &groundEdge;
        
        //wall definitions
        groundEdge.Set(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO, 0));
        groundBody->CreateFixture(&boxShapeDef);
        
        b2CircleShape circle;
        circle.m_radius = 26.0/PTM_RATIO;
        
        b2FixtureDef ballShapeDef;
        ballShapeDef.shape = &circle;
        ballShapeDef.density = 1.0f;
        ballShapeDef.friction = 0.0f;
        ballShapeDef.restitution = 0.0f;
        ballShapeDef.userData = jumpCount;
        m_body->CreateFixture(&ballShapeDef);
        
        m_world->SetContactListener(m_listener);
        
        [self schedule:@selector(tick:)];
    }
    return self;
}

- (void)generatePlatforms {
    int platformLength = 20;
    int platformYPos = 1;
    int distanceToNext = 5;
    int platformXPos = 10;
    
    for (int i = 0; i < 20; i++) {
        PlatformSprite *platform = [PlatformSprite platformWithTiles:platformLength];
        platform.position = ccp(platformXPos*PTM_RATIO*2, platformYPos*PTM_RATIO*2);
        [self addChild:platform];
        
        // Create ball body and shape
        b2BodyDef platformBodyDef;
        platformBodyDef.type = b2_kinematicBody;
        platformBodyDef.position.Set(platformXPos*2, platformYPos*2);
        platformBodyDef.userData = platform;
        b2Body *platformBody = m_world->CreateBody(&platformBodyDef);
        
        b2PolygonShape rectangle;
        rectangle.SetAsBox(platformLength, 1);
        
        b2FixtureDef platformShapeDef;
        platformShapeDef.shape = &rectangle;
        platformShapeDef.density = 1.0f;
        platformShapeDef.friction = 0.0f;
        platformShapeDef.restitution = 0.0f;
        platformBody->CreateFixture(&platformShapeDef);
        
        b2Vec2 force = b2Vec2(-15, 0);
        platformBody->SetLinearVelocity(force);
        
        platformXPos = platformLength + platformXPos + distanceToNext;
        platformLength = (3 + (arc4random() % 4))*2;
        distanceToNext = (4 + (arc4random() % 2));
        platformYPos = 1 + (arc4random() % 3);
    }
}

- (void)jump {
    if (jumpCount[0] < 2) {
        b2Vec2 force = b2Vec2(0, 15);
        m_body->SetLinearVelocity(force);
        jumpCount[0]++;
        jumping = true;
        [self scheduleOnce:@selector(endJump) delay:0.3f];
    }
}

- (void)endJump {
    jumping = false;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self jump];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endJump];
}

- (void)tick:(ccTime) dt {
    if (jumping) {
        b2Vec2 force = b2Vec2(0, 15);
        m_body->SetLinearVelocity(force);
    }
    
    m_world->Step(dt, 10, 10);
    for(b2Body *b = m_world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCNode *spriteData = (CCNode *)b->GetUserData();
            spriteData.position = ccp(b->GetPosition().x * PTM_RATIO,
                                      b->GetPosition().y * PTM_RATIO);
        }
    }
    
}

- (void)dealloc {
    delete m_world;
    delete m_listener;
    m_body = NULL;
    m_world = NULL;
    m_listener = NULL;
    
    [super dealloc];
}

@end