//
//  AFSettingTableViewCell.m
//  Note
//
//  Created by RetVal on 9/11/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "AFSettingTableViewCell.h"
#import "AFSettingCellDataModel.h"

@implementation AFSettingTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier model:(id)model
{
    BOOL custom = NO;
    if ([AFCellSwitchStyle isEqualToString:[model cellStyle]])
    {
        custom = YES;
    }
    else if ([AFCellPushStyle isEqualToString:[model cellStyle]])
    {
        style = UITableViewCellStyleValue1;
    }
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        [self setModel:model];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier model:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

- (void)setModel:(id)model
{
    _model = model;
    [self __apply];
}

- (id)model
{
    return _model;
}

- (void)__apply
{
    if (_model && [_model isKindOfClass:[AFSettingCellDataModel class]])
    {
        AFSettingCellDataModel *dm = (AFSettingCellDataModel *)_model;
        if ([AFCellSwitchStyle isEqualToString:[dm cellStyle]])
        {
            UISwitch *switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [switchBtn setOn:YES];
            [switchBtn addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            [self setAccessoryView:switchBtn];
        }
        else if ([AFCellPushStyle isEqualToString:[dm cellStyle]])
        {
            [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        else if ([AFCellBottonStyle isEqualToString:[dm cellStyle]])
        {
//            [[self contentView] addSubview:[_model pushTo]];
            if ([dm displayName]) [[self textLabel] setText:[dm displayName]];
            return;
        }
        if ([dm icon]) [[self imageView] setImage:[dm icon]];
        if ([dm displayName]) [[self textLabel] setText:[dm displayName]];
        if ([dm displayDescription]) [[self detailTextLabel] setText:[dm displayDescription]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)switchChanged: (UISwitch *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(switchChanged:)]) [_delegate switchChanged:sender];
}
@end
