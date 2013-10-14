//
//  RSAccount.h
//  RSRenrenDump
//
//  Created by RetVal on 5/27/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSAccount : NSObject <NSCoding>
@property (nonatomic, strong) NSString *accountId;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) UIImage *headIcon;
- (id)initWithAccountId:(NSString *)accountId password:(NSString *)password;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;
@end
