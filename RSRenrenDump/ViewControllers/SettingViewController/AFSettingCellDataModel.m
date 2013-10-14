//
//  AFSettingCellDataModel.m
//  Note
//
//  Created by RetVal on 9/11/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "AFSettingCellDataModel.h"

const NSString * AFSettingCellTouchable = @"touchable";
const NSString * AFSettingCellName = @"name";
const NSString * AFSettingCellIcon = @"icon";
const NSString * AFSettingCellPushTo = @"pushTo";
const NSString * AFSettingCellDescription = @"description";

#pragma mark -
#pragma mark AFCellStyle

const NSString * AFCellSwitchStyle = @"SwitchStyle";
const NSString * AFCellPushStyle = @"PushStyle";

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
        }
        _displayDescription = dict[AFSettingCellDescription];

    }
    return self;
}

- (NSString *)description
{
    return [@{AFSettingCellTouchable: @([self isEnable]), AFSettingCellName: [self displayName], AFSettingCellIcon: [self icon], AFSettingCellPushTo : [self pushTo], AFSettingCellDescription : [self description], AFSettingCellStyle : [self cellStyle]} description];
}
@end
