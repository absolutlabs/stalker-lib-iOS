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
#import "NSObject+BPStalker.h"

SpecBegin(Stalker)

    describe(@"objectWithStalker", ^{

      __block NSMutableDictionary *objectToBeObserved;
      __block NSObject *objectWithStalker;
      __block NSString *testNotification;

      beforeEach(^{
        objectWithStalker = [[NSObject alloc] init];
        objectToBeObserved = [@{ @"one" : @1, @"two" : @2 } mutableCopy];
        testNotification = @"TEST_NOTIFICATION";

      });

      it(@"should have a stalker", ^{
        expect(objectWithStalker.stalker).toNot.beNil;
      });

      it(@"should be able to observer changes", ^{

        __block BOOL objectChanged = NO;
        __block NSInteger blockCalled = 0;

        [objectWithStalker.stalker whenPath:@"one"
                            changeForObject:objectToBeObserved
                                    options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew |
                                             NSKeyValueObservingOptionOld)
                                       then:^(NSMutableDictionary *object, NSDictionary *change) {

                                         expect(object[@"one"]).to.equal(@1);
                                         blockCalled++;
                                       }];

        [objectWithStalker.stalker whenPath:@"two"
                            changeForObject:objectToBeObserved
                                    options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew |
                                             NSKeyValueObservingOptionOld)
                                       then:^(NSMutableDictionary *object, NSDictionary *change) {

                                         blockCalled++;

                                         if (objectChanged)
                                             expect(object[@"two"]).to.equal(@3);
                                         else
                                             expect(object[@"two"]).to.equal(@2);

                                       }];

        objectChanged = YES;
        objectToBeObserved[@"two"] = @3;
        expect(blockCalled).to.equal(3);

      });

      it(@"s stalker KVO shoud be removed when it is deallocated", ^{

        __block NSInteger blockCalled = 0;

        @autoreleasepool
        {
            NSObject *objectWithStalker = [[NSObject alloc] init];

            [objectWithStalker.stalker whenPath:@"one"
                                changeForObject:objectToBeObserved
                                        options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew |
                                                 NSKeyValueObservingOptionOld)
                                           then:^(NSMutableDictionary *object, NSDictionary *change) {

                                             blockCalled++;
                                           }];

            expect(blockCalled).to.equal(1);

            objectToBeObserved[@"one"] = @3;
            expect(blockCalled).to.equal(2);
        }

        objectToBeObserved[@"one"] = @4;
        objectToBeObserved[@"one"] = @10;

        expect(blockCalled).to.equal(2);

      });

      it(@"should be able to listen to notifications", ^{

        __block NSInteger blockCalled = 0;

        [objectWithStalker.stalker when:testNotification
                                   then:^(NSNotification *notification) {
                                     expect(notification.object).to.equal(@1);
                                     blockCalled++;
                                   }];

        expect(blockCalled).to.equal(0);
        [objectWithStalker.stalker.notificationCenter postNotificationName:testNotification object:@1];
        expect(blockCalled).to.equal(1);

      });

      it(@"s stalker notification observing shoud be removed when it is deallocated", ^{

        __block NSInteger blockCalled = 0;

        @autoreleasepool
        {
            NSObject *objectWithStalker = [[NSObject alloc] init];

            [objectWithStalker.stalker when:testNotification
                                       then:^(NSNotification *notification) {
                                         blockCalled++;
                                       }];

            expect(blockCalled).to.equal(0);
            [objectWithStalker.stalker.notificationCenter postNotificationName:testNotification object:@1];
            expect(blockCalled).to.equal(1);
        }

        [objectWithStalker.stalker.notificationCenter postNotificationName:testNotification object:@1];

        expect(blockCalled).to.equal(1);

      });

    });

SpecEnd
