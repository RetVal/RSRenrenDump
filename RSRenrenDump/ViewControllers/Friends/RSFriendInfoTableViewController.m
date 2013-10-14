//
//  RSFriendInfoTableViewController.m
//  RSRenrenDump
//
//  Created by RetVal on 5/26/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSFriendInfoTableViewController.h"
#import "RSBaseModel.h"
#import "RSModelCell.h"
#import "RSProgressHUD.h"
#import "RSCoreAnalyzer.h"
#import "RSSharedDataBase.h"
#import "RSZhenYiYueViewController.h"

@interface RSFriendInfoTableViewController()
{
    
}
@end

@implementation RSFriendInfoTableViewController
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
//    if ([self tabBarController])
//        [[self tableView] setContentInset:UIEdgeInsetsMake(64, [[self tableView] contentInset].left, [[self tableView] contentInset].bottom + 44, [[self tableView] contentInset].right)];
    [super viewDidLoad];
    _analyzer = [[RSSharedDataBase sharedInstance] currentAnalyzer];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Pull down to Refresh"]];
    [refreshControl addTarget:self action:@selector(_update:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    [self performSelectorInBackground:@selector(_dumpFriendList) withObject:nil];
}

- (void)_update:(id)sender
{
    [[self refreshControl] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Updating..."]];
    [RSProgressHUD showProgress:-1.0f status:@"Updating..." maskType:RSProgressHUDMaskTypeGradient];
    [self performSelector:@selector(_loadData) withObject:nil afterDelay:2.0f];
}

- (void)_loadData
{
    NSMutableArray *_results = nil;
    NSUInteger pageNumber = 0;
    NSUInteger count = 0;
    NSUInteger numberOfFriends = 0;
    double delta = 0.0f;
    if (_analyzer == nil)
        _analyzer = [[RSCoreAnalyzer alloc] init];
    _results = [[NSMutableArray alloc] initWithCapacity:20];
    do
    {
        [_analyzer setURLToAnalyze:[RSCoreAnalyzer urlForCoreDumpFriendListWithUserId:[_analyzer userId] pageNumber:pageNumber]];
        NSXMLDocument *analyzeResult = [_analyzer startAnalyze];
        if (numberOfFriends == 0){
            numberOfFriends = [_analyzer analyzeFriendNumberFromDocument:analyzeResult];
            if (numberOfFriends)
            {
                delta = (double)1.0f;
                delta /= numberOfFriends;
            }
        }
        
        NSArray *friendInfos = [_analyzer friendsElementFromDocument:analyzeResult];
        if ([friendInfos count] == 0)
        {
            NSLog(@"{\n%@\n}", _analyzer);
            NSLog(@"\n************count = %4ld, pageNumber = %4ld, sum of friends = %4ld************\n", (unsigned long)count, (unsigned long)pageNumber, (unsigned long)numberOfFriends);
            break;
        }
        count += [friendInfos count];
        pageNumber ++;
        for (NSXMLElement *friendInfo in friendInfos) {
            id x = [_analyzer analyzeFriend:friendInfo];
            [_results addObject:x];
        }
        
        NSLog(@"\n************count = %4ld, pageNumber = %4ld, sum of friends = %4ld************\n", (unsigned long)count, (unsigned long)pageNumber, (unsigned long)numberOfFriends);
    } while (numberOfFriends > count);
    NSLog(@"%@", _results);
    [[self refreshControl] endRefreshing];
    [self setFriends:_results];
    [RSProgressHUD dismiss];
    [RSProgressHUD showSuccessWithStatus:@"Done"];
    [[self tableView] reloadData];
    [[self refreshControl] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Pull down to Refresh"]];
}

- (void)_dumpFriendList
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [RSProgressHUD dismiss];
        [RSProgressHUD showProgress:0 status:@"Loading..." maskType:RSProgressHUDMaskTypeGradient];
    });
    NSMutableArray *_results = nil;
    NSUInteger pageNumber = 0;
    NSUInteger count = 0;
    NSUInteger numberOfFriends = 0;
    double delta = 0.0f;
    if (_analyzer == nil)
        _analyzer = [[RSCoreAnalyzer alloc] init];
    _results = [[NSMutableArray alloc] initWithCapacity:20];
    do
    {
        [_analyzer setURLToAnalyze:[RSCoreAnalyzer urlForCoreDumpFriendListWithUserId:[_analyzer userId] pageNumber:pageNumber]];
        NSXMLDocument *analyzeResult = [_analyzer startAnalyze];
        if (numberOfFriends == 0){
            numberOfFriends = [_analyzer analyzeFriendNumberFromDocument:analyzeResult];
            if (numberOfFriends)
            {
                delta = (double)1.0f;
                delta /= numberOfFriends;
            }
        }
        
        NSArray *friendInfos = [_analyzer friendsElementFromDocument:analyzeResult];
        if ([friendInfos count] == 0)
        {
            NSLog(@"{\n%@\n}", _analyzer);
            NSLog(@"\n************count = %4ld, pageNumber = %4ld, sum of friends = %4ld************\n", (unsigned long)count, (unsigned long)pageNumber, (unsigned long)numberOfFriends);
            break;
        }
        count += [friendInfos count];
        pageNumber ++;
        for (NSXMLElement *friendInfo in friendInfos) {
            id x = [_analyzer analyzeFriend:friendInfo];
            [_results addObject:x];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [RSProgressHUD showProgress:delta * count status:@"Loading..." maskType:RSProgressHUDMaskTypeGradient];
        });
        NSLog(@"\n************count = %4ld, pageNumber = %4ld, sum of friends = %4ld************\n", (unsigned long)count, (unsigned long)pageNumber, (unsigned long)numberOfFriends);
    } while (numberOfFriends > count);
    NSLog(@"%@", _results);
    [RSProgressHUD dismiss];
    [self setFriends:_results];
    [[self tableView] reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_friends) return 0;
    return [_friends count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
//    return 127.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const reuseIdentifier = @"cell";
    NSLog(@"tableView");
//    RSModelCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
//    if (cell == nil) {
//        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"RSModelCell" owner:self options:nil];
//        cell = (RSModelCell *)[nibArray objectAtIndex:0];
//    }
    RSBaseModel *model = _friends[[indexPath row]];
//    [[cell titleTabel] setText:[model name]];
//    [[cell infoLabel] setText:[model account]];
//    [[cell replyCountLabel] setText:@"0"];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"MMMM, EEEE, YYYY"];
//    [[cell dateLabel] setText:[formatter stringFromDate:[NSDate date]]];
//    [[cell senderLabel] setText:@"RetVal"];
//    if ([[cell headImageView] image]) return cell;
//    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[_friends[[indexPath row]] imageURL]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//        if (error)
//        {
//            NSLog(@"%@", error);
//            return ;
//        }
//        if (data)
//        {
//            [_friends[[indexPath row]] setImage:[UIImage imageWithData:data]];
//            [[cell headImageView] setImage:[UIImage imageWithData:data]];
//        }
//    }];
//    return cell;
    
    UITableViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!newCell) newCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    [newCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [[newCell textLabel] setText:[model name]];
    [[newCell detailTextLabel] setText:[model account]];
    if ([_friends[[indexPath row]] image])
    {
        [[newCell imageView] setContentMode:UIViewContentModeScaleAspectFit];
        [[newCell imageView] setImage:[_friends[[indexPath row]] image]];
        return newCell;
    }
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[_friends[[indexPath row]] imageURL]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error)
        {
            NSLog(@"%@", error);
            return ;
        }
        if (data)
        {
            [[newCell imageView] setContentMode:UIViewContentModeScaleAspectFit];
            [_friends[[indexPath row]] setImage:[UIImage imageWithData:data]];
            [[newCell imageView] setImage:[_friends[[indexPath row]] image]];
        }
    }];
    return newCell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RSModelCell *cell = (RSModelCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell)
    {
        UIStoryboard *st = [UIStoryboard storyboardWithName:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
        RSZhenYiYueViewController *zhenyiyue = [st instantiateViewControllerWithIdentifier:@"RSZhenYiYueViewController"];
        [zhenyiyue setModel:_friends[[indexPath row]]];
        [[self navigationController] pushViewController:zhenyiyue animated:YES];
    }
}
@end
