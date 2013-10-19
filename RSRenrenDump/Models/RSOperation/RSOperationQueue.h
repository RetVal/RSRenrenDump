//
//  RSOperationQueue.h
//  RSRenren
//
//  Created by Closure on 10/17/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSOperationQueue : NSObject
+ (id)sharedOperationQueue;
- (id)initWithName:(NSString *)name;
- (void)addTaskBlock:(void(^)())task complete:(void (^)())complete;
- (void)addOperation:(NSOperation *)op;
- (void)addOperationWithBlock:(void (^)(void))block;
- (NSInteger)maxConcurrentOperationCount;
- (void)setMaxConcurrentOperationCount:(NSInteger)cnt;
- (void)setSuspended:(BOOL)b;
- (BOOL)isSuspended;
- (NSArray *)operations;
- (NSUInteger)operationCount;
@end
