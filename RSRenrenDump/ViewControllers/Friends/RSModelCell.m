//
//  RSModelCell.m
//  RSRenrenDump
//
//  Created by RetVal on 5/27/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import "RSModelCell.h"

@implementation RSModelCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UITapGestureRecognizer *tap1=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelectedCell:)];
        tap1.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tap1];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        UITapGestureRecognizer *tap1=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelectedCell:)];
        tap1.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tap1];
    }
    return self;
}

- (UIImageView *)headImageView
{
    [_headImageView setHidden:NO];
    return _headImageView;
}

-(void)doSelectedCell:(UITapGestureRecognizer*)sender{
    CGPoint point=[sender locationInView:self];
    UITableView *tableView = nil;
    if ([UIDevice majorVersion] >= 7)
        tableView = (UITableView *)[[self superview] superview];
    else
        tableView = (UITableView *)[self superview];
    NSIndexPath *path=[tableView indexPathForRowAtPoint:point];
    if ([[tableView delegate] respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
        [[tableView delegate] tableView:tableView didSelectRowAtIndexPath:path];
}
@end
