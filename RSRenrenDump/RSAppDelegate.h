//
//  RSAppDelegate.h
//  RSRenrenDump
//
//  Created by RetVal on 5/25/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
- (NSString *) saveDirectory:(NSString *)subDirectory;
@end
