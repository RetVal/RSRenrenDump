//
//  RSSelectAlbumViewController.h
//  RSRenren
//
//  Created by Closure on 10/14/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSSelectAlbumViewController : UITableViewController
@property (nonatomic, strong) NSArray *albums;
@property (nonatomic, weak) UIViewController *parent;
@end
