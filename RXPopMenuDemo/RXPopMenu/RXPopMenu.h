//
//  RXPopMenu.h
//  RXPopMenuDemo
//
//  Created by Rex on 2018/3/7.
//  Copyright © 2018年 Rex. All rights reserved.
//
// 点击按钮 弹出选择菜单 多用于navigationItem.customView

/** 用法示例 可直接复制
 --------------------------------------------------------------
 NSArray * showItems = @[
 [RXPopMenuItem itemTitle:@"<#   #>" image:@"<#   #>"],
 [RXPopMenuItem itemTitle:@"<#   #>" image:@"<#   #>"],
 ];
 RXPopMenu * menu = [RXPopMenu menu];
 [menu showBy:<#   #> withItems:showItems];
 __weak typeof(self) weak = self;
 menu.itemActions = ^(RXPopMenuItem *item) {
 switch (item.index) {
 case 0: {
 <#statements#>
 } break;
 case 1: {
 <#statements#>
 } break;
 default: break;
 }
 };
 --------------------------------------------------------------
 */
 
#import <UIKit/UIKit.h>
@class RXPopMenuItem;

@interface RXPopMenu : UIViewController

#pragma mark - ShowMenu

/** 创建弹出框 */
+ (id)menu;

/** 展示弹出框
 * target: 弹出框指向控件 可以是view或者UIBarButtonItem
 * items: 弹出框包含的选项
 */
- (void)showBy:(id)target withItems:(NSArray <RXPopMenuItem *>*)items;

/** 点击事件
 * 可以用 item.index 或者 item.title 区分响应操作
 */
@property (nonatomic, copy) void (^itemActions)(RXPopMenuItem * item);

#pragma mark - Options

/** 弹出元素是否隐藏左侧的图片 默认 NO */
@property (nonatomic, assign) BOOL hideImage;

/** 弹出框大小 默认 CGSizeMake(图片宽度+文字最大宽度, 50 * items.count) */
@property (nonatomic, assign) CGSize menuSize;

/** 弹出框底色 默认 darkGrayColor */
@property (nonatomic, strong) UIColor * backColor;

/** 弹出框圆角 默认 4.f (max->13.f) */
@property (nonatomic, assign) CGFloat cornerRadius;

/** 单个元素高度 默认 50.f */
@property (nonatomic, assign) CGFloat itemHeight;

/** 统一文字颜色 默认 whiteColor */
@property (nonatomic, strong) UIColor * titleColor;

/** 统一文字大小 默认 16 */
@property (nonatomic, strong) UIFont * titleFont;

/** 统一文字对齐方式 默认 左侧对其 */
@property (nonatomic, assign) NSTextAlignment titleAlignment;

/** 统一线条颜色 不设置会自动适配 */
@property (nonatomic, strong) UIColor * lineColor;

@end

#pragma mark -

@interface RXPopMenuItem : NSObject

+ (id)itemTitle:(NSString *)title image:(NSString *)image;

+ (id)itemTitle:(NSString *)title;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * image;

@end
