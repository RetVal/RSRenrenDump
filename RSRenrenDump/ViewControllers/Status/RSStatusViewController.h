//
//  RSStatusViewController.h
//  RSRenrenDump
//
//  Created by RetVal on 10/9/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSAccount;
@interface RSStatusViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextView *statusContent;
@property (strong, nonatomic) RSAccount *account;
@property (strong, nonatomic) IBOutlet UISwitch *loopSwitch;
@property (weak, nonatomic) UIViewController *parent;
@end
