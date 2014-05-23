//
//  StalkerTests.m
//  StalkerTests
//
//  Created by Luca Querella on 23/05/14.
//  Copyright (c) 2014 BendingSpoons. All rights reserved.
//

#define EXP_SHORTHAND
#import "Expecta.h"
#import "Specta.h"


SpecBegin(BPPictures)

it(@"should work", ^{
    expect(10).to.equal(10);
});

SpecEnd
