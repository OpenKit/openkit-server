//
//  AppDelegate.m
//  OKPushTest
//
//  Created by Louis Zell on 11/9/13.
//  Copyright (c) 2013 OpenKit. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (UILabel *)failLabel
{
    float h = 100;
    CGRect frame = CGRectMake(0, (self.window.bounds.size.height / 2) - (h / 2), 320.0, h);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor redColor];
    label.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:18.0];
    label.text = @"Failed!  See error in console.";
    return label;
}


- (UILabel *)successLabel
{
    float h = 100;
    CGRect frame = CGRectMake(0, (self.window.bounds.size.height / 2) - (h / 2), 320.0, h);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor greenColor];
    label.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:18.0];
    label.text = @"Success!  Copy token from console!";
    return label;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [UIViewController new];    // silence "expected to have root view..." warning.
    [self.window makeKeyAndVisible];

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];

    return YES;
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];

    [self.window addSubview:[self successLabel]];

    NSLog(@"Your token is:\n%@", hexToken);
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [self.window addSubview:[self failLabel]];
    NSLog(@"Failed to register for remote notifications: %@", error.localizedDescription);
}

@end
