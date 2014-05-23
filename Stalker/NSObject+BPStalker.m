//
//  NSObject+BPStalker.m
//  Stalker
//
//  Created by Luca Querella on 23/05/14.
//  Copyright (c) 2014 BendingSpoons. All rights reserved.
//

#import "NSObject+BPStalker.h"
#import <objc/runtime.h>

@implementation NSObject (BPStalker)

-(BPStalker *)stalker
{
    id stalker =  objc_getAssociatedObject(self, @selector(stalker));
    if (!stalker) {
        stalker = [[BPStalker alloc] init];
        objc_setAssociatedObject(self, @selector(stalker), stalker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return stalker;
}

@end
