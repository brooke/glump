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
        return;
    }

    b2EdgeAndCircleContact *groundContact = dynamic_cast<b2EdgeAndCircleContact *>(contact);
    if (groundContact) {
        ((BallFixtureUD *)contact->GetFixtureB()->GetUserData())->dead = true;
    }
}