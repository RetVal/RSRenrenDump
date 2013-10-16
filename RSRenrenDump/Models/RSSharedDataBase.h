//
//  RSSharedDataBase.h
//  RSRenren
//
//  Created by RetVal on 10/10/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RSAccount, RSCoreAnalyzer;
@interface RSSharedDataBase : NSObject <NSCoding>
@property (atomic, strong) RSAccount *currentLoginAccount;
@property (atomic, strong) RSCoreAnalyzer *currentAnalyzer;
@property (nonatomic, strong, readonly) NSDictionary *settingPreferences;
+ (id)sharedInstance;
@end
