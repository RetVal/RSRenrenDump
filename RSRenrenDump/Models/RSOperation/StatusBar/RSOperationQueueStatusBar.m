//
//  RSOperationQueueStatusBar.m
//  RSRenren
//
//  Created by Closure on 10/18/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSOperationQueueStatusBar.h"
static RSOperationQueueStatusBar *__RSShreadOperationQueueStatusBar;

@interface RSOperationQueueStatusBar ()
{
    UIActivityIndicatorView *_indicator;
}
@end

@implementation RSOperationQueueStatusBar
+ (id)sharedStatusBar
{
    @synchronized(__RSShreadOperationQueueStatusBar)
    {
        if (!__RSShreadOperationQueueStatusBar)
            __RSShreadOperationQueueStatusBar = [[RSOperationQueueStatusBar alloc] init];
    }
    return __RSShreadOperationQueueStatusBar;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        // Place the window on the correct level & position
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;
        self.frame = [UIApplication sharedApplication].statusBarFrame;
        
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.frame = (CGRect){.origin.x = 2.0f, .origin.y = 3.0f, .size.width = self.frame.size.height - 6, .size.height = self.frame.size.height - 6};
        _indicator.hidesWhenStopped = YES;
        [self addSubview:_indicator];
        
        _statusLabel = [[UILabel alloc] initWithFrame:(CGRect){.origin.x = self.frame.size.height, .origin.y = 0.0f, .size.width = 200.0f, .size.height = self.frame.size.height}];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.textColor = [UIColor blackColor];
        _statusLabel.font = [UIFont boldSystemFontOfSize:10.0f];
        [self addSubview:_statusLabel];
    }
    return self;
}

- (void)_init
{
    UIStatusBarStyle statusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    if (statusBarStyle == UIStatusBarStyleDefault)
    {
        [self setBackgroundColor:[UIColor blackColor]];
        _statusLabel.textColor = [UIColor whiteColor];
        _statusLabel.backgroundColor= [UIColor clearColor];
    }
    else
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        _statusLabel.textColor= [UIColor blackColor];
        _statusLabel.backgroundColor= [UIColor whiteColor];
    }
    [self setWindowLevel:UIWindowLevelStatusBar + 1.0f];
}

- (void)showWithMessage:(NSString *)message
{
    if ([message isEqualToString:[_statusLabel text]])
        return;
    [self setHidden:NO];
    [self setAlpha:1.0];
    
    CGSize totalSize = self.frame.size;
    self.frame = (CGRect){ self.frame.origin, 0, totalSize.height };
    [UIView animateWithDuration:0.5f animations:^{
        self.frame = (CGRect){ self.frame.origin, totalSize };
    } completion:^(BOOL finished){
        [_statusLabel setText:message];
    }];
}

- (void)hide
{
    self.alpha = 1.0f;
    
    [UIView animateWithDuration:0.5f animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished){
        _statusLabel.text = nil;
        self.hidden = YES;
    }];;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
