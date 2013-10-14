//
//  AFNoteTableViewController.h
//  Note
//
//  Created by RetVal on 9/11/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AFNoteTableViewController : UITableViewController
@property (nonatomic, strong) NSDictionary * info;
@property (nonatomic, strong) NSMutableArray *groups;
@end

FOUNDATION_EXPORT NSString * const _AFSettingItems;
