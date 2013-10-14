//
//  RSAccount.m
//  RSRenrenDump
//
//  Created by RetVal on 5/27/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSAccount.h"

@implementation RSAccount
- (id)initWithAccountId:(NSString *)accountId password:(NSString *)password
{
    if (self = [super init])
    {
        _accountId = accountId;
        _password = password;
    }
    return self;
}

- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"%@, %@", _accountId, _password];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        _accountId = [aDecoder decodeObjectForKey:@"account"];
        _password = [aDecoder decodeObjectForKey:@"password"];
        _headIcon = [aDecoder decodeObjectForKey:@"headIcon"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_accountId forKey:@"account"];
    [aCoder encodeObject:_password forKey:@"password"];
    [aCoder encodeObject:_headIcon forKey:@"headIcon"];
}
@end
