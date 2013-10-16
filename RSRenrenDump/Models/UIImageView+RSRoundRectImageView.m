//
//  UIImageView+RSRoundRectImageView.m
//  RSRenren
//
//  Created by RetVal on 10/11/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "UIImageView+RSRoundRectImageView.h"

@implementation UIImageView (RSRoundRectImageView)
- (void)makeRoundRect
{
    UIImage *image = [self image];
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [[UIBezierPath bezierPathWithRoundedRect:imageRect
                                cornerRadius:180.0] addClip];
    [image drawInRect:imageRect];
    [self setImage:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();
}
@end
