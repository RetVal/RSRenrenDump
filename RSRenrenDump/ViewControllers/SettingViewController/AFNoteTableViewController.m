//
//  AFNoteTableViewController.m
//  Note
//
//  Created by RetVal on 9/11/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "AFNoteTableViewController.h"
#import "AFSettingCellDataModel.h"
#import "AFSettingTableViewCell.h"

@interface AFNoteTableViewController ()

@end

@implementation AFNoteTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
        [[self navigationItem] setTitle:[[self info] objectForKey:@"title"]];
        [self setTitle:[[self info] objectForKey:@"titile"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self groups][section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self groups] count];
}

- (id)_modelForIndexPath:(NSIndexPath *)indexPath
{
    return [self groups][[indexPath section]][[indexPath row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identifierSwitch = @"cell-switch";
    NSString * identifierPush = @"cell-push";
    NSString * identifierBotton = @"cell-botton";
    NSString * identifier = nil;
    id model = [self _modelForIndexPath:indexPath];
    if ([AFCellSwitchStyle isEqualToString:[model cellStyle]]) identifier = identifierSwitch;
    else if ([AFCellPushStyle isEqualToString:[model cellStyle]]) identifier = identifierPush;
    else if ([AFCellBottonStyle isEqualToString:[model cellStyle]]) identifier = identifierBotton;
    else identifier = @"cell";
    AFSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[AFSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier model:[self _modelForIndexPath:indexPath]];
    }
    [cell setModel:model];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [AFCellPushStyle isEqualToString:[[self _modelForIndexPath:indexPath] cellStyle]] || [AFCellBottonStyle isEqualToString:[[self _modelForIndexPath:indexPath] cellStyle]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL animated = [self tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:animated];
    if (animated == YES)
    {
        id model = [self _modelForIndexPath:indexPath];
        if ([AFCellPushStyle isEqualToString:[model cellStyle]])
        {
            [[model pushTo] setTitle:[model displayName]];
            [[self navigationController] pushViewController:[model pushTo] animated:animated];
        }
        else if ([AFCellBottonStyle isEqualToString:[model cellStyle]])
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            SEL selector = NSSelectorFromString([model pushTo]);
            if (selector) [model performSelector:selector withObject:self];
#pragma clang diagnostic pop
        }
    }
}
@end
