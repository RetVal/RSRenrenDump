//
//  RSUploadSettingViewController.m
//  RSRenren
//
//  Created by Closure on 10/13/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSUploadSettingViewController.h"
#import "AFNoteTableViewController.h"
#import "AFSettingCellDataModel.h"
#import "RSUploadImageViewController.h"
#import "RSStatusViewController.h"

@interface RSUploadSettingViewController ()

@end

@implementation RSUploadSettingViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)_init
{
//    NSDictionary *rootSettings = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UploadSettingPreferences" ofType:@"plist"]];
//    [self setGroups:[[NSMutableArray alloc] init]];
//    for (NSDictionary *group in (rootSettings[@"TableView"][@"tableViewSettings"]))
//    {
//        NSMutableArray *groupSet = [[NSMutableArray alloc] init];
//        NSArray *items = group[_AFSettingItems];
//        for (NSDictionary *item in items)
//        {
//            AFSettingCellDataModel *dm = [[AFSettingCellDataModel alloc] initWithDictionary:item];
//            [groupSet addObject:dm];
//        }
//        [[self groups] addObject:groupSet];
//    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueForShareImage"])
    {
        RSUploadImageViewController *uivc = (RSUploadImageViewController *)[segue destinationViewController];
        [uivc setParent:self];
    }
    else if ([[segue identifier] isEqualToString:@"segueForShareStatus"])
    {
        RSStatusViewController *svc = (RSStatusViewController *)[segue destinationViewController];
        [svc setParent:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
