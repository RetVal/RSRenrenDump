//
//  RSSharedDataBase.m
//  RSRenren
//
//  Created by RetVal on 10/10/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSSharedDataBase.h"
#import "RSAccount.h"
static RSSharedDataBase *sdb = nil;

@interface RSSharedDataBase()
{
    RSAccount *_currentLoginAccount;
    NSDictionary *_settingPreferences;
}
@end

@implementation RSSharedDataBase
@synthesize currentLoginAccount = _currentLoginAccount;
+ (void)load
{
    [RSSharedDataBase sharedInstance];
}

+ (id)sharedInstance
{
    if (!sdb) sdb = [[RSSharedDataBase alloc] init];
    return sdb;
}

- (NSString *)verifyAccountPath
{
    NSString *path = [[NSString alloc] initWithFormat:@"%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSAllDomainsMask, YES)[0], @"Account"];
    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory)
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}

- (id)init
{
    if (sdb) return sdb;
    if (self = [super init])
    {
        sdb = self;
        NSString *path = [self verifyAccountPath];
        BOOL isDirectory = NO;
        NSString *lastLogin = [NSString stringWithFormat:@"%@/%@", path, @"last.login.plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:lastLogin isDirectory:&isDirectory] && !isDirectory)
        {
            RSAccount *account = [NSKeyedUnarchiver unarchiveObjectWithFile:lastLogin];
            if (account)
                _currentLoginAccount = account;
        }
    }
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

- (RSAccount *)currentLoginAccount
{
    return _currentLoginAccount;
}

- (void)setCurrentLoginAccount:(RSAccount *)currentLoginAccount
{
    _currentLoginAccount = currentLoginAccount;
    if (!_currentLoginAccount) return;
    NSString *path = [self verifyAccountPath];
    NSString *writePath = [NSString stringWithFormat:@"%@/%@", path, @"last.login.plist"];
    [NSKeyedArchiver archiveRootObject:_currentLoginAccount toFile:writePath];
}

- (NSDictionary *)settingPreferences
{
    if (!_settingPreferences)
    {
        @synchronized(_settingPreferences)
        {
            _settingPreferences = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SettingPreferences" ofType:@"plist"]];
        }
    }
    return _settingPreferences;
}
@end
