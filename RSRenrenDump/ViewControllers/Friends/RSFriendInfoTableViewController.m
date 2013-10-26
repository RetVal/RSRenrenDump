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
#import "UIImageView+RSRoundRectImageView.h"
#import "_RSStoreCache.h"

@interface RSFriendInfoTableViewController()
{
    NSOperationQueue *_queue;
    _RSStoreCache *_imageCache;
}
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) _RSStoreCache *imageCache;
@end

@implementation RSFriendInfoTableViewController
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        
    }
    return self;
}

- (id)_loadCache
{
    NSDictionary *cachePreferences = [[RSSharedDataBase sharedInstance] settingPreferences][@"Cache"];
    NSString *path = [[NSString alloc] initWithFormat:@"%@/%@/%@/%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSAllDomainsMask, YES)[0],
                      cachePreferences[@"AccountName"],
                      [_analyzer userId],
                      cachePreferences[@"FriendsCache"],
                      cachePreferences[@"FriendsCacheInfo"]];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

- (BOOL)_saveCache:(id)object
{
    NSDictionary *cachePreferences = [[RSSharedDataBase sharedInstance] settingPreferences][@"Cache"];
    NSString *path = [[NSString alloc] initWithFormat:@"%@/%@/%@/%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSAllDomainsMask, YES)[0],
                      cachePreferences[@"AccountName"],
                      [_analyzer userId],
                      cachePreferences[@"FriendsCache"],
                      cachePreferences[@"FriendsCacheInfo"]];
    return [NSKeyedArchiver archiveRootObject:object toFile:path];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _analyzer = [[RSSharedDataBase sharedInstance] currentAnalyzer];
    [self setQueue:[[NSOperationQueue alloc] init]];
    [[self queue] setMaxConcurrentOperationCount:5];
    NSDictionary *cachePreferences = [[RSSharedDataBase sharedInstance] settingPreferences][@"Cache"];
    [self setImageCache:[[_RSStoreCache alloc] initWithStorePath:[NSString stringWithFormat:@"%@/%@/%@", cachePreferences[@"AccountName"], [_analyzer userId], cachePreferences[@"FriendsCache"]] named:cachePreferences[@"FriendsCacheImage"] memorySize:[cachePreferences[@"FriendsCacheImageCapacity"] integerValue]]];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Pull down to Refresh"]];
    [refreshControl addTarget:self action:@selector(_update:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    id data = [self _loadCache];
    if (data)
    {
        _friends = data;
    }
    else [self performSelectorInBackground:@selector(_dumpFriendList) withObject:nil];
}

- (void)_update:(id)sender
{
    [[self refreshControl] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Updating..."]];
    [RSProgressHUD showProgress:0.0f status:@"Updating..." maskType:RSProgressHUDMaskTypeGradient];
    [self performSelectorInBackground:@selector(_loadData) withObject:nil];
    return;
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
            RSBaseModel *x = [_analyzer analyzeFriend:friendInfo];
            [_results addObject:x];
//            [x setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[x imageURL]]]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [RSProgressHUD showProgress:delta * count status:@"Loading..." maskType:RSProgressHUDMaskTypeGradient];
        });
        NSLog(@"\n************count = %4ld, pageNumber = %4ld, sum of friends = %4ld************\n", (unsigned long)count, (unsigned long)pageNumber, (unsigned long)numberOfFriends);
    } while (numberOfFriends > count);
    [[self refreshControl] endRefreshing];
    [self setFriends:_results = [self _sectionResults:_results]];
    [self _saveCache:_results];
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
            RSBaseModel *x = [_analyzer analyzeFriend:friendInfo];
            [_results addObject:x];
//            [x setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[x imageURL]]]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [RSProgressHUD showProgress:delta * count status:@"Loading..." maskType:RSProgressHUDMaskTypeGradient];
        });
        NSLog(@"\n************count = %4ld, pageNumber = %4ld, sum of friends = %4ld************\n", (unsigned long)count, (unsigned long)pageNumber, (unsigned long)numberOfFriends);
    } while (numberOfFriends > count);
    _results = [self _sectionResults:_results];
    [self _saveCache:_results];
    dispatch_async(dispatch_get_main_queue(), ^{
        [RSProgressHUD dismiss];
    });
    [self setFriends:_results];
    [[self tableView] reloadData];
}

- (NSMutableArray *)_sectionResults:(NSMutableArray *)array
{
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    NSArray *sectionTitles = [collation sectionTitles];
    NSUInteger sectionTitlesCount = [sectionTitles count];
    NSMutableArray *sections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    for (NSUInteger idx = 0; idx < sectionTitlesCount; idx++)
        sections[idx] = [[NSMutableArray alloc] init];
    
    for (RSBaseModel *model in array) {
        NSUInteger sectionidx = [collation sectionForObject:model collationStringSelector:@selector(name)];
        [sections[sectionidx] addObject:model];
    }
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (NSMutableArray *section in sections) {
        NSArray *sortedSection = [collation sortedArrayFromArray:section collationStringSelector:@selector(name)];
        [results addObject:sortedSection];
    }
    return results;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_friends count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_friends) return 0;
    return [_friends[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
//    return 127.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const reuseIdentifier = @"cell";
    RSBaseModel *model = _friends[[indexPath section]][[indexPath row]];
    
    UITableViewCell *newCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!newCell) newCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    [newCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [[newCell textLabel] setText:[model name]];
    [[newCell detailTextLabel] setText:[model account]];
    [[newCell imageView] setContentMode:UIViewContentModeScaleAspectFit];
    UIImage *image = _imageCache[[_friends[[indexPath section]][[indexPath row]] account]];
    if (image)
    {
        [[newCell imageView] setImage:_imageCache[[_friends[[indexPath section]][[indexPath row]] account]]];
        [[newCell imageView] makeRoundRect];
        return newCell;
    }
    
    [[self queue] addOperationWithBlock:^{
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[_friends[[indexPath section]][[indexPath row]] imageURL]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (error)
            {
                NSLog(@"%@", error);
                return ;
            }
            if (data)
            {
                NSLog(@"update head for user (%@,%@)", [_friends[[indexPath section]][[indexPath row]] name], [_friends[[indexPath section]][[indexPath row]] account]);
                UIImage *image = [UIImage imageWithData:data];
                [_imageCache writeObject:image forKey:[_friends[[indexPath section]][[indexPath row]] account]];
                if ([[tableView visibleCells] containsObject: newCell])
                {
                    [[newCell imageView] setImage:image];
                    [[newCell imageView] makeRoundRect];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [newCell setNeedsLayout];
                    });
                }
            }
        }];
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
        [zhenyiyue setModel:_friends[[indexPath section]][[indexPath row]]];
        [[self navigationController] pushViewController:zhenyiyue animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([[_friends objectAtIndex:section] count] > 0) {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionTitles];
}
@end
