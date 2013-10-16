//
//  RSViewController.h
//  RSRenrenDump
//
//  Created by RetVal on 5/25/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSCoreAnalyzer;
@interface RSViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *email;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (nonatomic, strong) RSCoreAnalyzer *analyzer;
@end
