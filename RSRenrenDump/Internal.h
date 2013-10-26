//
//  Internal.h
//  RSDumpRenren
//
//  Created by RetVal on 5/24/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#ifndef RSDumpRenren_Internal_h
#define RSDumpRenren_Internal_h

static NSString * const _kCAHomePageLinkKey = @"homepage";
static NSString * const _kCAHeadImageLinkKey = @"headimageURL";
static NSString * const _kCAHeadImage = @"headimage";
static NSString * const _kCASchoolKey = @"location";
static NSString * const _kCANameKey = @"name";
static NSString * const _kCAAccountKey = @"account";
static NSString * const _kCAPopularityKey = @"popularity";

#if TARGET_OS_IPHONE
#define TOUCHXMLUSETIDY 1
#include "TouchXML.h"
typedef CXMLNode NSXMLNode;
typedef CXMLElement NSXMLElement;
typedef CXMLDocument NSXMLDocument;

enum  {
    NSXMLDocumentTidyHTML = CXMLDocumentTidyHTML,
};
#endif

@interface NSString (StringRegular)
- (NSMutableArray *)substringByRegular:(NSString *)regular;
@end

@interface UIDevice (SystemVersion)
+ (NSUInteger)majorVersion;
@end

typedef enum _UIBackgroundStyle {
	UIBackgroundStyleDefault,
	UIBackgroundStyleTransparent,
	UIBackgroundStyleLightBlur,
	UIBackgroundStyleDarkBlur,
	UIBackgroundStyleDarkTranslucent
} UIBackgroundStyle;

@interface UIApplication (UIBackgroundStyle)
-(void)_setBackgroundStyle:(UIBackgroundStyle)style;
@end

@interface UIApplication (Private)
- (void)_setApplicationIsOpaque:(BOOL)opaque;
@end
#endif
