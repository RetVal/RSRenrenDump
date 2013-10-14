//
//  RSStatusViewController.m
//  RSRenrenDump
//
//  Created by RetVal on 10/9/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSStatusViewController.h"
#import "RSCoreAnalyzer.h"
#import "RSAccount.h"
#import "RSProgressHUD.h"
#import "RSSharedDataBase.h"

@interface RSStatusViewController ()<RSCoreAnalyzerDelegate, UITextViewDelegate>
{
    RSCoreAnalyzer *_analyzer;
    RSAccount *_account;
    id _target;
    id _token;
    BOOL _floatingKeyboard;
}
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end

@implementation RSStatusViewController

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
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureHideKeyboard:)];
    [[self view] addGestureRecognizer:tapGesture];
    _analyzer = [[RSSharedDataBase sharedInstance] currentAnalyzer];
    _token = [_analyzer token];
    _token[@"channel"] = @"renren";
    _token[@"hostid"] = [_analyzer userId];
}

- (void)_prepare
{
    UIView *view = [[UIView alloc] initWithFrame:[[self view] bounds]];
    [view setTag:117]; // 不能删
	[view setBackgroundColor:[UIColor blackColor]];
	[view setAlpha:0.8];
    [self setActivityIndicator:[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, 32.0f, 32.0f)]];
    [[self activityIndicator] setCenter:[view center]];
    [[self activityIndicator] setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [[self view] addSubview:view];
    [view addSubview:[self activityIndicator]];
	[self.view bringSubviewToFront:view];
    [[self activityIndicator] startAnimating];
}

- (void)_cleanup
{
	[[self activityIndicator] stopAnimating];
	UIView *view = (UIView *)[[self view] viewWithTag:117];
	[view removeFromSuperview];
}

- (void)analyzerLoginSuccess:(RSCoreAnalyzer *)analyzer
{
    [self performSelector:@selector(_cleanup) withObject:nil afterDelay:1.2];
    _token = [[_analyzer token] mutableCopy];
    _token[@"channel"] = @"renren";
    _token[@"hostid"] = [_analyzer userId];
}

- (void)analyzer:(RSCoreAnalyzer *)analyzer LoginFailedWithError:(NSError *)error
{
    [self performSelector:@selector(_cleanup) withObject:nil afterDelay:1.2];
    NSLog(@"%@", error);
}

- (NSMutableDictionary *)_statusTokenInfo
{
    if (!_analyzer) return nil;
    NSString *str = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.renren.com/%@" ,[_analyzer userId]]] encoding:NSUTF8StringEncoding error:nil];
    NSString *requestToken = nil, *_rtk = nil;
    NSRange range = [str rangeOfString:@"get_check:'"];
    str = [str substringWithRange:NSMakeRange(range.location + range.length, [str length] - range.location - range.length - 1)];
    range = [str rangeOfString:@"'"];
    
    requestToken = [str substringWithRange:NSMakeRange(0, range.location)];
    str = [str substringWithRange:NSMakeRange(range.location + range.length, [str length] - range.location - range.length - 1)];
    
    range = [str rangeOfString:@"get_check_x:'"];
    str = [str substringWithRange:NSMakeRange(range.location + range.length, [str length] - range.location - range.length - 1)];
    
    range = [str rangeOfString:@"'"];
    _rtk = [str substringWithRange:NSMakeRange(0, range.location)];
    
    
    NSInteger n1 = [requestToken integerValue];
    if (n1 != abs(n1))
    {
        requestToken = [[NSString alloc] initWithFormat:@"%d", abs(n1)];
    }
    
    return [@{@"requestToken": requestToken, @"_rtk" : _rtk} mutableCopy];
}

- (void)_setTitle:(NSString *)title
{
    id str = [self title];
    [self setTitle:title];
    [self performSelector:@selector(setTitle:) withObject:str afterDelay:3.0];
}

- (IBAction)sendBtnPressed:(id)sender
{
    NSMutableDictionary *token = [_token mutableCopy];
    __block NSURLRequest *request = nil;
    [RSProgressHUD showProgress:-1.0 status:@"Publishing..." maskType:RSProgressHUDMaskTypeGradient];
    if ([[self loopSwitch] isOn] == YES && NO)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __block BOOL success = YES;
            id orgTitle = [self title];
            [self setTitle:@"Success"];
            NSUInteger idx = 0;
            while ([[self loopSwitch] isOn] && success)
            {
                token[@"content"] = [NSString stringWithFormat:@"%@(%d)", [[self statusContent] text] ,++idx];
                
                request = [RSCoreAnalyzer requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://shell.renren.com/%@/status", [_analyzer userId]]] postInfomation:token];
                NSError *error = nil;
                NSHTTPURLResponse *httpResponse = nil;
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&error];
                if ([httpResponse statusCode] != 200)
                {
                    success = NO;
                    break;
                }
                data = nil;
                [NSThread sleepForTimeInterval:1000];
            }
            [self setTitle:orgTitle];
            if (!success)
            {
                [RSProgressHUD showErrorWithStatus:@"Request Failed"];
            }
            else
            {
                [RSProgressHUD showSuccessWithStatus:@"Success"];
            }
            return;
        });
        
    }
    token[@"content"] = [[self statusContent] text];
    NSLog(@"token = %@", token);
    request = [RSCoreAnalyzer requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://shell.renren.com/%@/status", [_analyzer userId]]] postInfomation:token];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ([httpResponse statusCode] != 200)
        {
            [RSProgressHUD showErrorWithStatus:@"Request failed"];
            return;
        }
        [[self navigationController] popToViewController:_parent animated:YES];
        [RSProgressHUD showSuccessWithStatus:@"Success"];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_tapGestureHideKeyboard:(UIGestureRecognizer *)gesture
{
    [[self statusContent] resignFirstResponder];
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
        [self sendBtnPressed:self];
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

@end
