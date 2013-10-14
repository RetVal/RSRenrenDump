//
//  RSRemoteDataBase.m
//  RSDumpRenren
//
//  Created by RetVal on 10/9/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSRemoteDataBase.h"
#import "RSCoreAnalyzer.h"
#import "RSLikeModel.h"

static NSString * const __kRemoteUpdateServer = @"http://www.renren.com/feedretrieve3.do";
static NSString * const __kShabi = @"http://www.renren.com/moreminifeed.do";
static NSString * const __shabiID = @"333092533";
@implementation RSRemoteDataBase
+ (id)remoteUpdatePage:(NSUInteger)begin limit:(NSUInteger)limit count:(NSUInteger)count analyer:(id)analyer
{
    if (!analyer || ![analyer isKindOfClass:[RSCoreAnalyzer class]]) return nil;
    NSUInteger p = count;
    //    NSMutableURLRequest *request = (NSMutableURLRequest*)[RSCoreAnalyzer requestWithURL:[NSURL URLWithString:__kRemoteUpdateServer] postInfomation: @{@"p": @(p), @"u" : __shabiID, @"requestToken":[analyer token][@"requestToken"], @"_rtk":[analyer token][@"_rtk"]}];
    //
    //    [request setValue:[NSString stringWithFormat:@"http://www.renren.com/%@/profile", __shabiID] forHTTPHeaderField:@"Referer"];
    NSURLRequest *request = [RSCoreAnalyzer requestWithURL:[NSURL URLWithString:__kRemoteUpdateServer] postInfomation: @{@"p": @(p), @"begin": @(begin), @"limit":@(limit), @"requestToken":[analyer token][@"requestToken"], @"_rtk":[analyer token][@"_rtk"]}];
    return request;
}

+ (id)remoteUpdateUser:(NSString *)uid count:(NSUInteger)count analyer:(id)analyer
{
    // http://www.renren.com/moreminifeed.do?p=1&u=333092533&requestToken=1330581667&_rtk=1b100efd
    if (!analyer || ![analyer isKindOfClass:[RSCoreAnalyzer class]]) return nil;
    id token = [analyer token];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.renren.com/moreminifeed.do?p=%@&u=%@&requestToken=%@&_rtk=%@", @(count), uid, token[@"requestToken"], token[@"_rtk"]]]];
    return request;
}

+ (void)remoteInvokeUpdatePage:(NSUInteger)begin limit:(NSUInteger)limit count:(NSUInteger)count analyer:(id)analyer complete:(void(^)(NSURLResponse *response, NSData *data, NSError *error))complete
{
    NSURLRequest *request = [RSRemoteDataBase remoteUpdatePage:begin limit:limit count:count analyer:analyer];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:complete];
}

+ (NSData *)remoteSyncInvokeUpdatePage:(NSUInteger)begin limit:(NSUInteger)limit count:(NSUInteger)count analyer:(id)analyer response:(NSURLResponse **)response error:(NSError **)error
{
    NSURLRequest *request = [RSRemoteDataBase remoteUpdatePage:begin limit:limit count:count analyer:analyer];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:response error:error];
    return data;
}

+ (id)remoteDataBaseAddLikeToUser:(NSString *)user count:(NSUInteger)cnt analyzer:(id)analyzer
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger begin = 0;
        NSUInteger limit = 50;
        NSUInteger count = 0;
        BOOL shouldContinue = YES;
        NSMutableArray *models = [[NSMutableArray alloc] init];
        while (shouldContinue)
        {
            if (count > cnt) shouldContinue = NO;
            NSURLResponse *response = nil;
            NSData *data = nil;
            NSError *error = nil;
            //333092533
            data = [NSURLConnection sendSynchronousRequest:[RSRemoteDataBase remoteUpdateUser:user count:count analyer:analyzer] returningResponse:&response error:&error];  // 个人主页 朕已阅
            //            data = [RSRemoteDataBase remoteSyncInvokeUpdatePage:begin limit:limit count:count analyer:_analyzer response:&response error:&error]; // 新鲜事 朕已阅
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if ([httpResponse statusCode] == 200)
                [models addObjectsFromArray:[analyzer analyzeLikeModelWithData:data mode:RSRenrenAddLike]];
            else
                shouldContinue = NO;
            count++;
            begin += limit;
            [NSThread sleepForTimeInterval:1.25];
        }
        NSLog(@"%@", models);
        return;
        if ([models count])
        {
            
            [models enumerateObjectsUsingBlock:^(RSLikeModel *obj, NSUInteger idx, BOOL *stop) {
                [obj action];
                [NSThread sleepForTimeInterval:2];
            }];
            NSLog(@"end");
        }
    });
    return nil;
}
@end