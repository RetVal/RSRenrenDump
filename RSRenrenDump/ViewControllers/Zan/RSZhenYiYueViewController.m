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

@interface RSZhenYiYueViewController ()

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
@end
