//
//  AspectsAppDelegate.m
//  AspectsDemo
//
//  Created by Peter Steinberger on 03/05/14.
//  Copyright (c) 2014 PSPDFKit GmbH. All rights reserved.
//

#import "AspectsAppDelegate.h"
#import "AspectsViewController.h"
#import "Aspects.h"

@interface Test : NSObject

- (void)towMethod;

@end

@implementation Test

- (void)towMethod {
//    NSLog(@"%@ %s",NSStringFromClass([self class]),__func__);
}

@end

@interface TestSub1 : Test
@end

@implementation TestSub1

- (void)towMethod {
    [super towMethod];
}

@end


@implementation AspectsAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Test aspect_hookSelector:@selector(towMethod) withOptions:AspectPositionBefore usingBlock:^(id as){
        NSLog(@"AspectPositionBefore========one");
    } error:nil];
    [Test aspect_hookSelector:@selector(towMethod) withOptions:AspectPositionBefore usingBlock:^(id as){
        NSLog(@"AspectPositionBefore========two");
    } error:nil];
    
    [Test aspect_hookSelector:@selector(towMethod) withOptions:AspectOptionAutomaticRemoval usingBlock:^(id as){
        NSLog(@"AspectOptionAutomaticRemoval========One");
    } error:nil];
    
    [Test aspect_hookSelector:@selector(towMethod) withOptions:AspectPositionAfter usingBlock:^(id as){
        NSLog(@"AspectPositionAfter========One");
    } error:nil];
    
    Test *t = [Test new];
    [t towMethod];
    [t towMethod];
    
    
    AspectsViewController *aspectsController = [AspectsViewController new];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:aspectsController];
    [self.window makeKeyAndVisible];

    // Ignore hooks when we are testing.
//    if (!NSClassFromString(@"XCTestCase")) {
//        [aspectsController aspect_hookSelector:@selector(buttonPressed:) withOptions:0 usingBlock:^(id info, id sender) {
//            NSLog(@"Button was pressed by: %@", sender);
//        } error:NULL];
//
//        [aspectsController aspect_hookSelector:@selector(viewWillLayoutSubviews) withOptions:0 usingBlock:^{
//            NSLog(@"Controller is layouting!");
//        } error:NULL];
//    }

    return YES;
}

@end
