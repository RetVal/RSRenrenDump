//
//  RSModelCell.h
//  RSRenrenDump
//
//  Created by RetVal on 5/27/13.
//  Copyright (c) 2013 RetVal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSModelCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleTabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *replyCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@end
