//
//  AFSettingCellDataModel.m
//  Note
//
//  Created by RetVal on 9/11/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "AFSettingCellDataModel.h"
#include <objc/objc.h>
#include <objc/runtime.h>
#include <objc/message.h>

#import "RSSharedDataBase.h"
#import "_RSStoreCache.h"
#import "RSCoreAnalyzer.h"
#import "RSProgressHUD.h"

const NSString * AFSettingCellTouchable = @"touchable";
const NSString * AFSettingCellName = @"name";
const NSString * AFSettingCellIcon = @"icon";
const NSString * AFSettingCellPushTo = @"pushTo";
const NSString * AFSettingCellAction = @"action";
const NSString * AFSettingCellDescription = @"description";


#pragma mark -
#pragma mark AFCellStyle

const NSString * AFCellSwitchStyle = @"SwitchStyle";
const NSString * AFCellPushStyle = @"PushStyle";
const NSString * AFCellBottonStyle = @"BottonStyle";

const NSString * AFSettingCellStyle = @"cellStyle";
@implementation AFSettingCellDataModel
- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init])
    {
        id value = dict[AFSettingCellTouchable];
        if (value == nil || NO == [value boolValue]) _enable = NO;
        else _enable = YES;
        _displayName = dict[AFSettingCellName];
        if ((value = dict[AFSettingCellIcon]) && [value length]) _icon = [UIImage imageNamed:value];
        if ((value = dict[AFSettingCellStyle]))
        {
            _cellStyle = value;
            if ([AFCellPushStyle isEqualToString:value])
            {
                if ((value = dict[AFSettingCellPushTo]))
                {
                    UIStoryboard *st = [UIStoryboard storyboardWithName:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
                    id viewController = [st instantiateViewControllerWithIdentifier:value];
                    if (viewController) _pushTo = viewController;
                    else _pushTo = [[NSClassFromString(value) alloc] init];
                    
                    if (!_pushTo) [NSException raise:NSInvalidArgumentException format:@"PushTo style must have push to view controller"];
                }
            }
            else if ([AFCellBottonStyle isEqualToString:value])
            {
                SEL selector = NSSelectorFromString(dict[AFSettingCellAction]);
                if (!selector)
                {
                    [NSException raise:NSInvalidArgumentException format:@"action must not be nil"];
                }
                [self setPushTo:dict[AFSettingCellAction]];
            }
        }
        _displayDescription = dict[AFSettingCellDescription];

    }
    return self;
}

- (NSString *)description
{
    return [@{AFSettingCellTouchable: @([self isEnable]), AFSettingCellName: [self displayName], AFSettingCellIcon: [self icon], AFSettingCellPushTo : [self pushTo], AFSettingCellDescription : [self description], AFSettingCellStyle : [self cellStyle]} description];
}

- (void)__model_cleanup_cache:(id)sender
{
    NSLog(@"action %@", NSStringFromSelector(_cmd));
    [RSProgressHUD showProgress:-1.0f status:@"Cleanning up" maskType:RSProgressHUDMaskTypeGradient];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSDictionary *cachePreferences = [[RSSharedDataBase sharedInstance] settingPreferences][@"Cache"];
        [[NSFileManager defaultManager] removeItemAtPath:[[NSString alloc] initWithFormat:@"%@/%@/%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSAllDomainsMask, YES)[0], cachePreferences[@"AccountName"], [[[RSSharedDataBase sharedInstance] currentAnalyzer] userId], cachePreferences[@"FriendsCache"]] error:nil];
        [NSThread sleepForTimeInterval:1.5];
        dispatch_async(dispatch_get_main_queue(), ^{
            [RSProgressHUD dismiss];
            [RSProgressHUD showSuccessWithStatus:@"Done"];
        });
    });
}
@end
