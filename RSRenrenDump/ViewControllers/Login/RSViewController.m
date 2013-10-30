//
//  RSViewController.m
//  RSRenrenDump
//
//  Created by RetVal on 5/25/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSViewController.h"
#import "RSDumpViewController.h"
#import "RSStatusViewController.h"
#import "RSAccount.h"
#import "RSCoreAnalyzer.h"
#import "RSProgressHUD.h"
#import "RSSharedDataBase.h"
#import "UIImageView+RSRoundRectImageView.h"
CGImageRef UIGetScreenImage(void);
static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

@interface RSViewController () <UITextFieldDelegate, RSCoreAnalyzerDelegate>
{
    @private
    RSCoreAnalyzer *_analyzer;
    RSAccount *_account;
    id _target;
    BOOL _floatingKeyboard;
    id _motion;
}
@property (strong, nonatomic) IBOutlet id blurView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation RSViewController
- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"%@", [NSBundle mainBundle]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor clearColor]];
    [[UIApplication sharedApplication] _setApplicationIsOpaque: NO];
    // only work on iOS 7.0.2
    [_email setDelegate:self];
    [_password setDelegate:self];
    
    _account = [[RSSharedDataBase sharedInstance] currentLoginAccount];
    if (_account)
    {
        [_email setText:[_account accountId]];
        [_password setText:[_account password]];
        [[self imageView] setImage:[_account headIcon]];
        [[self imageView] makeRoundRect];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueForLogin"])
    {
    }
    return;
}

- (IBAction)loginBtnPressed:(UIButton *)sender
{
    _analyzer = nil;
    _account = nil;
    _account = [[RSAccount alloc] initWithAccountId:[[self email] text] password:[[self password] text]];
    _analyzer = [RSCoreAnalyzer analyzerWithAccount:[_account accountId] password:[_account password]];
    [_analyzer setDelegate:self];
    [_analyzer startLogin];
    [RSProgressHUD showWithStatus:@"Login..." maskType:RSProgressHUDMaskTypeGradient];
    
}

#pragma mark -
#pragma mark RSCoreAnalyzerDelegate
- (void)analyzerLoginSuccess:(RSCoreAnalyzer *)analyzer
{
    [analyzer analyzerGetAccountInformation:[analyzer userId]];
    [[RSSharedDataBase sharedInstance] setCurrentAnalyzer:analyzer];
    dispatch_async(dispatch_get_main_queue(), ^{
        [RSProgressHUD dismiss];
    });
    [self performSegueWithIdentifier:@"segueForLogin" sender:self];
}

- (void)analyzer:(RSCoreAnalyzer *)analyzer LoginFailedWithError:(NSError *)error
{
    [RSProgressHUD dismiss];
    [RSProgressHUD showErrorWithStatus:@"Login failed!"];
}

- (void)analyzer:(RSCoreAnalyzer *)analyzer getAccountInfoFailedWithError:(NSError *)error
{
    NSLog(@"%@ - %@", NSStringFromSelector(_cmd), error);
}

- (void)analyzer:(RSCoreAnalyzer *)analyzer getAccountInfoSuccess:(RSAccount *)account
{
    [_account setHeadIcon:[account headIcon]];
    [[RSSharedDataBase sharedInstance] setCurrentLoginAccount:_account];
    
}

#pragma mark - 
#pragma mark UITextFiledDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _target = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _target = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // return key is pressed
    if ([textField isSecureTextEntry])
    {
        [self tipGestureActive:nil];
        [self loginBtnPressed:nil];
    }
    else
    {
        [_password becomeFirstResponder];
    }
    return YES;
}

#pragma mark -
#pragma mark UIKeyBoardNotification
- (IBAction)tipGestureActive:(UITapGestureRecognizer *)sender {
    [_target resignFirstResponder];
    _target = nil;
}

const double fbixt = 2.2;
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (_floatingKeyboard) return;
    _floatingKeyboard = YES;
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect newFrame = self.view.frame;
//    newFrame.origin.y -= kbSize.height / 4;
    newFrame.origin.y -= kbSize.height / fbixt;
    [UIView animateWithDuration:0.3f animations:^{
        [[self view] setFrame:newFrame];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (!_floatingKeyboard) return;
    _floatingKeyboard = NO;
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect newFrame = self.view.frame;
//    newFrame.origin.y += kbSize.height / 4;
    newFrame.origin.y += kbSize.height / fbixt;
    [UIView animateWithDuration:0.3f animations:^{
        [[self view] setFrame:newFrame];
    }];
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
    for (UIView *view in [[self view] subviews])
        [view addMotionEffect:[self _motion]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    for (UIView *view in [[self view] subviews]) {
        [view removeMotionEffect:[self _motion]];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (id)_motion;
{
    if (_motion) return _motion;
    const static CGFloat motionXMinValue = -20.f;
    const static CGFloat motionXMaxValue = 20.f;
    
    const static CGFloat motionYMinValue = -20.f;
    const static CGFloat motionYMaxValue = 20.f;
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = @(motionXMinValue);
    xAxis.maximumRelativeValue = @(motionXMaxValue);
    
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = @(motionYMinValue);
    yAxis.maximumRelativeValue = @(motionYMaxValue);
    
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    [group setMotionEffects:@[xAxis, yAxis]];
    _motion = group;
    return _motion;
}

@end

