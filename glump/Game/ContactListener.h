//
//  ContactListener.h
//  glump
//
//  Created by Brooke Costa on 4/8/13.
//  Copyright (c) 2013 Brooke Costa. All rights reserved.
//

#ifndef __glump__ContactListener__
#define __glump__ContactListener__

#include "Box2D.h"

class ContactListener : public b2ContactListener
{
public:
    void BeginContact(b2Contact* contact);
    void EndContact(b2Contact* contact)
    { /* handle end event */ }
    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
    void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse)
    { /* handle post-solve event */ }
};

#endif /* defined(__glump__ContactListener__) */
