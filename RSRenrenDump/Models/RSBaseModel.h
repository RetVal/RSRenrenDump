//
//  RSBaseModel.h
//  RSDumpRenren
//
//  Created by RetVal on 5/24/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSBaseModel : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *homePageURL;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *schoolName;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, assign) NSUInteger popularity;
- (id)serialization;
- (id)initWithSerialization:(id)serialization;
@end
