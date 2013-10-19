//
//  RSUploadImageTask.m
//  RSRenren
//
//  Created by Closure on 10/17/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSUploadImageTask.h"
#import "RSBaseModel.h"
#import "RSCoreAnalyzer.h"
#import "RSSharedDataBase.h"

NSString * const __RSUploadImageTaskDescription = @"Description";
NSString * const __RSUploadImageTaskAblumSelector = @"AblumSelector";
NSString * const __RSUploadImageTaskCompleteSelector = @"CompleteSelector";
NSString * const __RSUploadImageTaskImage = @"Image";
NSString * const __RSUploadImageTaskAnalyzer = @"Analyzer";

@interface RSUploadImageTask()
{
    RSCoreAnalyzer *_analyzer;
    UIImage *_uploadImage;
    NSString *_description;
    id (^_selForSelectAblumSelector)(NSArray *ablumList);
    void (^_completeSelector)(RSUploadImageTask *task, BOOL success);
    id _property;
}

@end

@implementation RSUploadImageTask
- (id)initWithTask:(id)taskProperty
{
    if (![taskProperty isKindOfClass:[NSDictionary class]]) return nil;
    if (self = [super init])
    {
        _property = [taskProperty copy];
        _analyzer = _property[__RSUploadImageTaskAnalyzer];
        if (!_analyzer)
            _analyzer = [[RSSharedDataBase sharedInstance] currentAnalyzer];
        _uploadImage = _property[__RSUploadImageTaskImage];
        _selForSelectAblumSelector = _property[__RSUploadImageTaskAblumSelector];
        _completeSelector = _property[__RSUploadImageTaskCompleteSelector];
        _description = _property[__RSUploadImageTaskDescription];
    }
    return self;
}

- (void)main
{
    [_analyzer uploadSyncImage:_uploadImage description:_description selectAblum:_selForSelectAblumSelector complete:^(id photoId, BOOL success) {
        _completeSelector(self, success);
    }];
    NSLog(@"uploadImage selector return!");
}

- (id)property
{
    return _property;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", [self class], _property[__RSUploadImageTaskDescription]];
}
@end
