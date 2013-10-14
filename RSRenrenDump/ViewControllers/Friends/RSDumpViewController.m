//
//  RSDumpViewController.m
//  RSRenrenDump
//
//  Created by RetVal on 5/26/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSDumpViewController.h"
#import "RSCoreAnalyzer.h"
#import "RSAccount.h"
#import "RSFriendInfoTableViewController.h"
#import "RSSharedDataBase.h"
#import "RSProgressHUD.h"

@interface RSDumpViewController () <RSCoreAnalyzerDelegate>
{
    @private
    RSCoreAnalyzer *_analyzer;
    RSAccount *_account;
    NSMutableArray *_results;
}
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end

@implementation RSDumpViewController

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
    
    NSLog(@"%@", _account);
    _analyzer = [[RSSharedDataBase sharedInstance] currentAnalyzer];
    if (!_analyzer)
    {
        [self _prepare];
        _analyzer = [RSCoreAnalyzer analyzerWithAccount:[_account accountId] password:[_account password]];
        [_analyzer setDelegate:self];
        [_analyzer startLogin];
    }
    else
    {
        [self performSelectorInBackground:@selector(_dumpFriendList) withObject:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self _cleanup];
    [self performSelectorInBackground:@selector(_dumpFriendList) withObject:nil];
}

- (void)analyzer:(RSCoreAnalyzer *)analyzer LoginFailedWithError:(NSError *)error
{
    [self _cleanup];
    NSLog(@"%@", error);
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)_dumpFriendList
{
    [RSProgressHUD showProgress:0 status:@"Loading..." maskType:RSProgressHUDMaskTypeGradient];
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
            [_results addObject:x];        }
        [RSProgressHUD showProgress:delta * count status:@"Loading..." maskType:RSProgressHUDMaskTypeGradient];
        NSLog(@"\n************count = %4ld, pageNumber = %4ld, sum of friends = %4ld************\n", (unsigned long)count, (unsigned long)pageNumber, (unsigned long)numberOfFriends);
    } while (numberOfFriends > count);
    NSLog(@"%@", _results);
    [RSProgressHUD dismiss];
    [self performSegueWithIdentifier:@"segueForFriendList" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segueForFriendList"])
    {
        RSFriendInfoTableViewController *desVC = [segue destinationViewController];
        [desVC setFriends:_results];
    }
}

@end
