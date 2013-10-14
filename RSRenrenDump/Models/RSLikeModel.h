//
//  RSLikeModel.h
//  RSDumpRenren
//
//  Created by RetVal on 10/9/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSLikeModel : NSObject
{
    id _container;
    id _mode;
}
@property (nonatomic, strong) id info;
- (id)initWithContent:(NSString *)content mode:(NSString *)mode;
- (void)action;
- (NSString *)type;
- (id)userInfo;
@end

FOUNDATION_EXPORT NSString * const RSRenrenAddLike;
FOUNDATION_EXPORT NSString * const RSRenrenRemoveLike;
