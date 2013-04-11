//
//  HelloWorldLayer.h
//  glump
//
//  Created by Brooke Costa on 4/8/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import "cocos2d.h"
#import "Box2D.h"
#import "ContactListener.h"
#import "FixtureUserData.h"

@interface HelloWorldLayer : CCLayer {
    
    b2World *m_world;
    b2Body *m_body;
    CCSprite *m_player;
    NSMutableArray *m_platforms;
    NSMutableArray *m_targets;
    ContactListener *m_listener;
    
    CCTexture2D *m_itemsTexture;
    CCTexture2D *m_walkingTexture;
    CCTexture2D *m_jumpingTexture;

    BallFixtureUD *m_ballUD;
    bool walkAcknowledged;
    bool jumping;
}

+ (id) scene;

@end