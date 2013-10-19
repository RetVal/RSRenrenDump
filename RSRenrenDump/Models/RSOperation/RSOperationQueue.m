//
//  RSOperationQueue.m
//  RSRenren
//
//  Created by Closure on 10/17/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSOperationQueue.h"
#import <dispatch/dispatch.h>
#import "RSOperationQueueStatusBar.h"
#import "MTStatusBarOverlay.h"

static RSOperationQueue *__RSSharedOperationQueue;

@interface RSOperationQueue()
{
    NSOperationQueue *_operationQueue;
    dispatch_queue_t _dispatch_queue;
    
    NSMutableArray *_tasks;
}
@end

@implementation RSOperationQueue
+ (id)sharedOperationQueue
{
    @synchronized(__RSSharedOperationQueue)
    {
        if (__RSSharedOperationQueue) return __RSSharedOperationQueue;
        __RSSharedOperationQueue = [[RSOperationQueue alloc] initWithName:@"com.retval.RSSharedOperationQueue"];
    }
    return __RSSharedOperationQueue;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([_operationQueue respondsToSelector:aSelector])
    {
        return _operationQueue;
    }
    return nil;
}

- (id)initWithName:(NSString *)name
{
    if (self = [super init])
    {
        _operationQueue = [[NSOperationQueue alloc] init];
        [_operationQueue setName:name];
        [_operationQueue setMaxConcurrentOperationCount:1];
        _dispatch_queue = dispatch_queue_create([name UTF8String], nil);
    }
    return self;
}

- (void)dealloc
{
    _dispatch_queue = nil;
}

- (void)addTaskBlock:(void(^)())task complete:(void (^)())complete
{
    if ([self operationCount] == 0)
    {
    }
    @synchronized(_dispatch_queue)
    {
        if (task) dispatch_async(_dispatch_queue, task);
        if (complete) dispatch_async(_dispatch_queue, complete);
    }
}

- (void)addOperationWithBlock:(void (^)(void))block
{
    [_operationQueue addOperationWithBlock:block];
}

- (void)addOperation:(NSOperation *)op
{
    [[MTStatusBarOverlay sharedInstance] postMessage:@"Uploading..." animated:YES];
    [_operationQueue addOperation:op];
    [self addOperationWithBlock:^{
        [[MTStatusBarOverlay sharedInstance] postFinishMessage:@"Finished" duration:0.618 animated:YES];
    }];
}

@end
