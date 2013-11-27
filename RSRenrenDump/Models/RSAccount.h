//
//  RSAccount.h
//  RSRenrenDump
//
//  Created by RetVal on 5/27/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_MAC
@class NSImage;
#endif
@interface RSAccount : NSObject <NSCoding>
@property (nonatomic, strong) NSString *accountId;
@property (nonatomic, strong) NSString *password;
#if TARGET_OS_IPHONE
@property (nonatomic, strong) UIImage *headIcon;
#elif TARGET_OS_MAC
@property (nonatomic, strong) NSImage *headIcon;
#endif
- (id)initWithAccountId:(NSString *)accountId password:(NSString *)password;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;
@end
