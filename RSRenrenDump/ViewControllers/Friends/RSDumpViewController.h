//
//  RSDumpViewController.h
//  RSRenrenDump
//
//  Created by RetVal on 5/26/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSAccount, RSCoreAnalyzer;
@interface RSDumpViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) RSAccount *account;
@property (strong, nonatomic) RSCoreAnalyzer *analyzer;
@end
