//
//  RSAppDelegate.m
//  RSRenrenDump
//
//  Created by RetVal on 5/25/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSAppDelegate.h"
#import "RSCoreAnalyzer.h"
#import "RSLikeModel.h"
#import "RSRemoteDataBase.h"
#import "UIImage+ImageEffects.h"
#import "RSOperationQueue.h"
#import "MTStatusBarOverlay.h"
#import "RSOperationQueueStatusBar.h"

#include <objc/objc.h>

@interface RSAppDelegate () <RSCoreAnalyzerDelegate>
{
    RSCoreAnalyzer *_analyzer;
    RSOperationQueue *_queue;
}

@end
@implementation RSAppDelegate

- (id)init
{
    if (self = [super init])
    {
        _queue = [[RSOperationQueue alloc] initWithName:@"com.retval.taskqueue"];
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

- (void)analyzerLoginSuccess:(RSCoreAnalyzer *)analyzer
{
}

- (void)analyzer:(RSCoreAnalyzer *)analyzer LoginFailedWithError:(NSError *)error
{
    NSLog(@"login failed");
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSString *) saveDirectory:(NSString *)subDirectory
{
	NSString *saveDirectory = nil;
    saveDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	if (subDirectory)
		saveDirectory = [saveDirectory stringByAppendingPathComponent:subDirectory];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:saveDirectory])
	{
		NSError *error = nil;
		BOOL created = [[NSFileManager defaultManager] createDirectoryAtPath:saveDirectory withIntermediateDirectories:YES attributes:nil error:&error];
		if (!created)
			NSLog(@"%@\n%@", error, error.userInfo);
	}
	
	return saveDirectory;
}

@end

@implementation UIDevice (SystemVersion)
+ (NSUInteger)majorVersion
{
    NSUInteger major = [[[UIDevice currentDevice] systemVersion] integerValue];
    return major;
}
@end
