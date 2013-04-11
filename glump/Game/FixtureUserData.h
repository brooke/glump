//
//  FixtureUserData.h
//  glump
//
//  Created by Brooke Costa on 4/10/13.
//  Copyright (c) 2013 Brooke Costa. All rights reserved.
//

#ifndef __glump__FixtureUserData__
#define __glump__FixtureUserData__

enum FixtureType {
    kBallFixture,
    kPlatformFixture,
    kItemFixture
};

struct FixtureUserData {
    virtual FixtureType getFixtureType() = 0;
};

struct BallFixtureUD : public FixtureUserData {
    int jumpCount;
    bool walking;
    bool dead;
    virtual FixtureType getFixtureType() { return kBallFixture; };
};

struct PlatformFixtureUD {
    virtual FixtureType getFixtureType() { return kPlatformFixture; };
};

struct ItemFixtureUD {
    int good;
    virtual FixtureType getFixtureType() { return kItemFixture; };
};


#endif 