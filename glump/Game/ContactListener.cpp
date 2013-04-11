//
//  ContactListener.cpp
//  glump
//
//  Created by Brooke Costa on 4/8/13.
//  Copyright (c) 2013 Brooke Costa. All rights reserved.
//

#include "ContactListener.h"
#include "b2PolygonAndCircleContact.h"
#include "b2EdgeAndCircleContact.h"
#include "FixtureUserData.h"

void ContactListener::BeginContact(b2Contact *contact) {
    b2PolygonAndCircleContact *platformContact = dynamic_cast<b2PolygonAndCircleContact *>(contact);
    if (platformContact) {
        ((BallFixtureUD *)contact->GetFixtureB()->GetUserData())->jumpCount = 0;
        
        // detect the point of contact
        b2Manifold manifold;
        const b2Transform xfA = contact->GetFixtureA()->GetBody()->GetTransform();
        const b2Transform xfB = contact->GetFixtureB()->GetBody()->GetTransform();
        
        contact->Evaluate(&manifold, xfA, xfB);
        
        b2WorldManifold worldManifold;
        worldManifold.Initialize(&manifold, xfA, contact->GetFixtureA()->GetShape()->m_radius,
                                 xfB, contact->GetFixtureB()->GetShape()->m_radius);
        
        if (manifold.pointCount > 0) {
            b2Vec2 contactPoint = worldManifold.points[0];
            
            if (contactPoint.x > contact->GetFixtureB()->GetBody()->GetPosition().x) {
                ((BallFixtureUD *)contact->GetFixtureB()->GetUserData())->dead = true;
                
            }
        }
        
        return;
    }

    b2EdgeAndCircleContact *groundContact = dynamic_cast<b2EdgeAndCircleContact *>(contact);
    if (groundContact) {
        ((BallFixtureUD *)contact->GetFixtureB()->GetUserData())->dead = true;
    }
}

void ContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
    
}