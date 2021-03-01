//
//  RXPopBoxCell.h
//  COMEngine
//
//  Created by Rex on 2021/2/25.
//  Copyright © 2021 yunxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RXPopBoxCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@property (nonatomic, strong) UIColor * backColor;

@end

NS_ASSUME_NONNULL_END
