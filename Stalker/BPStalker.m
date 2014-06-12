//
//  BPStalker.m
//  Stalker
//
//  Created by Luca Querella on 23/05/14.
//  Copyright (c) 2014 BendingSpoons. All rights reserved.
//

#import "BPStalker.h"
#import <libkern/OSAtomic.h>
#import <objc/message.h>

#pragma mark - BPKVOStalking


@interface BPKVOStalking : NSObject
@property (nonatomic, weak) BPStalker *stalker;
@property (nonatomic) NSString *keyPath;
@property (nonatomic) NSKeyValueObservingOptions options;
@property (nonatomic,strong) BPStalkerKVONotificationBlock block;
@end

@implementation  BPKVOStalking
- (instancetype)initWithStalker:(BPStalker *)stalker
                        keyPath:(NSString *)keyPath
                        options:(NSKeyValueObservingOptions)options
                          block:(BPStalkerKVONotificationBlock)block
{
    self = [super init];
    if (self) {
        self.stalker = stalker;
        self.keyPath = [keyPath copy];
        self.options = options;
        self.block = [block copy];
    }
    
    return self;
}

-(NSUInteger)hash
{
    return [self.keyPath hash];
}

- (BOOL)isEqual:(id)object
{
    if (!object)
        return NO;
    
    if (self == object)
        return YES;
    
    
    if (![object isKindOfClass:[self class]])
        return NO;
    
    return [self.keyPath isEqualToString:((BPKVOStalking *)object).keyPath];
}

@end

#pragma mark - BPSharedStalker

@interface BPSharedStalker : NSObject
@property (nonatomic,strong) NSHashTable *KVOStalkers;
@property (nonatomic) OSSpinLock lock;
@end

@implementation BPSharedStalker
+ (instancetype)sharedStalker
{
    static BPSharedStalker *sharedStalker;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStalker = [[BPSharedStalker alloc] init];
    });
    return sharedStalker;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.KVOStalkers = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
        self.lock = OS_SPINLOCK_INIT;
    }
    return self;
}

- (void)observeKVO:(id)object info:(BPKVOStalking *)info
{
    if (!object)
        return;
    
    OSSpinLockLock(&_lock);
    [self.KVOStalkers addObject:info];
    OSSpinLockUnlock(&_lock);
    
    [object addObserver:self forKeyPath:info.keyPath options:info.options context:(void*)info];
}

- (void)unobserveKVO:(id)object info:(BPKVOStalking *)info
{
    if (!object)
        return;
    
    OSSpinLockLock(&_lock);
    [self.KVOStalkers removeObject:info];
    OSSpinLockUnlock(&_lock);
    
    [object removeObserver:self forKeyPath:info.keyPath context:(void *)info];
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    
    BPKVOStalking *KVOStalking;
    {
        OSSpinLockLock(&_lock);
        KVOStalking = [self.KVOStalkers member:(__bridge id)context];
        OSSpinLockUnlock(&_lock);
    }

    BPStalker *stalker = KVOStalking.stalker;

    if (stalker && KVOStalking.block)
        KVOStalking.block(object, change);
}

@end

#pragma mark - BPStalker


@interface BPStalker ()
@property (atomic, weak) id target;
@property (nonatomic,strong) NSMapTable *KVOStalkingsMap;
@property (nonatomic) OSSpinLock lock;
@end

@implementation BPStalker

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.notificationCenter = [NSNotificationCenter defaultCenter];
        
        NSPointerFunctionsOptions keyOptions = NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPointerPersonality;
        self.KVOStalkingsMap = [[NSMapTable alloc] initWithKeyOptions:keyOptions valueOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality capacity:0];
        self.lock = OS_SPINLOCK_INIT;
    }
    return self;
}


-(void)whenPath:(NSString*)path changeForObject:(id)object options:(NSKeyValueObservingOptions)options then:(BPStalkerKVONotificationBlock)block
{

    NSParameterAssert(path.hash);
    NSParameterAssert(block);
    NSParameterAssert(object);
    
    BPKVOStalking *stalking = [[BPKVOStalking alloc] initWithStalker:self keyPath:path options:options block:block];
    OSSpinLockLock(&_lock);
    
    NSMutableSet *stalkingsForObject = [self.KVOStalkingsMap objectForKey:object];
    if (!stalkingsForObject) {
        stalkingsForObject = [NSMutableSet set];
        [self.KVOStalkingsMap setObject:stalkingsForObject forKey:object];
    }
    
    NSAssert(![stalkingsForObject member:stalking], @"observation already exists");
    
    [stalkingsForObject addObject:stalking];
    OSSpinLockUnlock(&_lock);

    [[BPSharedStalker sharedStalker] observeKVO:object info:stalking];
    
}

-(void)when:(NSString*)notification then:(BPStalkerNotificationBlock)block
{
    NSParameterAssert(notification);
    NSParameterAssert(block);

    [self.notificationCenter addObserverForName:notification object:nil queue:[NSOperationQueue mainQueue] usingBlock:block];
}

-(void)unobserveAll
{
    [self.notificationCenter removeObserver:self];
    
    OSSpinLockLock(&_lock);
    NSMapTable *KVOStalkingsMap = [self.KVOStalkingsMap copy];

    [self.KVOStalkingsMap removeAllObjects];
    OSSpinLockUnlock(&_lock);
    
    BPSharedStalker *sharedStalker = [BPSharedStalker sharedStalker];
    
    
    for (id object in KVOStalkingsMap) {
        NSSet *paths = [KVOStalkingsMap objectForKey:object];
        for (BPKVOStalking *stalking in paths) {
            [sharedStalker unobserveKVO:object info:stalking];
        }
    }
}

-(void)dealloc
{
    [self unobserveAll];
}

@end
