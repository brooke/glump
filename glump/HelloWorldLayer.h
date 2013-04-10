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

#define PTM_RATIO 32.0

@interface HelloWorldLayer : CCLayer {
    
    b2World *m_world;
    b2Body *m_body;
    CCSprite *m_player;
    NSMutableArray *m_platforms;
    NSMutableArray *m_targets;
    ContactListener *m_listener;
    
    CCTexture2D *m_itemsTexture;

    BallFixtureUD *m_ballUD;
    bool jumping;
}

+ (id) scene;

@end