//
//  RSRemoteDataBase.h
//  RSDumpRenren
//
//  Created by RetVal on 10/9/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSRemoteDataBase : NSObject
+ (id)remoteUpdatePage:(NSUInteger)begin limit:(NSUInteger)limit count:(NSUInteger)count analyer:(id)analyer;
+ (id)remoteUpdateUser:(NSString *)uid count:(NSUInteger)count analyer:(id)analyer;

+ (void)remoteInvokeUpdatePage:(NSUInteger)begin limit:(NSUInteger)limit count:(NSUInteger)count analyer:(id)analyer complete:(void(^)(NSURLResponse *response, NSData *data, NSError *error))complete;

+ (NSData *)remoteSyncInvokeUpdatePage:(NSUInteger)begin limit:(NSUInteger)limit count:(NSUInteger)count analyer:(id)analyer response:(NSURLResponse **)response error:(NSError **)error;

+ (id)remoteDataBaseAddLikeToUser:(NSString *)user count:(NSUInteger)count analyzer:(id)analyzer;
@end
