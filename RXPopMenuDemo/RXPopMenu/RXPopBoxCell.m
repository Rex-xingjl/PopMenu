//
//  RXPopBoxCell.m
//  COMEngine
//
//  Created by Rex on 2021/2/25.
//  Copyright © 2021 yunxiang. All rights reserved.
//

#import "RXPopBoxCell.h"

@implementation RXPopBoxCell

- (void)setBackColor:(UIColor *)backColor {
    _backColor = backColor;
    self.contentView.backgroundColor = backColor;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _topImageView.contentMode = UIViewContentModeCenter;
    _topImageView.userInteractionEnabled = NO;
    _bottomLabel.userInteractionEnabled = NO;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
        // 动画高亮变色效果
    [UIView animateWithDuration:0.2 animations:^{
        if (highlighted) {
            self.contentView.backgroundColor = [UIColor blackColor];
        } else {
            self.contentView.backgroundColor = self.backColor;
        }
    }];
}

@end
