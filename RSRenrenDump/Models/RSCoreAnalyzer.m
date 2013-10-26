//
//  RSCoreAnalyzer.m
//  RSDumpRenren
//
//  Created by RetVal on 5/23/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSCoreAnalyzer.h"
#import "RSBaseModel.h"
#include <pthread.h>
#import "RSLikeModel.h"
#import "RSAlbumLibrary.h"
#import "RSAccount.h"
#import "RSSharedDataBase.h"
#import "RSRemoteDataBase.h"

@implementation NSString (StringRegular)

- (NSMutableArray *)substringByRegular:(NSString *)regular
{
    NSString * reg=regular;
    NSRange r = [self rangeOfString:reg options:NSRegularExpressionSearch];
    NSMutableArray *arr=[NSMutableArray array];
    if (r.length != NSNotFound &&r.length != 0)
    {
        while (r.length != NSNotFound &&r.length != 0)
        {
            NSString* substr = [self substringWithRange:r];
            [arr addObject:substr];
            NSRange startr=NSMakeRange(r.location+r.length, [self length]-r.location-r.length);
            r = [self rangeOfString:reg options:NSRegularExpressionSearch range:startr];
        }
    }
    return arr;
}
@end

@interface RSCoreAnalyzer() <NSURLConnectionDataDelegate>
{
    id _obj;
    NSURLConnection *_connection;
    NSXMLDocument *_document;

    NSString *_userId;
    id _token;
    BOOL _login;
}
@end
@implementation RSCoreAnalyzer
+ (NSString *)buildURLStringWithBase:(NSString *)baseString domain:(NSString *)domain account:(NSString *)account password:(NSString *)password
{
    static NSString * const _append = @"&";
    static NSString * const _origURL = @"origURL=";
    static NSString * const _domain = @"domain=";
    static NSString * const _password = @"password=";
    static NSString * const _account = @"email=";
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@", _origURL, baseString, _append, _domain, domain, _append, _password, password, _append, _account, account];
    return urlString;//[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}

- (void)startLogin
{
    if (pthread_main_np()) [_connection start];
    else dispatch_async(dispatch_get_main_queue(), ^{
        [_connection start];
    });
}

+ (id)analyzerWithAccount:(NSString *)email password:(NSString *)password
{
    RSCoreAnalyzer *analyzer = [[RSCoreAnalyzer alloc] init];
    if (email == nil || password == nil) return NO;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.renren.com/PLogin.do"]];
    NSString *post = [self buildURLStringWithBase:@"http://www.renren.com/SysHome.do" domain:@"renren.com" account:email password:password];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%ld", (unsigned long)[postData length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    analyzer->_connection = [[NSURLConnection alloc] initWithRequest:request delegate:analyzer];
    return analyzer;
}

- (void)setDataToAnalyze:(NSData *)object
{
    _obj = object;
}

- (void)setURLToAnalyze:(NSURL *)URL
{
    _obj = URL;
}

- (id)startAnalyze
{
    if ([_obj isKindOfClass:[NSData class]])
        _document = [[NSXMLDocument alloc] initWithData:_obj options:NSXMLDocumentTidyHTML error:nil];
    else if ([_obj isKindOfClass:[NSURL class]])
        _document = [[NSXMLDocument alloc] initWithContentsOfURL:_obj options:NSXMLDocumentTidyHTML error:nil];
    return _document;
}

- (id)_analyzeFriendForAvatar:(NSXMLElement *)avatar
{
    NSMutableDictionary *avatarInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    NSXMLElement *a = [[avatar elementsForName:@"a"] lastObject];
    NSXMLNode *href = [a attributeForName:@"href"];
    
    [avatarInfo setObject:[href objectValue] forKey:_kCAHomePageLinkKey];
    
    NSXMLElement *img = [[a elementsForName:@"img"] lastObject];
    NSXMLNode *src = [img attributeForName:@"src"];
    
    [avatarInfo setObject:[src objectValue] forKey:_kCAHeadImageLinkKey];
    return avatarInfo;
}

- (id)_analyzeFriendForInfo:(NSXMLElement *)info
{
    NSMutableDictionary *infoInfo = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSXMLElement *dl = [[info elementsForName:@"dl"] lastObject];
    NSXMLElement *dd = [dl elementsForName:@"dd"][0];
    NSXMLElement *dd_location = [[dl elementsForName:@"dd"] lastObject];
    
    NSXMLElement *a = [[dd elementsForName:@"a"] lastObject];
    NSXMLNode *href __unused = [a attributeForName:@"href"];
    
    if (dd_location && NO == [dd isEqual:dd_location])
    {
        [infoInfo setObject:[a objectValue] forKey:_kCANameKey];
        [infoInfo setObject:[[dd_location objectValue] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] forKey:_kCASchoolKey];
    }
    else
    {
        [infoInfo setObject:[a objectValue] forKey:_kCANameKey];
    }
    
    return infoInfo;
}

- (id)_analyzeFriendForActions:(NSXMLElement *)actions
{
    return nil;
}

- (NSString *)_analyzeFriendForAccountId:(RSBaseModel *)model
{
    NSString *homelink = [[model homePageURL] absoluteString];
    NSString *userId = nil;
    if ([homelink hasPrefix:@"http://www.renren.com/profile.do?id="])
        userId = [[homelink mutableCopy] stringByReplacingOccurrencesOfString:@"http://www.renren.com/profile.do?id=" withString:@""];
    else
        userId = nil;
    return userId;
}

static NSString * const __kCAFilterNameKey = @"key";
static NSString * const __kCAFilterValueKey = @"value";

- (NSXMLElement *)__findSubElement:(NSXMLElement *)parent WithName:(NSString *)name fitler:(NSDictionary *)filter
{
    if (parent == nil || name == nil || filter == nil) return nil;
    NSArray *subElements = [parent elementsForName:name];
    if (subElements == nil) return nil;
    NSArray *keys = filter[__kCAFilterNameKey];
    NSArray *values = filter[__kCAFilterValueKey];
    for (NSXMLElement *subElement in subElements) {
        NSMutableArray *subValues = [[NSMutableArray alloc] init];
        for (NSString *key in keys) {
            NSXMLNode *node = [subElement attributeForName:key];
            if (node == nil) break;
            [subValues addObject:[node objectValue]];
        }
        if ([subValues count])
        {
            if ([subValues isEqualToArray:values])
                return subElement;
        }
    }
    return nil;
}

- (NSUInteger)_analyzeUserPopularityOldStypleWithDocument:(NSXMLDocument *)document userId:(NSString *)userId
{
    if (document == nil) return 0;
    NSXMLElement *body = [[document rootElement] elementsForName:@"body"][0];
    
    NSXMLElement *containerDiv = [self __findSubElement:body WithName:@"div" fitler:@{__kCAFilterNameKey  : @[@"id"], __kCAFilterValueKey : @[@"container-for-buddylist"]}];
    if (containerDiv)
    {
        NSXMLElement *opi = [self __findSubElement:containerDiv WithName:@"div" fitler:@{__kCAFilterNameKey : @[@"id"], __kCAFilterValueKey : @[@"opi"]}];
        if (opi)
        {
            NSXMLElement *full_page_holder = [self __findSubElement:opi WithName:@"div" fitler:@{__kCAFilterNameKey : @[@"class"], __kCAFilterValueKey : @[@"full-page-holder"]}];
            if (full_page_holder)
            {
                NSXMLElement *ajaxContainer = [self __findSubElement:full_page_holder WithName:@"div" fitler:@{__kCAFilterNameKey : @[@"id", @"class"], __kCAFilterValueKey : @[@"ajaxContainer", @"cols clearfix"]}];
                if (ajaxContainer)
                {
                    NSXMLElement *col_right = [self __findSubElement:ajaxContainer WithName:@"div" fitler:@{__kCAFilterNameKey : @[@"class"], __kCAFilterValueKey : @[@"col-right"]}];
                    if (col_right)
                    {
                        NSXMLElement *extra_side = [self __findSubElement:col_right WithName:@"div" fitler:@{__kCAFilterNameKey : @[@"class"], __kCAFilterValueKey : @[@"extra-side"]}];
                        if (extra_side)
                        {
                            NSXMLElement *visitors = [self __findSubElement:extra_side WithName:@"div" fitler:@{__kCAFilterNameKey : @[@"id", @"class"], __kCAFilterValueKey : @[@"visitors", @"mod"]}];
                            if (visitors)
                            {
                                NSXMLElement *mod_header = [self __findSubElement:visitors WithName:@"div" fitler:@{__kCAFilterNameKey : @[@"class"], __kCAFilterValueKey : @[@"mod-header"]}];
                                if (mod_header)
                                {
                                    NSXMLElement *mod_header_in = [self __findSubElement:mod_header WithName:@"div" fitler:@{__kCAFilterNameKey : @[@"class"], __kCAFilterValueKey : @[@"mod-header-in"]}];
                                    if (mod_header_in)
                                    {
                                        NSXMLElement *h4 = [mod_header_in elementsForName:@"h4"][0];
                                        NSXMLElement *span = [mod_header_in elementsForName:@"span"][0];
                                        if ([[h4 objectValue] isEqualToString:@"最近来访\n"] &&
                                            [[[span attributeForName:@"class"] objectValue] isEqualToString:@"count"] &&
                                            [[span objectValue] hasPrefix:@"("])
                                        {
                                            NSLog(@"%@ match", userId);
                                        }
                                        return [[[[[span objectValue] mutableCopy] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""] intValue];
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return 0;
}

- (NSUInteger)_analyzeUserPopularityTimelineStypleWithDocument:(NSXMLDocument *)document userId:(NSString *)userId
{
    if (document == nil) return 0;
    NSXMLElement *body = [[document rootElement] elementsForName:@"body"][0];
    
    NSXMLElement *containerDiv = [self __findSubElement:body WithName:@"div" fitler:@{__kCAFilterNameKey  : @[@"id"], __kCAFilterValueKey : @[@"container-for-buddylist"]}];
    
    if (containerDiv)
    {
        NSXMLElement *container = [self __findSubElement:containerDiv WithName:@"div" fitler:@{__kCAFilterNameKey : @[@"id"], __kCAFilterValueKey : @[@"container"]}];
        if (container)
        {
            NSXMLElement *profile_wrapper = [self __findSubElement:container WithName:@"div" fitler:@{__kCAFilterNameKey: @[@"id"], __kCAFilterValueKey : @[@"profile_wrapper"]}];
            if (profile_wrapper)
            {
                NSXMLElement *timeline_wrapper = [self __findSubElement:profile_wrapper WithName:@"div" fitler:@{__kCAFilterNameKey: @[@"id"], __kCAFilterValueKey : @[@"timeline_wrapper"]}];
                if (timeline_wrapper)
                {
                    NSXMLElement *timeline = [self __findSubElement:timeline_wrapper WithName:@"div" fitler:@{__kCAFilterNameKey: @[@"id"], __kCAFilterValueKey : @[@"timeline"]}];
                    if (timeline)
                    {
                        NSXMLElement *visit_special_con = [self __findSubElement:timeline WithName:@"div" fitler:@{__kCAFilterNameKey: @[@"class"], __kCAFilterValueKey : @[@"visit-special-con"]}];
                        if (visit_special_con)
                        {
                            NSXMLElement *footprint_box = [self __findSubElement:visit_special_con WithName:@"div" fitler:@{__kCAFilterNameKey: @[@"id", @"class"], __kCAFilterValueKey : @[@"footprint-box", @"clearfix"]}];
                            if (footprint_box)
                            {
                                NSXMLElement *h5 = [footprint_box elementsForName:@"h5"][0];
                                if ([[h5 objectValue] hasPrefix:@"最近来访 "])
                                    NSLog(@"%@ match", userId);
                                return [[[[h5 objectValue] mutableCopy] stringByReplacingOccurrencesOfString:@"最近来访 " withString:@""] intValue];
                            }
                        }
                    }
                }
            }
        }
    }
    return 0;
}

- (NSUInteger)analyzeUserPopularityWithUserId:(NSString *)userId
{
    if (userId == nil) return 0;
//    NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"instance-timeline" ofType:@"html"]] options:NSXMLDocumentTidyHTML error:nil];
//    [document setCharacterEncoding:@"utf-8"]; //NSWindowsCP1250Encoding
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:[RSCoreAnalyzer urlForCoreDumpPopularityWithUserId:userId] options:NSXMLDocumentTidyHTML error:nil];
    NSXMLElement *body = [[document rootElement] elementsForName:@"body"][0];
    
    NSXMLElement *containerDiv = [self __findSubElement:body WithName:@"div" fitler:@{__kCAFilterNameKey  : @[@"id"], __kCAFilterValueKey : @[@"container-for-buddylist"]}];
    
    if (containerDiv)
    {
        NSXMLElement *opi = [self __findSubElement:containerDiv WithName:@"div" fitler:@{__kCAFilterNameKey : @[@"id"], __kCAFilterValueKey : @[@"opi"]}];
        NSXMLElement *container = nil;
        if (opi == nil)
            container = [self __findSubElement:containerDiv WithName:@"div" fitler:@{__kCAFilterNameKey : @[@"id"], __kCAFilterValueKey : @[@"container"]}];
        if (opi == nil && container)
        {
            return [self _analyzeUserPopularityTimelineStypleWithDocument:document userId:userId];
        }
        else if (opi && container == nil)
        {
            return [self _analyzeUserPopularityOldStypleWithDocument:document userId:userId];
        }
    }
    return 0;
}

- (NSUInteger)_analyzeUserPopularityWithModel:(RSBaseModel *)model
{
    return [self analyzeUserPopularityWithUserId:[model account]];
}

- (id)analyzeFriend:(NSXMLElement *)friendInfo
{
    if (!friendInfo) return nil;
    NSXMLElement *avatar = [[friendInfo elementsForName:@"p"] lastObject];
    NSXMLElement *info = [[friendInfo elementsForName:@"div"] lastObject];
    NSXMLElement *actions = [[friendInfo elementsForName:@"ul"] lastObject];
    if (!avatar || !info || !actions) return nil;
    NSDictionary *avatarResult = [self _analyzeFriendForAvatar:avatar];
    NSDictionary *infoResult = [self _analyzeFriendForInfo:info];
    
    RSBaseModel *model = [[RSBaseModel alloc] init];
    [model setHomePageURL:[NSURL URLWithString:[avatarResult objectForKey:_kCAHomePageLinkKey]]];
    [model setImageURL:[NSURL URLWithString:[avatarResult objectForKey:_kCAHeadImageLinkKey]]];
    [model setName:[infoResult objectForKey:_kCANameKey]];
    [model setSchoolName:[infoResult objectForKey:_kCASchoolKey]];
    [model setAccount:[self _analyzeFriendForAccountId:model]];
    return model;
}

- (NSArray *)friendsElementFromDocument:(NSXMLDocument *)analyzeResult
{
    NSXMLElement *rootElement = [analyzeResult rootElement];
    NSXMLElement *bodyElement = [rootElement elementsForName:@"body"][0];
    
    NSXMLElement *containerDiv = [bodyElement elementsForName:@"div"][0];
    
    NSXMLElement *containerForBuddyListDiv = [containerDiv elementsForName:@"div"][3];
    NSXMLElement *contentDiv = [[[[[containerForBuddyListDiv elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0];

    NSXMLElement *stdContainerDiv = [contentDiv elementsForName:@"div"][1];
    
    NSXMLElement *list_resultDiv = [stdContainerDiv elementsForName:@"div"][1];
    
    NSXMLElement *friendListCon_s_ol __unused = [list_resultDiv elementsForName:@"ol"][0];
    NSXMLElement *friendListCon_ol = [list_resultDiv elementsForName:@"ol"][1];
    
    NSArray *friendInfos = [friendListCon_ol elementsForName:@"li"];
    return friendInfos;
}

- (NSUInteger)analyzeFriendNumberFromDocument:(NSXMLDocument *)analyzeResult
{
    NSXMLElement *rootElement = [analyzeResult rootElement];

    NSXMLElement *bodyElement = [rootElement elementsForName:@"body"][0];
    
    NSXMLElement *containerDiv = [bodyElement elementsForName:@"div"][0];
    
    NSXMLElement *containerForBuddyListDiv = [containerDiv elementsForName:@"div"][3];
    NSXMLElement *contentDiv = [[[[[containerForBuddyListDiv elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0];
    
    NSXMLElement *tocDiv = [contentDiv elementsForName:@"div"][0];
    NSXMLElement *p = [tocDiv elementsForName:@"p"][0];
    NSXMLElement *span = [p elementsForName:@"span"][0];
    NSUInteger cnt = [[span objectValue] intValue];
    return cnt;
}

- (id)userId
{
    return _userId;
}

- (NSMutableDictionary *)_statusTokenInfo
{
    NSString *str = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.renren.com/%@" ,[self userId]]] encoding:NSUTF8StringEncoding error:nil];
    NSString *requestToken = nil, *_rtk = nil;
    NSRange range = [str rangeOfString:@"get_check:'"];
    str = [str substringWithRange:NSMakeRange(range.location + range.length, [str length] - range.location - range.length - 1)];
    range = [str rangeOfString:@"'"];
    
    requestToken = [str substringWithRange:NSMakeRange(0, range.location)];
    str = [str substringWithRange:NSMakeRange(range.location + range.length, [str length] - range.location - range.length - 1)];
    
    range = [str rangeOfString:@"get_check_x:'"];
    str = [str substringWithRange:NSMakeRange(range.location + range.length, [str length] - range.location - range.length - 1)];
    
    range = [str rangeOfString:@"'"];
    _rtk = [str substringWithRange:NSMakeRange(0, range.location)];
    
    return [@{@"requestToken": requestToken, @"_rtk" : _rtk} mutableCopy];
}

- (id)token
{
    if (_token) return _token;
    NSMutableDictionary *token = [self _statusTokenInfo];
    token[@"channel"] = @"renren";
    token[@"hostid"] = [self userId];
    return _token = token;
}

- (NSArray *)_analyzeparseContent:(NSString *)content mode:(NSString *)mode analyzer:(id)analyzer
{
    static NSString * const __kMatchExpress1 = @"(?=onclick=\\\"ILike_toggleUserLike\\\().*(?<=\\\)\\\")";
    static NSString * const __kMatchExpress2 = @"\\\(.*\\\)";
    if (!analyzer) return nil;
    NSString *htmlContent = content;
    if (!htmlContent) return nil;
    NSArray *regexResults = [htmlContent substringByRegular:__kMatchExpress1];
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:[regexResults count]];
    for (id obj in regexResults)
    {
        [results addObject:[obj substringByRegular:__kMatchExpress2][0]];
    }
    regexResults = nil;
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for (id obj in results)
    {
        [models addObject:[[RSLikeModel alloc] initWithContent:obj mode:mode]];
    }
    return models;
}

- (NSArray *)analyzeLikeModelWithString:(NSString *)string mode:(NSString *)mode;
{
    return [self _analyzeparseContent:string mode:mode analyzer:self];
}

- (NSArray *)analyzeLikeModelWithData:(NSData *)data mode:(NSString *)mode
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str ? [self analyzeLikeModelWithString:str mode:mode] : nil;
}



- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return YES;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (_delegate && [_delegate respondsToSelector:@selector(analyzer:LoginFailedWithError:)])
       [_delegate analyzer:self LoginFailedWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (_login && _delegate && [_delegate respondsToSelector:@selector(analyzerLoginSuccess:)])
        [_delegate analyzerLoginSuccess:self];
    else if (_delegate && [_delegate respondsToSelector:@selector(analyzer:LoginFailedWithError:)])
            [_delegate analyzer:self LoginFailedWithError:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSString *userId = [[httpResponse URL] absoluteString];
    if ([userId hasPrefix:@"http://www.renren.com/"])
    {
        if ([httpResponse statusCode] == 200 && [userId rangeOfString:@"failCode="].length <= 0 && [[userId stringByReplacingOccurrencesOfString:@"http://www.renren.com/" withString:@""] longLongValue])
        {
            _login = YES;
            _userId = [userId stringByReplacingOccurrencesOfString:@"http://www.renren.com/" withString:@""];
        }
    }
}

- (NSString *)description
{
    NSString *description = [[NSString alloc] initWithFormat:@"analyze object : %@\nlogin status : %@\nuser id = %@", _obj, _login ? @"YES" : @"NO", _userId];
    return description;
}

- (id)responseData
{
    return nil;
}
@end

@implementation RSCoreAnalyzer (Log)

+ (void)logAttributes:(id)elemnts
{
    NSArray *attributes = [elemnts attributes];
    
    for (NSXMLNode *attribute in attributes)
    {
        NSLog (@"%@ = %@", [attribute name], [attribute stringValue]);
    }

}

+ (NSURL *)urlForCoreDumpFriendListWithUserId:(NSString *)userId pageNumber:(NSUInteger)pageNumber
{
    return [NSURL URLWithString:[NSString stringWithFormat:[RSCoreAnalyzer baseURLStringFormatForDumpFriendList], pageNumber, userId]];
}

+ (NSURL *)urlForCoreDumpPopularityWithUserId:(NSString *)userId
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.renren.com/%@", userId]];
}

+ (NSString *)baseURLStringFormatForDumpFriendList
{
    return @"http://friend.renren.com/GetFriendList.do?curpage=%ld&id=%@";
}
@end

@implementation RSCoreAnalyzer (Post)

+ (NSString *)urlEncode:(NSDictionary *)dictionary
{
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
        id encodedValue = dictionary[key];//([dictionary[key] isKindOfClass:[NSString class]]) ? [dictionary[key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : ;
        if ([encodedValue isKindOfClass:[NSDictionary class]])
        {
            encodedValue = [NSJSONSerialization dataWithJSONObject:encodedValue options:NSJSONWritingPrettyPrinted error:nil];
            encodedValue = [[[NSString alloc] initWithData:encodedValue encoding:NSUTF8StringEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ? : encodedValue;
        }
        else if ([encodedValue isKindOfClass:[NSString class]]) encodedValue = [dictionary[key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        else if ([encodedValue isKindOfClass:[NSNumber class]]) encodedValue = encodedValue;
        else if ([encodedValue isKindOfClass:[NSData class]]) encodedValue = [[NSString alloc] initWithData:encodedValue encoding:NSUTF8StringEncoding] ?: encodedValue;
        else if ([encodedValue isKindOfClass:[NSArray class]]) {
            encodedValue = [NSJSONSerialization dataWithJSONObject:encodedValue options:NSJSONWritingPrettyPrinted error:nil];
            encodedValue = [[[NSString alloc] initWithData:encodedValue encoding:NSUTF8StringEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ? : encodedValue;;
        }
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    return encodedDictionary;
}

+ (NSData*)encodeDictionary:(NSDictionary*)dictionary
{
    //    NSMutableArray *parts = [[NSMutableArray alloc] init];
    //    for (NSString *key in dictionary) {
    //        id encodedValue = dictionary[key];//([dictionary[key] isKindOfClass:[NSString class]]) ? [dictionary[key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : ;
    //        if ([encodedValue isKindOfClass:[NSDictionary class]])
    //        {
    //            encodedValue = [NSJSONSerialization dataWithJSONObject:encodedValue options:NSJSONWritingPrettyPrinted error:nil];
    //            encodedValue = [[[NSString alloc] initWithData:encodedValue encoding:NSUTF8StringEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ? : encodedValue;
    //        }
    //        else if ([encodedValue isKindOfClass:[NSString class]]) encodedValue = [dictionary[key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //        else if ([encodedValue isKindOfClass:[NSNumber class]]) encodedValue = encodedValue;
    //        else if ([encodedValue isKindOfClass:[NSData class]]) encodedValue = [[NSString alloc] initWithData:encodedValue encoding:NSUTF8StringEncoding] ?: encodedValue;
    //        else if ([encodedValue isKindOfClass:[NSArray class]]) {
    //            encodedValue = [NSJSONSerialization dataWithJSONObject:encodedValue options:NSJSONWritingPrettyPrinted error:nil];
    //            encodedValue = [[[NSString alloc] initWithData:encodedValue encoding:NSUTF8StringEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ? : encodedValue;;
    //        }
    //        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
    //        [parts addObject:part];
    //    }
    //    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    //    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
    return [[RSCoreAnalyzer urlEncode:dictionary] dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSURLRequest *)requestWithURL:(NSURL *)aURL postInfomation:(NSDictionary *)dictionary
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:aURL];
    NSData *data = [RSCoreAnalyzer encodeDictionary:dictionary];
    [request setHTTPMethod: @"POST"];
    [request setValue: [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:[data length]]] forHTTPHeaderField:@"Content-Length"];
    [request setValue: @"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    return request;
}

@end

@implementation RSCoreAnalyzer (UploadImage)

- (void)_uploadSyncImage:(NSData *)imageData description:(NSString *)description selectAblum:(id (^)(NSArray *ablumList))selForSelectAblum complete:(void (^)(id photoId, BOOL success))complete
{
    if (!imageData)
    {
        complete(nil, NO);
        return;
    }
    NSLog(@"token = %@", [self token]);
    //    return [self _public:@"906004381" photoId:@"7489585138" description:@"description"];
    NSString *parent_formCallback = @"parent.formCallback";
    NSString *uploadFilePath = @"/Users/retval8237/Pictures/PJ/35a5ab5906177b4e79f731c7a09a976e.jpg";
    NSMutableDictionary *requestProperty = [[NSMutableDictionary alloc] init];
    NSMutableArray *albumCollection = [[NSMutableArray alloc] init];
    NSError *error = nil;
    NSString *urlString = @"http://upload.renren.com/addphotoPlain.do";
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString:urlString] options:NSXMLDocumentTidyHTML error:&error];
    if (!document) return;
    NSXMLElement *body = [[document rootElement] elementsForName:@"body"][0];
    NSArray *subElements = [body elementsForName:@"div"];
    if (!subElements) return;
    if ([subElements count] != 4) return;
    if (![[[subElements[3] attributeForName:@"id"] objectValue] isEqualToString:@"container-for-buddylist"]) return;
    
    NSXMLElement *div = subElements[3];
    div = [[[[[[[[div elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][2];
    div = [div elementsForName:@"div"][1]; // single-column
    if (![[[div attributeForName:@"id"] objectValue] isEqualToString:@"single-column"]) return;
    NSXMLElement *form = [div elementsForName:@"form"][0];
    if (![[[form attributeForName:@"target"] objectValue] isEqualToString:@"uploadPlainIframe"]) return;
    requestProperty[@"method"] = [[form attributeForName:@"method"] objectValue];
    requestProperty[@"action"] = [[form attributeForName:@"action"] objectValue];
    requestProperty[@"enctype"] = [[form attributeForName:@"enctype"] objectValue];
    NSLog(@"%@", requestProperty);
    
    NSArray *albumlist = [[[[form elementsForName:@"p"][0] elementsForName:@"span"][0] elementsForName:@"select"][0] elementsForName:@"option"];
    for (NSXMLElement *album in albumlist)
    {
        NSMutableDictionary *dict = [@{@"id": [[album attributeForName:@"value"] objectValue], @"name" : [album objectValue]} mutableCopy];
        if ([[[album attributeForName:@"disabled"] objectValue] isEqualToString:@"disabled"]) dict[@"disabled"] = @(YES);
        [albumCollection addObject:[[RSAlbum alloc] initWithProperty:dict]];
    }
    
    RSAlbum *albumId = nil;
    if (selForSelectAblum) albumId = selForSelectAblum(albumCollection);
    else if ([albumCollection count])
    {
        albumId = albumCollection[0][@"id"];
    }
    else
    {
        complete(nil, NO);
        return;
    }
    if (!albumId || NSNotFound == [albumCollection indexOfObject:albumId] || ([albumCollection indexOfObject:albumId] && [albumCollection[[albumCollection indexOfObject:albumId]] disabled]))
    {
        complete(nil, NO);
        return;
    }
    
    NSArray *files = [[[form elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"p"];
    NSMutableArray *filesCollection = [[NSMutableArray alloc] init];
    for (NSXMLElement *file in files) {
        NSArray *inputs = [file elementsForName:@"input"];
        if (![inputs count]) continue;
        NSXMLElement *input = inputs[0];
        if (![[[input attributeForName:@"type"] objectValue] isEqualToString:@"file"]) continue;
        [filesCollection addObject:[@{@"name": [[input attributeForName:@"name"] objectValue], @"filename":@""} mutableCopy]];
    }
    
    filesCollection[0][@"filename"] = uploadFilePath;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestProperty[@"action"]]];
    NSString * boundary = @"----WebKitFormBoundaryRJUGdi7326XY1u1b";
    NSMutableData *postData = [[NSMutableData alloc] init];
    
    [postData appendData:[[[NSString alloc] initWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", boundary, @"id", [albumId albumId]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    for (NSDictionary *file in filesCollection)
    {
        if ([file[@"filename"] length])
        {
            //            NSData *imageData = [NSData dataWithContentsOfFile:uploadFilePath];
            [postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", file[@"name"], [uploadFilePath lastPathComponent]] dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:imageData];
            [postData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    [postData appendData:[[[NSString alloc] initWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"privacyParams\"\r\n\r\n%@\r\n", boundary, @"{\"sourceControl\":99}"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[[NSString alloc] initWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"callback\"\r\n\r\n%@\r\n", boundary, @"parent.formCallback"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[[NSString alloc] initWithFormat:@"--%@--\r\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    [request setValue:@"http://upload.renren.com/addphotoPlain.do" forHTTPHeaderField:@"Referer"];
    [request setValue:@"http://upload.renren.com" forHTTPHeaderField:@"Origin"];
    [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9) AppleWebKit/537.71 (KHTML, like Gecko) Version/7.0 Safari/537.71" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"1" forHTTPHeaderField:@"DNT"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
        
    NSURLResponse *response = nil;
    NSData *data = nil;
    error = nil;
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) NSLog(@"%@", error);
    NSLog(@"status code = %d", [(NSHTTPURLResponse *)response statusCode]);
    NSString *des = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"";
    NSLog(@"%@", des);
    if ([(NSHTTPURLResponse *)response statusCode] != 200)
    {
        complete(nil, NO);
        return;
    }
    error = nil;
    NSXMLDocument *jumpScript = [[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentTidyHTML error:&error];
    if (error)
    {
        NSLog(@"error = %@", error);
    }
    if (!jumpScript)
    {
        complete(nil, NO);
        return;
    }
    NSXMLElement *head = [[jumpScript rootElement] elementsForName:@"head"][0];
    if (!head) return;
    NSXMLElement *script = [head elementsForName:@"script"][0];
    if (![[[script attributeForName:@"type"] objectValue] isEqualToString:@"text/javascript"])
    {
        complete(nil, NO);
        return;
    }
    
    if (![[script objectValue] rangeOfString:@"document.domain = \"renren.com\";"].location > 10)
    {
        complete(nil, NO);
        return;
    }
    NSString *value = [script objectValue];
    NSRange range = {NSNotFound};
    range = [value rangeOfString:[NSString stringWithFormat:@"%@(", parent_formCallback]];
    value = [value substringWithRange:NSMakeRange(range.location + range.length, [value length] - range.location - range.length)];
    range = [value rangeOfString:@");"];
    value = [value substringWithRange:NSMakeRange(0, range.location)];
    error = nil;
    id dict = [NSJSONSerialization JSONObjectWithData:[value dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (!dict) return;
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    NSURL *saveURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://upload.renren.com/upload/%@/photo/save", [self userId]]];
    post[@"flag"] = @"0/";
    post[@"album.id"] = [albumId albumId];
    post[@"album.description"] = @"";
    post[@"privacyParams"] = @"{\"sourceControl\":99}";
    post[@"photos"] = dict[@"files"] ;
    
    NSMutableURLRequest *saveRequest = [[NSMutableURLRequest alloc] initWithURL:saveURL];
    [saveRequest setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    [saveRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [saveRequest setHTTPMethod:@"POST"];
    NSData *savePostData = [RSCoreAnalyzer encodeDictionary:post];
    [saveRequest setHTTPBody:savePostData];
    [saveRequest setValue:[NSString stringWithFormat:@"%d", [savePostData length]] forHTTPHeaderField:@"Content-Length"];
    [saveRequest setValue:@"http://upload.renren.com" forHTTPHeaderField:@"Origin"];
    [saveRequest setValue:@"http://upload.renren.com/addphotoPlain.do" forHTTPHeaderField:@"Referer"];
    [saveRequest setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    
    
    data = [NSURLConnection sendSynchronousRequest:saveRequest returningResponse:&response error:&error];
    if ([(NSHTTPURLResponse *)response statusCode] != 200)
    {
        complete(nil, NO);
        return;
    }
    NSLog(@"response = %@", response);
    error = nil;
    NSXMLDocument *publishDocument = [[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentTidyHTML error:&error];
    if (!publishDocument)
    {
        complete(nil, NO);
        return;
    }
    
    body = [[publishDocument rootElement] elementsForName:@"body"][0];
    if (![[[body attributeForName:@"id"] objectValue] isEqualToString:@"pageAlbum"])
    {
        complete(nil, NO);
        return;
    }
    
    div = [[[[[[[body elementsForName:@"div"][0] elementsForName:@"div"][3] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0];
    if (![[[div attributeForName:@"id"] objectValue] isEqualToString:@"content"])
    {
        complete(nil, NO);
        return;
    }
    form = [div elementsForName:@"form"][0];
    if (![[[form attributeForName:@"id"] objectValue] isEqualToString:@"albumEditForm"])
    {
        complete(nil, NO);
        return;
    }
    div = [[[[[form elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][1] elementsForName:@"div"][0] elementsForName:@"div"][0];
    NSArray *inputs = [div elementsForName:@"input"];
    id aid = [[inputs[0] attributeForName:@"value"] objectValue];
    if (!aid)
    {
        complete(nil, NO);
        return;
    }
    [self publicImage:[albumId albumId] photoId:aid description:description complete:complete ];
}

- (void)_uploadImage:(NSData *)imageData description:(NSString *)description selectAblum:(id (^)(NSArray *ablumList))selForSelectAblum complete:(void (^)(id photoId, BOOL success))complete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!imageData)
        {
            complete(nil, NO);
            return;
        }
        NSLog(@"token = %@", [self token]);
        //    return [self _public:@"906004381" photoId:@"7489585138" description:@"description"];
        NSString *parent_formCallback = @"parent.formCallback";
        NSString *uploadFilePath = @"/Users/retval8237/Pictures/PJ/35a5ab5906177b4e79f731c7a09a976e.jpg";
        NSMutableDictionary *requestProperty = [[NSMutableDictionary alloc] init];
        NSMutableArray *albumCollection = [[NSMutableArray alloc] init];
        NSError *error = nil;
        NSString *urlString = @"http://upload.renren.com/addphotoPlain.do";
        NSXMLDocument *document = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString:urlString] options:NSXMLDocumentTidyHTML error:&error];
        if (!document) return;
        NSXMLElement *body = [[document rootElement] elementsForName:@"body"][0];
        NSArray *subElements = [body elementsForName:@"div"];
        if (!subElements) return;
        if ([subElements count] != 4) return;
        if (![[[subElements[3] attributeForName:@"id"] objectValue] isEqualToString:@"container-for-buddylist"]) return;
        
        NSXMLElement *div = subElements[3];
        div = [[[[[[[[div elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][2];
        div = [div elementsForName:@"div"][1]; // single-column
        if (![[[div attributeForName:@"id"] objectValue] isEqualToString:@"single-column"]) return;
        NSXMLElement *form = [div elementsForName:@"form"][0];
        if (![[[form attributeForName:@"target"] objectValue] isEqualToString:@"uploadPlainIframe"]) return;
        requestProperty[@"method"] = [[form attributeForName:@"method"] objectValue];
        requestProperty[@"action"] = [[form attributeForName:@"action"] objectValue];
        requestProperty[@"enctype"] = [[form attributeForName:@"enctype"] objectValue];
        NSLog(@"%@", requestProperty);
        
        NSArray *albumlist = [[[[form elementsForName:@"p"][0] elementsForName:@"span"][0] elementsForName:@"select"][0] elementsForName:@"option"];
        for (NSXMLElement *album in albumlist)
        {
            NSMutableDictionary *dict = [@{@"id": [[album attributeForName:@"value"] objectValue], @"name" : [album objectValue]} mutableCopy];
            if ([[[album attributeForName:@"disabled"] objectValue] isEqualToString:@"disabled"]) dict[@"disabled"] = @(YES);
            [albumCollection addObject:[[RSAlbum alloc] initWithProperty:dict]];
        }
        
        RSAlbum *album = nil;
        if (selForSelectAblum) album = selForSelectAblum(albumCollection);
        else if ([albumCollection count])
        {
            album = albumCollection[0][@"id"];
        }
        else
        {
            complete(nil, NO);
            return;
        }
        if (!album || NSNotFound == [albumCollection indexOfObject:album] || ([albumCollection indexOfObject:album] && albumCollection[[albumCollection indexOfObject:album]][@"disabled"]))
        {
            complete(nil, NO);
            return;
        }
        
        NSArray *files = [[[form elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"p"];
        NSMutableArray *filesCollection = [[NSMutableArray alloc] init];
        for (NSXMLElement *file in files) {
            NSArray *inputs = [file elementsForName:@"input"];
            if (![inputs count]) continue;
            NSXMLElement *input = inputs[0];
            if (![[[input attributeForName:@"type"] objectValue] isEqualToString:@"file"]) continue;
            [filesCollection addObject:[@{@"name": [[input attributeForName:@"name"] objectValue], @"filename":@""} mutableCopy]];
        }
        
        filesCollection[0][@"filename"] = uploadFilePath;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestProperty[@"action"]]];
        NSString * boundary = @"----WebKitFormBoundaryRJUGdi7326XY1u1b";
        NSMutableData *postData = [[NSMutableData alloc] init];
        
        [postData appendData:[[[NSString alloc] initWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", boundary, @"id", [album albumId]] dataUsingEncoding:NSUTF8StringEncoding]];
        
        for (NSDictionary *file in filesCollection)
        {
            if ([file[@"filename"] length])
            {
                //            NSData *imageData = [NSData dataWithContentsOfFile:uploadFilePath];
                [postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", file[@"name"], [uploadFilePath lastPathComponent]] dataUsingEncoding:NSUTF8StringEncoding]];
                [postData appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [postData appendData:imageData];
                [postData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        
        [postData appendData:[[[NSString alloc] initWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"privacyParams\"\r\n\r\n%@\r\n", boundary, @"{\"sourceControl\":99}"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[[NSString alloc] initWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"callback\"\r\n\r\n%@\r\n", boundary, @"parent.formCallback"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[[[NSString alloc] initWithFormat:@"--%@--\r\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
        [request setValue:@"http://upload.renren.com/addphotoPlain.do" forHTTPHeaderField:@"Referer"];
        [request setValue:@"http://upload.renren.com" forHTTPHeaderField:@"Origin"];
        [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9) AppleWebKit/537.71 (KHTML, like Gecko) Version/7.0 Safari/537.71" forHTTPHeaderField:@"User-Agent"];
        [request setValue:@"1" forHTTPHeaderField:@"DNT"];
        [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:postData];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (error) NSLog(@"%@", error);
            NSLog(@"status code = %d", [(NSHTTPURLResponse *)response statusCode]);
            NSString *des = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"";
            NSLog(@"%@", des);
            if ([(NSHTTPURLResponse *)response statusCode] != 200)
            {
                complete(nil, NO);
                return;
            }
            error = nil;
            NSXMLDocument *jumpScript = [[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentTidyHTML error:&error];
            if (error)
            {
                NSLog(@"error = %@", error);
            }
            if (!jumpScript)
            {
                complete(nil, NO);
                return;
            }
            NSXMLElement *head = [[jumpScript rootElement] elementsForName:@"head"][0];
            if (!head) return;
            NSXMLElement *script = [head elementsForName:@"script"][0];
            if (![[[script attributeForName:@"type"] objectValue] isEqualToString:@"text/javascript"])
            {
                complete(nil, NO);
                return;
            }
            
            if (![[script objectValue] rangeOfString:@"document.domain = \"renren.com\";"].location > 10)
            {
                complete(nil, NO);
                return;
            }
            NSString *value = [script objectValue];
            NSRange range = {NSNotFound};
            range = [value rangeOfString:[NSString stringWithFormat:@"%@(", parent_formCallback]];
            value = [value substringWithRange:NSMakeRange(range.location + range.length, [value length] - range.location - range.length)];
            range = [value rangeOfString:@");"];
            value = [value substringWithRange:NSMakeRange(0, range.location)];
            error = nil;
            id dict = [NSJSONSerialization JSONObjectWithData:[value dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
            if (!dict) return;
            NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
            NSURL *saveURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://upload.renren.com/upload/%@/photo/save", [self userId]]];
            post[@"flag"] = @"0/";
            post[@"album.id"] = [album albumId];
            post[@"album.description"] = @"";
            post[@"privacyParams"] = @"{\"sourceControl\":99}";
            post[@"photos"] = dict[@"files"] ;
            
            NSMutableURLRequest *saveRequest = [[NSMutableURLRequest alloc] initWithURL:saveURL];
            [saveRequest setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
            [saveRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [saveRequest setHTTPMethod:@"POST"];
            NSData *savePostData = [RSCoreAnalyzer encodeDictionary:post];
            [saveRequest setHTTPBody:savePostData];
            [saveRequest setValue:[NSString stringWithFormat:@"%d", [savePostData length]] forHTTPHeaderField:@"Content-Length"];
            [saveRequest setValue:@"http://upload.renren.com" forHTTPHeaderField:@"Origin"];
            [saveRequest setValue:@"http://upload.renren.com/addphotoPlain.do" forHTTPHeaderField:@"Referer"];
            [saveRequest setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
            
            [NSURLConnection sendAsynchronousRequest:saveRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                if ([(NSHTTPURLResponse *)response statusCode] != 200)
                {
                    complete(nil, NO);
                    return;
                }
                NSLog(@"response = %@", response);
                error = nil;
                NSXMLDocument *publishDocument = [[NSXMLDocument alloc] initWithData:data options:NSXMLDocumentTidyHTML error:&error];
                if (!publishDocument)
                {
                    complete(nil, NO);
                    return;
                }
                
                NSXMLElement *body = [[publishDocument rootElement] elementsForName:@"body"][0];
                if (![[[body attributeForName:@"id"] objectValue] isEqualToString:@"pageAlbum"])
                {
                    complete(nil, NO);
                    return;
                }
                
                NSXMLElement *div = [[[[[[[body elementsForName:@"div"][0] elementsForName:@"div"][3] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0];
                if (![[[div attributeForName:@"id"] objectValue] isEqualToString:@"content"])
                {
                    complete(nil, NO);
                    return;
                }
                NSXMLElement *form = [div elementsForName:@"form"][0];
                if (![[[form attributeForName:@"id"] objectValue] isEqualToString:@"albumEditForm"])
                {
                    complete(nil, NO);
                    return;
                }
                div = [[[[[form elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][1] elementsForName:@"div"][0] elementsForName:@"div"][0];
                NSArray *inputs = [div elementsForName:@"input"];
                id aid = [[inputs[0] attributeForName:@"value"] objectValue];
                if (!aid)
                {
                    complete(nil, NO);
                    return;
                }
                [self publicImage:[album albumId] photoId:aid description:description complete:complete ];
            }];
        }];
    });
}

- (void)publicImage:(NSString *)albumid photoId:(NSString *)photoId description:(NSString *)description complete:(void (^)(id photoId, BOOL success))complete
{
    
    NSString *publishURLString = [[NSString alloc] initWithFormat:@"http://upload.renren.com/upload/%@/album-%@/editPhotoList", [self userId], albumid];
    NSLog(@"%@", publishURLString);
    NSURL *publishURL = [NSURL URLWithString:publishURLString];
    NSMutableURLRequest *publishRequest = [[NSMutableURLRequest alloc] initWithURL:publishURL];
    NSString *boundary = @"----WebKitFormBoundaryKueLOdoAgrkoekBu";
    NSMutableData *postData = [[NSMutableData alloc] init];
    NSString *standardFormat = @"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n";
    [postData appendData:[[[NSString alloc] initWithFormat:standardFormat, boundary, @"id", photoId] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[[NSString alloc] initWithFormat:standardFormat, boundary, @"publishFeed", @"true"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[[NSString alloc] initWithFormat:standardFormat, boundary, @"title", description] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[[NSString alloc] initWithFormat:standardFormat, boundary, @"requestToken", [self token][@"requestToken"]] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[[NSString alloc] initWithFormat:standardFormat, boundary, @"_rtk", [self token][@"_rtk"]] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[[NSString alloc] initWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = nil;
    NSString *string = nil;
    [publishRequest setHTTPBody:postData];
    NSLog(@"\n%@", string);
    
    [publishRequest setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [publishRequest setValue:@"http://upload.renren.com" forHTTPHeaderField:@"Origin"];
    [publishRequest setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.69 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [publishRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    [publishRequest setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];
    
    [publishRequest setHTTPMethod:@"POST"];
    
    NSLog(@"publishRequest %@\n%@", publishRequest, [publishRequest allHTTPHeaderFields]);
    
    NSURLResponse *response = nil;
    data = nil;
    NSError *error = nil;
    data = [NSURLConnection sendSynchronousRequest:publishRequest returningResponse:&response error:&error];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    complete(photoId, error == nil && [httpResponse statusCode] == 200);
}

- (void)uploadImage:(UIImage *)image description:(NSString *)description selectAblum:(id (^)(NSArray *ablumList))selForSelectAblum complete:(void (^)(id photoId, BOOL success))complete
{
    if (!image)
    {
        complete(nil, NO);
        return;
    }
    NSData *data = nil;
    if (UIImagePNGRepresentation(image) == nil)
    {
        data = UIImageJPEGRepresentation(image, 1.0);
    }
    else
    {
        data = UIImagePNGRepresentation(image);
    }
    if (!data)
    {
        complete(nil, NO);
        return;
    }
    [self _uploadImage:data description:description selectAblum:selForSelectAblum complete:complete];
}

- (void)uploadSyncImage:(UIImage *)image description:(NSString *)description selectAblum:(id (^)(NSArray *ablumList))selForSelectAblum complete:(void (^)(id photoId, BOOL success))complete
{
    if (!image)
    {
        complete(nil, NO);
        return;
    }
    NSData *data = nil;
    if (UIImagePNGRepresentation(image) == nil)
    {
        data = UIImageJPEGRepresentation(image, 1.0);
    }
    else
    {
        data = UIImagePNGRepresentation(image);
    }
    if (!data)
    {
        complete(nil, NO);
        return;
    }
    [self _uploadSyncImage:data description:description selectAblum:selForSelectAblum complete:complete];
}

- (void)analyzerGetAccountInformation:(NSString *)accountId
{
    NSString *base = @"http://www.renren.com/%@/profile?v=info_ajax&undefined";
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:base, accountId]]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error)
        {
            if ([[self delegate] respondsToSelector:@selector(analyzer:getAccountInfoFailedWithError:)])
                [[self delegate] analyzer:self getAccountInfoFailedWithError:error];
            return;
        }
        NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:data encoding:NSUTF8StringEncoding options:NSXMLDocumentTidyHTML error:&error];
        if (error)
        {
            if ([[self delegate] respondsToSelector:@selector(analyzer:getAccountInfoFailedWithError:)])
                [[self delegate] analyzer:self getAccountInfoFailedWithError:error];
            return;
        }
        NSXMLElement *body = [[document rootElement] elementsForName:@"body"][0];
        NSXMLElement *div = [[[body elementsForName:@"div"][0] elementsForName:@"div"][0] elementsForName:@"div"][0];
        NSXMLElement *ul = [div elementsForName:@"ul"][0];
        NSXMLElement *li = [ul elementsForName:@"li"][0];
        NSXMLElement *a = [li elementsForName:@"a"][0];
        NSXMLElement *img = [a elementsForName:@"img"][0];
        NSLog(@"%@", [[img attributeForName:@"src"] objectValue]);
        RSAccount *account = [[RSAccount alloc] initWithAccountId:accountId password:nil];
        [account setHeadIcon:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[img attributeForName:@"src"] objectValue]]]]];
        if ([[self delegate] respondsToSelector:@selector(analyzer:getAccountInfoSuccess:)])
        {
            [[self delegate] analyzer:self getAccountInfoSuccess:account];
        }
    }];
}

@end