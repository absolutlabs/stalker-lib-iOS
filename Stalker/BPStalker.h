//
//  BPStalker.h
//  Stalker
//
//  Created by Luca Querella on 23/05/14.
//  Copyright (c) 2014 BendingSpoons. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^BPStalkerKVONotificationBlock)(id object, NSDictionary *change);
typedef void (^BPStalkerNotificationBlock)(NSNotification *notification);

@interface BPStalker : NSObject
@property (nonatomic, strong) NSNotificationCenter* notificationCenter;

-(void)whenPath:(NSString*)path
changeForObject:(id)object
        options:(NSKeyValueObservingOptions)options
  dispatchQueue:(dispatch_queue_t)dispatchQueue
           then:(BPStalkerKVONotificationBlock)block;

-(void)whenPath:(NSString*)path
changeForObject:(id)object
        options:(NSKeyValueObservingOptions)options
           then:(BPStalkerKVONotificationBlock)block;

-(void)when:(NSString*)notification then:(BPStalkerNotificationBlock)block;

@end
