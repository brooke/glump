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
    b2PolygonAndCircleContact *polyContact = dynamic_cast<b2PolygonAndCircleContact *>(contact);
    if (polyContact) {
        FixtureUserData *fixtureUD = (FixtureUserData *)contact->GetFixtureA()->GetUserData();
        if (fixtureUD->getFixtureType() == kPlatformFixture) {
            ((BallFixtureUD *)contact->GetFixtureB()->GetUserData())->jumpCount = 0;
        
            // detect the point of contact
            b2Manifold manifold;
            const b2Transform xfA = contact->GetFixtureA()->GetBody()->GetTransform();
            const b2Transform xfB = contact->GetFixtureB()->GetBody()->GetTransform();
            
            contact->Evaluate(&manifold, xfA, xfB);
            
            b2WorldManifold worldManifold;
            worldManifold.Initialize(&manifold, xfA, contact->GetFixtureA()->GetShape()->m_radius,
                                     xfB, contact->GetFixtureB()->GetShape()->m_radius);
            
            if (contact->GetFixtureA()->GetBody()->GetPosition().y + 1.45 >
                contact->GetFixtureB()->GetBody()->GetPosition().y) {
                ((BallFixtureUD *)contact->GetFixtureB()->GetUserData())->dead = true;
            }
            else {
                ((BallFixtureUD *)contact->GetFixtureB()->GetUserData())->walking = true;
            }
        }
        else if (fixtureUD->getFixtureType() == kItemFixture) {
            if (((ItemFixtureUD *)fixtureUD)->good) {
                contact->SetEnabled(false);
            }
            else {
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