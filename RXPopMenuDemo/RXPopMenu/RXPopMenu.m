//
//  RXPopMenu.m
//  RXPopMenuDemo
//
//  Created by Rex on 2018/3/7.
//  Copyright © 2018年 Rex. All rights reserved.
//

#import "RXPopMenu.h"
#import "RXPopMenuCell.h"
#import "RXPopMenuArrow.h"

#define RXPopMenuCellID @"RXPopMenuCell"
#define RXScreenWidth [UIScreen mainScreen].bounds.size.width
#define RXScreenHeight [UIScreen mainScreen].bounds.size.height
#define RXHexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface RXPopMenu ()
<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *popTableView;
@property (nonatomic, strong) RXPopMenuArrow * popArrow;
@property (nonatomic, strong) UIView * popView;
@property (nonatomic, strong) id showView;
@property (nonatomic, assign) BOOL inNaviBar;

/** 元素集合 */
@property (nonatomic, strong) NSArray <RXPopMenuItem *> * items;

@end

@implementation RXPopMenu
@synthesize menuSize = _menuSize;
@synthesize backColor = _backColor;
@synthesize itemHeight = _itemHeight;
@synthesize cornerRadius = _cornerRadius;
@synthesize titleFont = _titleFont;
@synthesize titleColor = _titleColor;

#pragma mark - View Life Cycle -

+ (id)menu {
    RXPopMenu * menu = [[RXPopMenu alloc] initWithFrame:[UIScreen mainScreen].bounds];
    menu.alpha = 0.95f;
    menu.backgroundColor = [UIColor clearColor];
    return menu;
}

+ (void)hideBy:(id)target {
    UIViewController * showVC;
    UIView * containerView;
    if ([target isKindOfClass:[UIView class]]) {
        showVC = [RXPopMenu VCForShowView:target];
    } else {
        showVC = target;
    }
    if (showVC.navigationController) {
        containerView = showVC.navigationController.view;
    } else {
        containerView = showVC.view;
    }
    [containerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:self]) {
            [obj removeFromSuperview];
            obj = nil;
            *stop = YES;
        }
    }];
}

- (void)showBy:(id)target withItems:(NSArray <RXPopMenuItem *>*)items {
    self.showView = target;
    if (![target isKindOfClass:[UIView class]] &&
        ![target isKindOfClass:[UIBarButtonItem class]]) {
        return;
    }
    if ([NSStringFromClass([[self.showView superview] class]) isEqualToString:@"_UITAMICAdaptorView"]) {
        self.inNaviBar = YES; // 在navigationBar上面
    }
    self.items = items;
    UIViewController * showVC = [RXPopMenu VCForShowView:self.showView];
    if (showVC.navigationController) {
        [showVC.navigationController.view addSubview:self];
    } else {
        [showVC.view addSubview:self];
    }
}

- (void)setItems:(NSArray<RXPopMenuItem *> *)items {
    if (_items != items) {
        _items = items;
        for (RXPopMenuItem * item in items) {
            if (!item.image || [item.image isEqualToString:@""]) {
                self.hideImage = YES; break;
            }
        }
        [self popView];
        [self popArrow];
        [self.popTableView reloadData];
    }
}

- (CGSize)menuSize {
    if (CGSizeEqualToSize(CGSizeZero, _menuSize)) {
        return CGSizeMake([self widthOfMenu], self.itemHeight * _items.count);
    } else {
        return _menuSize;
    }
}

- (CGFloat)widthOfMenu {
    CGFloat MINWIDTH = self.hideImage ? 70.f : 100.f;

    RXPopMenuItem * maxItem;
    for (RXPopMenuItem * item in _items) {
        if (maxItem.title.length < item.title.length) {
            maxItem = item;
        }
    }
    CGFloat otherWidth = 60 - (self.hideImage ? 30.f : 0.f);
    CGFloat maxTextWidth = [maxItem.title sizeWithAttributes:@{NSFontAttributeName:self.titleFont}].width;
    CGFloat itemWidth = maxTextWidth + 1 + otherWidth;
    itemWidth = itemWidth <= MINWIDTH ? MINWIDTH : itemWidth;
    return itemWidth;
}

- (void)setMenuSize:(CGSize)menuSize {
    if (!CGSizeEqualToSize(_menuSize, menuSize)) {
        _menuSize = menuSize;
        self.popTableView.frame = CGRectMake(0, 0, _menuSize.width, _menuSize.height);
    }
}

- (CGFloat)itemHeight {
    return _itemHeight <= 0 ? 50.f : _itemHeight;
}

- (void)setItemHeight:(CGFloat)itemHeight {
    if (_itemHeight != itemHeight) {
        _itemHeight = itemHeight;
        [_popTableView reloadData];
    }
}

- (UIColor *)backColor {
    return _backColor ? : RXHexRGB(0x222222);
}

- (void)setBackColor:(UIColor *)backColor {
    if (_backColor != backColor) {
        _backColor = backColor;
    }
}

- (CGFloat)cornerRadius {
    return _cornerRadius <= 0 ? 4.f : _cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (_cornerRadius != cornerRadius) {
        _cornerRadius = cornerRadius;
        self.popView.superview.layer.cornerRadius = self.cornerRadius;
    }
}

- (UIFont *)titleFont {
    return _titleFont ? : [UIFont systemFontOfSize:16.f];
}

- (void)setTitleFont:(UIFont *)titleFont {
    if (_titleFont != titleFont) {
        _titleFont = titleFont;
        [_popTableView reloadData];
    }
}

- (UIColor *)titleColor {
    return _titleColor ? : [UIColor whiteColor];
}

- (void)setTitleColor:(UIColor *)titleColor {
    if (_titleColor != titleColor) {
        _titleColor = titleColor;
        [_popTableView reloadData];
    }
}

- (UIColor *)lineColor {
    return _lineColor ? : RXHexRGB(0x7E7E7E);
}

- (UITableView *)popTableView {
    if (!_popTableView) {
        self.popTableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 0, self.menuSize.width, self.menuSize.height)];
        _popTableView.bounces = NO;
        _popTableView.delegate = self;
        _popTableView.dataSource = self;
        _popTableView.separatorColor = self.lineColor;
        _popTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _popTableView.backgroundColor = self.backColor;
        _popTableView.clipsToBounds = YES;
        _popTableView.tableFooterView = [[UIView alloc] init];
        [_popTableView registerNib:[UINib nibWithNibName:RXPopMenuCellID bundle:[NSBundle mainBundle]]
            forCellReuseIdentifier:RXPopMenuCellID];
    }
    return _popTableView;
}

- (UIView *)popView {
    if (!_popView) {
        CGRect arrow = [self getArrowFrame];
        CGRect frame = [self getPopFrame];
        frame.origin.x = (arrow.origin.x + arrow.size.width/2.0) - frame.size.width/2.0;
        
        self.popView = [[UIView alloc] initWithFrame:frame];
        _popView.layer.cornerRadius = self.cornerRadius;
        _popView.layer.masksToBounds = YES;
        _popView.backgroundColor = self.backColor;
        [_popArrow addSubview:self.popArrow];
        [_popView addSubview:self.popTableView];
        [self addSubview:_popView];
    }
    return _popView;
}

- (RXPopMenuArrow *)popArrow {
    if (!_popArrow) {
        CGRect viewScreenFrame = [self getShowViewFrame];
        CGRect frame = [self getArrowFrame];
        self.popArrow = [[RXPopMenuArrow alloc] initWithFrame:frame Color:self.backColor];
        [self addSubview:_popArrow];
        if (frame.origin.y <= viewScreenFrame.origin.y) {
            CGAffineTransform transform = CGAffineTransformIdentity;
            _popArrow.transform = CGAffineTransformRotate(transform, M_PI);
        }
    }
    return _popArrow;
}

- (CGRect)getShowViewFrame {
    CGRect viewScreenFrame;
    if (self.inNaviBar) {
        viewScreenFrame = [self.showView convertRect:[self.showView bounds] toView:[RXPopMenu VCForShowView:self.showView].navigationController.view];;
    }  else {
        UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
        viewScreenFrame = [self.showView convertRect: [self.showView bounds] toView:window];
    }
    return viewScreenFrame;
}

- (CGRect)getPopFrame {
    CGRect viewScreenFrame = [self getShowViewFrame];
    CGSize menuSize = self.menuSize;
    CGRect popFrame;
    CGFloat verticalSpac = 10;
    if (viewScreenFrame.origin.x > RXScreenWidth/2 &&
        viewScreenFrame.origin.y < RXScreenHeight/2) { // 右上方区域内
        CGFloat right_spac = RXScreenWidth - viewScreenFrame.origin.x - viewScreenFrame.size.width;
        popFrame.origin.x = viewScreenFrame.origin.x + viewScreenFrame.size.width + right_spac/2 - menuSize.width;
        popFrame.origin.y = viewScreenFrame.origin.y + viewScreenFrame.size.height + verticalSpac;
    } else if (viewScreenFrame.origin.x < RXScreenWidth/2 &&
               viewScreenFrame.origin.y < RXScreenHeight/2) { // 左上方区域内
        CGFloat left_spac = viewScreenFrame.origin.x;
        popFrame.origin.x = viewScreenFrame.origin.x - left_spac/2;
        popFrame.origin.y = viewScreenFrame.origin.y + viewScreenFrame.size.height + verticalSpac;
    } else if (viewScreenFrame.origin.x < RXScreenWidth/2 &&
              viewScreenFrame.origin.y >= RXScreenHeight/2) { // 左上方区域内
        CGFloat left_spac = viewScreenFrame.origin.x;
        popFrame.origin.x = viewScreenFrame.origin.x - left_spac/2;
        popFrame.origin.y = viewScreenFrame.origin.y - verticalSpac/2.0 - menuSize.height;
    } else if (viewScreenFrame.origin.x >= RXScreenWidth/2 &&
              viewScreenFrame.origin.y >= RXScreenHeight/2) { // 左上方区域内
        CGFloat left_spac = viewScreenFrame.origin.x;
        popFrame.origin.x = viewScreenFrame.origin.x - left_spac/2;
        popFrame.origin.y = viewScreenFrame.origin.y - verticalSpac/2.0 - menuSize.height;
    }
    popFrame.size = menuSize;
    return popFrame;
}


- (CGRect)getArrowFrame {
    CGRect viewScreenFrame = [self getShowViewFrame];
    CGRect arrowFrame = CGRectMake(0, 0, 13, 13/2);
    CGFloat verticalSpac = 10;
    arrowFrame.origin.x = viewScreenFrame.origin.x + viewScreenFrame.size.width/2 - arrowFrame.size.width/2;
    if (viewScreenFrame.origin.y >= RXScreenHeight/2) {
        arrowFrame.origin.y = viewScreenFrame.origin.y  - arrowFrame.size.height;
    } else {
        arrowFrame.origin.y = viewScreenFrame.origin.y + viewScreenFrame.size.height + verticalSpac - arrowFrame.size.height;
    }
    return arrowFrame;
}

- (void)setShowView:(id)showView {
    if (_showView != showView) {
        if ([showView isKindOfClass:[UIView class]]) {
            _showView = showView;
        } else if ([showView isKindOfClass:[UIBarButtonItem class]]) {
            if ([showView customView]) {
                _showView = [showView customView];
            } else {
                NSAssert(1, @"Unsupport Type:Is not a View");
            }
        }
    }
}

+ (UIViewController *)VCForShowView:(id)view {

    if ([view isKindOfClass:[UIView class]]) {
        for (UIView * next = [view superview]; next; next = next.superview) {
            UIResponder* nextResponder = [next nextResponder];
            if ([nextResponder isKindOfClass:[UIViewController class]]) {
                return (UIViewController *)nextResponder;
            }
        }
    } else if ([view isKindOfClass:[UIBarButtonItem class]]) {
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        if (window.windowLevel != UIWindowLevelNormal) {
            NSArray *windows = [[UIApplication sharedApplication] windows];
            for(UIWindow * tmpWin in windows) {
                if (tmpWin.windowLevel == UIWindowLevelNormal) {
                    window = tmpWin;
                    break;
                }
            }
        }
        UIView *frontView = [[window subviews] objectAtIndex:0];
        id nextResponder = [frontView nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]])
            return nextResponder;
        else
            return window.rootViewController;
    }
    return nil;
}

#pragma mark - Delegate -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RXPopMenuItem * item = self.items[indexPath.row];
    item.index = indexPath.row;
    RXPopMenuCell * cell = [tableView dequeueReusableCellWithIdentifier:RXPopMenuCellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.rightLabel.text = item.title;
    cell.rightLabel.font = self.titleFont;
    cell.rightLabel.textColor = self.titleColor;
    cell.rightLabel.textAlignment = self.titleAlignment;
    cell.leftImageView.image = item.image ? [UIImage imageNamed:item.image] : nil;
    cell.imageViewWidth.constant = self.hideImage ? 0.f : 22.f;
    cell.spaceOfImageAndLabel.constant = self.hideImage ? 0.f : 8.f;
    cell.backColor = self.backColor;
    CGFloat left = indexPath.row+1 == self.items.count ? self.menuSize.width : 11;
    cell.separatorInset = UIEdgeInsetsMake(0, left, 0, left);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.itemActions) {
        self.itemActions(self.items[indexPath.row]);
        [self removeFromSuperview];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self removeFromSuperview];
}

@end


@implementation RXPopMenuItem

+ (id)itemTitle:(NSString *)title image:(NSString *)image {
    RXPopMenuItem * item = [[RXPopMenuItem alloc] init];
    item.title = title;
    item.image = image;
    return item;
}

+ (id)itemTitle:(NSString *)title {
    RXPopMenuItem * item = [[RXPopMenuItem alloc] init];
    item.title = title;
    return item;
}

@end
