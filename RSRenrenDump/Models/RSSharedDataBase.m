//
//  RSSharedDataBase.m
//  RSRenren
//
//  Created by RetVal on 10/10/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSSharedDataBase.h"
static RSSharedDataBase *sdb = nil;
@implementation RSSharedDataBase
+ (void)load
{
    [RSSharedDataBase sharedInstance];
}

+ (id)sharedInstance
{
    if (!sdb) sdb = [[RSSharedDataBase alloc] init];
    return sdb;
}

- (id)init
{
    if (sdb) return sdb;
    if (self = [super init])
        sdb = self;
    return sdb;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_currentLoginAccount forKey:@"loginAccount"];
    [aCoder encodeObject:_currentAnalyzer forKey:@"analyzer"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        _currentLoginAccount = [aDecoder decodeObjectForKey:@"loginAccount"];
        _currentAnalyzer = [aDecoder decodeObjectForKey:@"analyzer"];
    }
    return self;
}
@end
