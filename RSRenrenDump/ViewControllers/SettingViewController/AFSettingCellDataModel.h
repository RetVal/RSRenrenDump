//
//  AFSettingCellDataModel.h
//  Note
//
//  Created by RetVal on 9/11/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AFSettingCellDataModel : NSObject

@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, strong) NSString * cellStyle;
@property (nonatomic, strong) NSString * displayDescription;
@property (nonatomic, strong) UIImage * icon;
@property (nonatomic, strong) id pushTo;
@property (nonatomic, assign, getter = isEnable) BOOL enable;

- (id)initWithDictionary:(NSDictionary *)dict;
@end

FOUNDATION_EXPORT const NSString * AFCellSwitchStyle;
FOUNDATION_EXPORT const NSString * AFCellPushStyle;