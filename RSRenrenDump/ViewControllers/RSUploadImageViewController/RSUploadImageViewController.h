//
//  RSUploadImageViewController.h
//  RSRenren
//
//  Created by Closure on 10/14/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSUploadImageViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITableView *albumInfoTableView;
@property (strong, nonatomic) id selectedAlbum;
@property (strong, nonatomic) IBOutlet UITextView *descriptionContent;
@property (weak, nonatomic) UIViewController *parent;
@end
