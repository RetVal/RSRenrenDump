//
//  RSOperationQueueStatusBar.h
//  RSRenren
//
//  Created by Closure on 10/18/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSOperationQueueStatusBar : UIWindow
{
    @private
    UILabel *_statusLabel;
}

+ (id)sharedStatusBar;
- (void)showWithMessage:(NSString *)message;
- (void)hide;
@end
