//
//  RSTopImageViewController.m
//  RSRenren
//
//  Created by Closure on 10/18/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSTopImageViewController.h"
#import "RSSelectAlbumViewController.h"
#import "RSAlbumLibrary.h"
#import "RSCoreAnalyzer.h"
#import "RSSharedDataBase.h"
#import "RSProgressHUD.h"

@interface RSTopImageViewController ()<RSAblumLibraryDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITableView *albumInfoTableView;
@property (nonatomic, strong) UIImage *capturedImage;
@property (nonatomic, strong) UIImagePickerController *pickerViewController;
@end

@implementation RSTopImageViewController

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
    
    [RSProgressHUD showProgress:-1.0f status:@"Updating Album..." maskType:RSProgressHUDMaskTypeGradient];
    [self setAnalyzer:[[RSSharedDataBase sharedInstance] currentAnalyzer]];
    _albumLibrary = [[RSAlbumLibrary alloc] initWithAnaylzer:[self analyzer] delegate:self];
    [_albumLibrary start];
	// Do any additional setup after loading the view.
    [self performSelector:@selector(show) withObject:nil afterDelay:0.0];
}

- (void)show
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    self.pickerViewController = imagePickerController;
    [self presentViewController:self.pickerViewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    _capturedImage = image;
    [[self imageView] setImage:[self capturedImage]];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self setPickerViewController:nil];
    //    [self.capturedImages addObject:image];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:^{
        [[self navigationController] popToViewController:_parent animated:YES];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueForSelectAlbum"])
    {
        RSSelectAlbumViewController *savc = (RSSelectAlbumViewController *)[segue destinationViewController];
        [savc setAlbums:[self albums]];
        [savc setParent:self];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"segueForSelectAlbum" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    NSString * format= @"Album name : %@";
    NSString *title = @"";
    NSString *detail = @"";
    
    
    switch ([indexPath row]) {
        case 0:
            if (![self selectedAlbum])
            {
                if ([[self albums] count])
                {
                    NSInteger idx = [self selectAblumAutomatically];
                    if (idx >= 0)
                    {
                        title = [[self albums][idx] name];
                        detail = [[self albums][idx] albumId];
                        [self setSelectedAlbum:[self albums][idx]];
                    }
                }
            }
            title = [[self selectedAlbum] name];
            detail = [[self selectedAlbum] photoNumber];
            [[cell textLabel] setText:[NSString stringWithFormat:format, title]];
            [[cell detailTextLabel] setText:detail];
            break;
    }
    return cell;
}

- (NSInteger)selectAblumAutomatically
{
    __block NSInteger _idx = -1;
    [[self albums] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj disabled])
        {
            _idx = idx;
            *stop = YES;
        }
    }];
    return _idx;
}
//- (void)publicImage:(NSString *)albumid photoId:(NSString *)photoId description:(NSString *)description complete:(void (^)(BOOL success))complete

#pragma mark -
#pragma mark RSAlbumLibrary Delegate
- (void)albumLibraray:(RSAlbumLibrary *)albumLibrary finishUpdate:(NSArray *)albums
{
    [self setAlbums:albums];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger idx = [self selectAblumAutomatically];
        if (idx >= 0)
        {
            [self setSelectedAlbum:[self albums][idx]];
            [[self albumInfoTableView] reloadData];
        }
        [RSProgressHUD dismiss];
        [RSProgressHUD showSuccessWithStatus:@"Done"];
    });
}

- (void)albumLibraray:(RSAlbumLibrary *)albumLibrary failedWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [RSProgressHUD dismiss];
        [RSProgressHUD showErrorWithStatus:@"Update failed!"];
        [[self navigationController] popToViewController:_parent animated:YES];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self albumInfoTableView] reloadData];
}

- (IBAction)makeTopAction:(id)sender
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"%@", NSStringFromSelector(_cmd));
        [_analyzer uploadSyncImage:[self capturedImage] description:@"置顶" selectAblum:^id(NSArray *ablumList) {
            return [self selectedAlbum];
        } complete:^(id photoId, BOOL success) {
            __block BOOL shouldContinue = YES;
            const NSTimeInterval step = 10.0f;
            NSTimeInterval time = 12 * 60 * 60;
            while (shouldContinue && time > 0.00001)
            {
                [_analyzer publicImage:[[self selectedAlbum] albumId] photoId:photoId description:@"置顶" complete:^(id photoId, BOOL success) {
                    if (!success) shouldContinue = NO;
                }];
                [NSThread sleepForTimeInterval:step];
                time -= step;
            }
        }];
    });
}
@end
