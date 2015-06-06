//
//  BPAppDelegate.m
//  Stalker
//
//  Created by Luca Querella on 23/05/14.
//  Copyright (c) 2014 BendingSpoons. All rights reserved.
//

#import "BPAppDelegate.h"
#import "NSObject+BPStalker.h"

@interface BPAppDelegate ()
@end
@implementation BPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = UIViewController.new;
    self.window.rootViewController.view.backgroundColor = UIColor.redColor;
    [self.window makeKeyAndVisible];

    return YES;
}


@end
