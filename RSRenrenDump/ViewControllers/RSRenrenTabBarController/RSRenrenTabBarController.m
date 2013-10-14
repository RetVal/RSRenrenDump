//
//  RSRenrenTabBarController.m
//  RSRenren
//
//  Created by RetVal on 10/11/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSRenrenTabBarController.h"
#import "RSAppDelegate.h"

@interface RSRenrenTabBarController ()

@end

@interface UITabBarItem (ext)
- (UIImage *)shit;

@end

@implementation RSRenrenTabBarController

static NSString *pathWithScale(NSString *path, CGFloat scale)
{
	if (scale > 1)
		return [[[path stringByDeletingPathExtension] stringByAppendingFormat:@"@%gx", scale] stringByAppendingPathExtension:[path pathExtension]];
	else
		return path;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {

    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    NSArray *subBarItems = [[self tabBar] items];
//    id appDelegate = [UIApplication sharedApplication].delegate;
//    NSUInteger idx = 0;
//    for (UITabBarItem *item in subBarItems)
//    {
//        idx++;
//        
//        NSLog(@"item name = %@", [item title]);
//        NSLog(@"%p", [item shit]);
//        [item setTitle:@"Friends"];
//        if ([item shit])
//        {
//            UIImage *image = [item shit];;
//            NSString *imageName = @"contacts";
//            NSString *bundleName = [NSString stringWithFormat:@"bundle name - %@", @(idx)];
//            NSString *imagePath = [[appDelegate saveDirectory:bundleName] stringByAppendingPathComponent:pathWithScale(imageName, [image scale])];
//            [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
//        }
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation UITabBarItem (ext)

- (UIImage *)shit
{
    char *ptr = (__bridge void *)self;
    ptr = ((void *)((ptr) + sizeof(id) * 8));
    return (__bridge UIImage *)(void *)*(void **)ptr;
}

@end
