//
//  main.m
//  rp
//
//  Created by Closure on 11/27/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//
#import <RSRenrenCore/RSRenrenCore.h>

@interface RSRenrenRP : NSObject <RSCoreAnalyzerDelegate>
@property (nonatomic, strong) RSAccount *account;
@property (nonatomic, strong) RSCoreAnalyzer *analyzer;
@end

@implementation RSRenrenRP

- (id)initWithAccount:(RSAccount *)account {
    if (self = [super init]) {
        _account = account;
        _analyzer = [RSCoreAnalyzer analyzerWithAccount:[_account accountId] password:[account password]];
        [_analyzer setDelegate:self];
    }
    return self;
}

- (void)run {
    [_analyzer startLogin];
}

- (void)analyzerLoginSuccess:(RSCoreAnalyzer *)analyzer {
    NSLog(@"login success");
    [analyzer getRP];
    NSString *url = [[NSString alloc] initWithFormat:@"http://www.renren.com/%@", [_analyzer userId]];
    while (1) {
        @autoreleasepool {
            NSURLResponse *response = nil;
            NSError *error = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] returningResponse:&response error:&error];
            if (data && [(NSHTTPURLResponse *)response statusCode]) NSLog(@"success");
        }
        sleep(30 * 60);
    }
    return;
}

- (void)analyzer:(RSCoreAnalyzer *)analyzer LoginFailedWithError:(NSError *)error {
    NSLog(@"login failed.");
    exit(0);
}
@end

int main(int argc, const char * argv[])
{
    if (argc != 3) {
        NSLog(@"rp email-address password");
        return -1;
    }
    @autoreleasepool {
        RSRenrenRP *rp = [[RSRenrenRP alloc] initWithAccount:[[RSAccount alloc] initWithAccountId:[NSString stringWithUTF8String:argv[1]] password:[NSString stringWithUTF8String:argv[2]]]];
        [rp run];
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
