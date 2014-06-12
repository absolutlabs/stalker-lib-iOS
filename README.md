Stalker
========

Heavily inspired by [KVOController](https://github.com/facebook/KVOController), Stalker offers a developer-friendly, block-based interface to KVO and `NSNotification`.


How to use it
=============

```objective-c
//import the header
#import "NSObject+Stalker.h"

// observe the property 'count' for the object spoons
[self.stalker whenPath:@"count"
       changeForObject:spoons
               options:NSKeyValueObservingOptionNew 
                  then:^(id object, NSDictionary *change) {
    
               }];

// listen to the notification UIApplicationDidBecomeActiveNotification
[self.stalker when:UIApplicationDidBecomeActiveNotification 
              then:^(NSNotification *notification) {
    
}];

```

note that:
- You don't need to unobserve. it's automagically done when the object is deallocated
- You don't need to create an instance of BPStalker, it's already available through the category NSObject+Stalker

Contact
=======
Luca Querella
lq@bendingspoons.dk
