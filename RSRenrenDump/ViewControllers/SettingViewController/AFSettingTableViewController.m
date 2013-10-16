//
//  AFSettingTableViewController.m
//  Note
//
//  Created by RetVal on 9/11/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "AFSettingTableViewController.h"
#import "AFSettingCellDataModel.h"
#import "AFSettingTableViewCell.h"
#import "RSSharedDataBase.h"

NSString * const _AFSettingItems = @"items";
@interface AFSettingTableViewController ()

@end

@implementation AFSettingTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // Custom initialization
        NSDictionary *rootSettings = [[RSSharedDataBase sharedInstance] settingPreferences];
        [self setGroups:[[NSMutableArray alloc] init]];
        for (NSDictionary *group in (rootSettings[@"TableView"][@"tableViewSettings"]))
        {
            NSMutableArray *groupSet = [[NSMutableArray alloc] init];
            NSArray *items = group[_AFSettingItems];
            for (NSDictionary *item in items)
            {
                AFSettingCellDataModel *dm = [[AFSettingCellDataModel alloc] initWithDictionary:item];
                [groupSet addObject:dm];
            }
            [[self groups] addObject:groupSet];
        }
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        NSDictionary *rootSettings = [[RSSharedDataBase sharedInstance] settingPreferences];
        [self setGroups:[[NSMutableArray alloc] init]];
        for (NSDictionary *group in (rootSettings[@"TableView"][@"tableViewSettings"]))
        {
            NSMutableArray *groupSet = [[NSMutableArray alloc] init];
            NSArray *items = group[_AFSettingItems];
            for (NSDictionary *item in items)
            {
                AFSettingCellDataModel *dm = [[AFSettingCellDataModel alloc] initWithDictionary:item];
                [groupSet addObject:dm];
            }
            [[self groups] addObject:groupSet];
        }
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    CGRect rect = [[self tableView] frame];
    [self setTableView:[[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
