//
//  ContactListener.cpp
//  glump
//
//  Created by Brooke Costa on 4/8/13.
//  Copyright (c) 2013 Brooke Costa. All rights reserved.
//

#include "ContactListener.h"

void ContactListener::BeginContact(b2Contact *contact) {
    if (contact->GetFixtureA()->GetUserData() != NULL) {
        ((int *)contact->GetFixtureA()->GetUserData())[0] = 0;
    }
    else if (contact->GetFixtureB()->GetUserData() != NULL) {
        ((int *)contact->GetFixtureB()->GetUserData())[0] = 0;
    }
}