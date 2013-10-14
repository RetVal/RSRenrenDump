//
//  RSLikeModel.m
//  RSDumpRenren
//
//  Created by RetVal on 10/9/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSLikeModel.h"

NSString * const RSRenrenAddLike = @"addlike";
NSString * const RSRenrenRemoveLike = @"removelike";

@implementation RSLikeModel

/*  share
 *  event id
 *  user id(host)
 *  owner id
 *  name
 */
- (id)initWithContent:(NSString *)content mode:(NSString *)mode
{
    const char *ptr = [content UTF8String];
    if (!content || *ptr != '(' || ![content hasSuffix:@")"]) return nil;
    if (self = [super init])
    {
        _mode = mode;
        _container = [[NSMutableArray alloc] initWithCapacity:5];
        ptr++;  // skip (
        unsigned int count = 0;
        while (count < 5)
        {
            BOOL inside = NO;
            
            while (*ptr != '\'')
                ptr++;
            inside = YES;
            ptr++;
            char *end = (char *)ptr;
            while (*end != '\'')
                end ++;
            NSString *subContent = [[NSString alloc] initWithBytes:ptr length:end - ptr encoding:NSUTF8StringEncoding];
            _container[count] = subContent;
            end++;
            ptr = end;
            count++;
        }
    }
    return self;
}

- (void)action
{
    //    http://like.renren.com/addlike?gid=share_16473280745&uid=340278563&owner=353220347&type=3&name=%E8%83%A1%E6%80%9D%E5%8D%8E.c&t=0.7837001783773303
    NSString *urlFormat = [[NSString stringWithFormat:@"http://like.renren.com/%@?gid=%@_%@&uid=%@&owner=%@&type=%@&name=%@", _mode, _container[0], _container[1], _container[2], _container[3], @3, _container[4]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLResponse *response = nil;
    NSData *data = nil;
    NSError *error = nil;
    //    NSLog(@"%@", urlFormat);
    data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlFormat]] returningResponse:&response error:&error];
    if (error)
    {
        NSLog(@"%@", error);
        return ;
    }
    if (!data) return;
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (str) NSLog(@"json result string = %@", str);
    //    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    //    NSLog(@"json = %@", json);
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ([httpResponse statusCode] == 200)
    {
        NSLog(@"success");
    }
    return;
    //    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlFormat]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
    //        if (error)
    //        {
    //            NSLog(@"%@", error);
    //            return ;
    //        }
    //        if (!data) return;
    //        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    //        NSLog(@"json = %@", json);
    //        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    //        if ([httpResponse statusCode] == 200)
    //        {
    //            NSLog(@"success");
    //        }
    //    }];
}

- (NSString *)type
{
    return [[NSString alloc] initWithFormat:@"%@ - %@", _container[0], _container[1]];
}

- (NSString *)description
{
    return [_container description];
}

- (id)userInfo
{
    return _container[3];
}
@end
