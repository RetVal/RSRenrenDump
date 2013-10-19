//
//  RSUploadImageTask.h
//  RSRenren
//
//  Created by Closure on 10/17/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSUploadImageTask : NSOperation
- (id)initWithTask:(id)taskProperty;
- (id)property;
- (void)main;
- (NSString *)description;
@end

FOUNDATION_EXPORT NSString * const __RSUploadImageTaskDescription;
FOUNDATION_EXPORT NSString * const __RSUploadImageTaskAblumSelector;
FOUNDATION_EXPORT NSString * const __RSUploadImageTaskCompleteSelector;
FOUNDATION_EXPORT NSString * const __RSUploadImageTaskImage;
FOUNDATION_EXPORT NSString * const __RSUploadImageTaskAnalyzer;