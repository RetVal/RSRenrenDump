//
//  RSFriendInfoTableViewController.h
//  RSRenrenDump
//
//  Created by RetVal on 5/26/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTUITableViewZoomController.h"

@class RSCoreAnalyzer;
@interface RSFriendInfoTableViewController : UITableViewController
//TTUITableViewZoomController
@property (nonatomic, strong) RSCoreAnalyzer *analyzer;
@property (nonatomic, strong) NSArray *friends;
@end
