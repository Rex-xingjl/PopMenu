//
//  RXPopMenuCell.m
//  RXPopMenuDemo
//
//  Created by Rex on 2018/3/7.
//  Copyright © 2018年 Rex. All rights reserved.
//

#import "RXPopMenuCell.h"

@implementation RXPopMenuCell

- (void)setBackColor:(UIColor *)backColor {
    _backColor = backColor;
    self.contentView.backgroundColor = backColor;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _leftImageView.contentMode = UIViewContentModeCenter;
    _leftImageView.userInteractionEnabled = NO;
    _rightLabel.userInteractionEnabled = NO;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    // 动画高亮变色效果
    [UIView animateWithDuration:0.2 animations:^{
        if (highlighted) {
            self.contentView.backgroundColor = [UIColor blackColor];
        } else {
            self.contentView.backgroundColor = self.backColor;
        }
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
