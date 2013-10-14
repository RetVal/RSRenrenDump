//
//  RSSelectAlbumViewController.m
//  RSRenren
//
//  Created by Closure on 10/14/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSSelectAlbumViewController.h"
#import "RSUploadImageViewController.h"
#import "RSAlbumLibrary.h"

@interface RSSelectAlbumViewController ()

@end

@implementation RSSelectAlbumViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self albums] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    // Configure the cell...
    [[cell textLabel] setText:[[self albums][[indexPath row]] name]];
    [[cell detailTextLabel] setText:[[self albums][[indexPath row]] photoNumber]];
    [cell setUserInteractionEnabled:![[self albums][[indexPath row]] disabled]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self parent] setSelectedAlbum:[self albums][[indexPath row]]];
    UINavigationController *nav = (UINavigationController *)[self parentViewController];
    [nav popToViewController:[self parent] animated:YES];
//    [[self parent] dismissViewControllerAnimated:YES completion:nil];
}
@end
