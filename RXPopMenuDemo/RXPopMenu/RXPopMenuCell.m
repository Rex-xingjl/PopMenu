//
//  RXPopMenuCell.m
//  RXPopMenuDemo
//
//  Created by Rex on 2018/3/7.
//  Copyright © 2018年 Rex. All rights reserved.
//

#import "RXPopMenuCell.h"

@implementation RXPopMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _leftImageView.userInteractionEnabled = NO;
    _rightLabel.userInteractionEnabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
