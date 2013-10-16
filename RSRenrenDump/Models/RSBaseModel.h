//
//  RSBaseModel.h
//  RSDumpRenren
//
//  Created by RetVal on 5/24/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSBaseModel : NSObject <NSCoding>
@property (nonatomic, strong) NSString *name;
@property (atomic, strong) NSURL *homePageURL;
@property (atomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSString *schoolName;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, assign) NSUInteger popularity;
- (id)serialization;
- (id)initWithSerialization:(id)serialization;
@end
