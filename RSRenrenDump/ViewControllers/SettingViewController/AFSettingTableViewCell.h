//
//  AFSettingTableViewCell.h
//  Note
//
//  Created by RetVal on 9/11/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AFSettingTableViewCellSwitchDelegate;
@interface AFSettingTableViewCell : UITableViewCell
{
    id _model;
}
@property (nonatomic, weak) id<AFSettingTableViewCellSwitchDelegate> delegate;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier model:(id)model;
- (void)setModel:(id)model;
- (id)model;
@end

@protocol AFSettingTableViewCellSwitchDelegate <NSObject>
@optional
- (void)switchChanged:(UISwitch *)sender;
@end