//
//  RSCoreAnalyzer.h
//  RSDumpRenren
//
//  Created by RetVal on 5/23/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol RSCoreAnalyzerDelegate;
@interface RSCoreAnalyzer : NSObject
@property (nonatomic, weak) id <RSCoreAnalyzerDelegate> delegate;
+ (id)analyzerWithAccount:(NSString *)account password:(NSString *)password;
- (void)startLogin;

- (void)setDataToAnalyze:(NSData *)object;
- (void)setURLToAnalyze:(NSURL *)URL;
- (id)startAnalyze;

- (id)analyzeFriend:(NSXMLElement *)friendInfo;
- (NSArray *)friendsElementFromDocument:(NSXMLDocument *)doc;
- (NSUInteger)analyzeFriendNumberFromDocument:(NSXMLDocument *)doc;
- (NSUInteger)analyzeUserPopularityWithUserId:(NSString *)userId;

- (id)userId;
- (id)responseData;
- (id)token;

- (NSArray *)analyzeLikeModelWithString:(NSString *)string mode:(NSString *)mode;
- (NSArray *)analyzeLikeModelWithData:(NSData *)data mode:(NSString *)mode;
@end

@interface RSCoreAnalyzer (Log)
+ (void)logAttributes:(id)elemnts;
+ (NSURL *)urlForCoreDumpFriendListWithUserId:(NSString *)userId pageNumber:(NSUInteger)pageNumber;
+ (NSURL *)urlForCoreDumpPopularityWithUserId:(NSString *)userId;
@end

@interface RSCoreAnalyzer (Post)
+ (NSData*)encodeDictionary:(NSDictionary*)dictionary;
+ (NSURLRequest *)requestWithURL:(NSURL *)aURL postInfomation:(NSDictionary *)dictionary;
@end

@interface RSCoreAnalyzer (UploadImage)
- (void)uploadImage:(UIImage *)image description:(NSString *)description selectAblum:(id (^)(NSArray *ablumList))selForSelectAblum complete:(void (^)(BOOL success))complete;
@end

@protocol RSCoreAnalyzerDelegate <NSObject>
@optional
- (void)analyzerLoginSuccess:(RSCoreAnalyzer *)analyzer;
- (void)analyzer:(RSCoreAnalyzer *)analyzer LoginFailedWithError:(NSError *)error;
@end