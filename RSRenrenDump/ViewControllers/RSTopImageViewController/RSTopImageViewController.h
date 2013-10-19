//
//  RSTopImageViewController.h
//  RSRenren
//
//  Created by Closure on 10/18/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RSCoreAnalyzer, RSAlbum, RSAlbumLibrary;
@interface RSTopImageViewController : UIViewController
@property (nonatomic, strong) RSCoreAnalyzer *analyzer;
@property (nonatomic, strong) RSAlbumLibrary *albumLibrary;
@property (nonatomic, strong) NSArray *albums;
@property (nonatomic, strong) RSAlbum *selectedAlbum;
@property (nonatomic, weak) UIViewController *parent;
@end
