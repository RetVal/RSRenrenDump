//
//  RSUploadImageViewController.m
//  RSRenren
//
//  Created by Closure on 10/14/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSUploadImageViewController.h"
#import "RSCoreAnalyzer.h"
#import "RSSharedDataBase.h"
#import "RSAlbumLibrary.h"
#import "RSSelectAlbumViewController.h"
#import "RSProgressHUD.h"

@interface RSUploadImageViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate, RSAblumLibraryDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate>
{
    RSCoreAnalyzer *_analyzer;
    id _target;
    BOOL _floatingKeyboard;
}
//@property (nonatomic, strong) NSMutableArray *capturedImages;
@property (atomic, strong) RSCoreAnalyzer *analyzer;
@property (nonatomic, strong) UIImage *capturedImage;
@property (nonatomic, strong) UIImagePickerController *pickerViewController;
@property (nonatomic, strong) RSAlbumLibrary *albumLibrary;
@property (atomic, strong) NSArray *albums;
@property (atomic, assign) BOOL albumUpdated;
- (RSCoreAnalyzer *)analyzer;
- (void)setAnalyzer:(RSCoreAnalyzer *)analyzer;
@end

@implementation RSUploadImageViewController
@synthesize analyzer = _analyzer;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
//        _capturedImages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        _capturedImages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    _albumLibrary = [[RSAlbumLibrary alloc] initWithAnaylzer:[self analyzer] delegate:self];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureHideKeyboard:)];
    [tapGesture setDelegate:self];
    [[self view] addGestureRecognizer:tapGesture];
	// Do any additional setup after loading the view.
//    [[self capturedImages] removeAllObjects];
    _pickerViewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [_albumLibrary start];
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

- (RSCoreAnalyzer *)analyzer
{
    if (!_analyzer) _analyzer = [[RSSharedDataBase sharedInstance] currentAnalyzer];
    return _analyzer;
}

- (void)setAnalyzer:(RSCoreAnalyzer *)analyzer
{
    _analyzer = analyzer;
}

- (void)update
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[self imageView] setImage:[self capturedImage]];
    
    [self setPickerViewController:nil];
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

#pragma mark - 
#pragma mark RSAlbumLibrary Delegate
- (void)albumLibraray:(RSAlbumLibrary *)albumLibrary finishUpdate:(NSArray *)albums
{
    [self setAlbums:albums];
    NSInteger idx = [self selectAblumAutomatically];
    if (idx >= 0)
    {
        [[self albumInfoTableView] reloadData];
    }
}

- (void)albumLibraray:(RSAlbumLibrary *)albumLibrary failedWithError:(NSError *)error
{
    
}

#pragma mark -
#pragma mark UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    _capturedImage = image;
    [self update];
//    [self.capturedImages addObject:image];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:^{
        [[self navigationController] popToViewController:_parent animated:YES];
    }];
}

#pragma mark -
#pragma mark UITableViewDelegate 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
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
        case 1:
            [[cell textLabel] setText:@"2"];
            break;
    }
    return cell;
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self albumInfoTableView] reloadData];
}

- (void)_tapGestureHideKeyboard:(UIGestureRecognizer *)gesture
{
    [[self descriptionContent] resignFirstResponder];
}

#pragma mark -
#pragma mark UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _target = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _target = nil;
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#define MAX_LENGTH  135
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        [self publicAction:self];
        return YES;
    }
    NSUInteger newLength = (textView.text.length - range.length) + text.length;
    if(newLength <= MAX_LENGTH)
    {
        return YES;
    }
    else
    {
        NSUInteger emptySpace = MAX_LENGTH - (textView.text.length - range.length);
        textView.text = [[[textView.text substringToIndex:range.location]
                          stringByAppendingString:[text substringToIndex:emptySpace]]
                         stringByAppendingString:[textView.text substringFromIndex:(range.location + range.length)]];
        return NO;
    }
}

#pragma mark -
#pragma mark UIKeyBoardNotification
- (IBAction)tipGestureActive:(UITapGestureRecognizer *)sender {
    [_target resignFirstResponder];
    _target = nil;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (_floatingKeyboard) return;
    _floatingKeyboard = YES;
//    NSDictionary* info = [notification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    
//    CGRect newFrame = self.view.frame;
//    newFrame.origin.y -= kbSize.height / 4;
//    [UIView animateWithDuration:0.3f animations:^{
//        [[self view] setFrame:newFrame];
//    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (!_floatingKeyboard) return;
    _floatingKeyboard = NO;
//    NSDictionary* info = [notification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    
//    CGRect newFrame = self.view.frame;
//    newFrame.origin.y += kbSize.height / 4;
//    [UIView animateWithDuration:0.3f animations:^{
//        [[self view] setFrame:newFrame];
//    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([UIDevice majorVersion] >= 7)
    {
        if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"])
            return NO;
    }
    if ([touch.view isKindOfClass:[UITableViewCell class]])
        return NO;
    return YES;
}

- (void)bindKeyBoardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self bindKeyBoardNotification];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (IBAction)publicAction:(id)sender
{
    [RSProgressHUD showProgress:-1.0f status:@"Uploading..." maskType:RSProgressHUDMaskTypeGradient];
    [_analyzer uploadImage:_capturedImage description:_descriptionContent.text selectAblum:^NSString *(NSArray *ablumList) {
        NSLog(@"select album %@", _selectedAlbum);
        return _selectedAlbum;
    } complete:^(BOOL success) {
        NSLog(@"upload result = %@", success ? @"Success" : @"failed");
        [RSProgressHUD dismiss];
        if (success)
        {
            [RSProgressHUD showSuccessWithStatus:@"Success"];
            [[self navigationController] popToViewController:_parent animated:YES];
        }
        else [RSProgressHUD showErrorWithStatus:@"Failed"];
    }];
}

@end
