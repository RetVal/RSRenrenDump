//
//  RSZhenYiYueViewController.m
//  RSRenren
//
//  Created by RetVal on 10/10/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSZhenYiYueViewController.h"
#import "RSCoreAnalyzer.h"
#import "RSSharedDataBase.h"
#import "RSRemoteDataBase.h"
#import "RSBaseModel.h"
#import "RSLikeModel.h"
#import "RSProgressHUD.h"

@interface RSZhenYiYueViewController ()
{
    RSCoreAnalyzer *_analyzer;
}

@end

@implementation RSZhenYiYueViewController

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
    _analyzer = [[RSSharedDataBase sharedInstance] currentAnalyzer];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)zanSliderValueChanged:(UISlider *)sender {
    [_itemsNumber setText: [[NSString alloc] initWithFormat:@"%d", (NSUInteger)[sender value]]];
}

- (IBAction)zan:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [RSProgressHUD showProgress:-1.0f status:@"Zaning..." maskType:RSProgressHUDMaskTypeGradient];
        NSUInteger begin = 0;
        NSUInteger limit = 50;
        NSUInteger count = 0;
        NSUInteger turn = [[_itemsNumber text] integerValue] / 50 + 1;
        BOOL shouldContinue = YES;
        NSMutableArray *models = [[NSMutableArray alloc] init];
        while (shouldContinue)
        {
            if (count > turn) shouldContinue = NO;
            NSURLResponse *response = nil;
            NSData *data = nil;
            NSError *error = nil;
            //333092533
            data = [NSURLConnection sendSynchronousRequest:[RSRemoteDataBase remoteUpdateUser:[_model account] count:count analyer:_analyzer] returningResponse:&response error:&error];  // 个人主页 朕已阅
//            data = [RSRemoteDataBase remoteSyncInvokeUpdatePage:begin limit:limit count:count analyer:_analyzer response:&response error:&error]; // 新鲜事 朕已阅
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if ([httpResponse statusCode] == 200)
                [models addObjectsFromArray:[_analyzer analyzeLikeModelWithData:data mode:RSRenrenAddLike]];
            else
                shouldContinue = NO;
            count++;
            begin += limit;
            [NSThread sleepForTimeInterval:1.25];
        }
        if ([models count])
        {
            [models enumerateObjectsUsingBlock:^(RSLikeModel *obj, NSUInteger idx, BOOL *stop) {
                [obj action];
                [NSThread sleepForTimeInterval:2];
            }];
            [RSProgressHUD dismiss];
            NSLog(@"end");
            return ;
        }
        [RSProgressHUD dismiss];
    });
}
@end
