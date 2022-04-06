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
#import "RXPopBoxCell.h"

static NSString * const RXPopMenuCellID = @"RXPopMenuCell";
static NSString * const RXPopBoxCellID = @"RXPopBoxCell";
static CGFloat const RXPopBoxItemWidth = 60.f;

#define RXSafeTopHeight (RXScreenHeight/RXScreenWidth > 2 ? 44.f : 24.f)
#define RXScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define RXScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define RXHexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define RXArrowSize CGSizeMake(14.0, 7)

@interface RXPopMenu () <
UITableViewDelegate,
UITableViewDataSource,
UICollectionViewDataSource
>

@property (nonatomic, assign) RXPopMenuType menuType;

@property (nonatomic, strong) UITableView *popTableView;
@property (nonatomic, strong) UICollectionView * popCollectionView;
@property (nonatomic, strong) RXPopMenuArrow * popArrow;
@property (nonatomic, strong) UIView * popView;
@property (nonatomic, strong) id targetView;
@property (nonatomic, assign) BOOL inNaviBar;

@property (nonatomic, assign) CGFloat visibleHeight;
@property (nonatomic, assign) CGRect targetViewFrame;

/** 元素集合 */
@property (nonatomic, strong) NSArray <RXPopMenuItem *> * items;

@end

@implementation RXPopMenu
@synthesize menuSize = _menuSize;
@synthesize backColor = _backColor;
@synthesize itemHeight = _itemHeight;
@synthesize titleFont = _titleFont;
@synthesize titleColor = _titleColor;

#pragma mark - View Life Cycle -

+ (id)menu {
    RXPopMenu * menu = [[RXPopMenu alloc] initWithFrame:[UIScreen mainScreen].bounds];
    menu.backgroundColor = [UIColor clearColor];
    return menu;
}

+ (id)menuWithType:(RXPopMenuType)type {
    RXPopMenu * menu = [[RXPopMenu alloc] initWithFrame:[UIScreen mainScreen].bounds];
    menu.backgroundColor = [UIColor clearColor];
    menu.menuType = type;
    return menu;
}

+ (void)hideBy:(id)target {
    UIViewController * targetVC;
    UIView * containerView;
    if ([target isKindOfClass:[UIView class]]) {
        targetVC = [RXPopMenu VCForShowView:target];
    } else {
        targetVC = target;
    }
    if (targetVC.navigationController) {
        containerView = targetVC.navigationController.view;
    } else {
        containerView = targetVC.view;
    }
    [containerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:self]) {
            RXPopMenu * menu = (RXPopMenu *)obj;
            [menu hideMenu];
            obj = nil;
            *stop = YES;
        }
    }];
}

- (void)hideMenu {
    [self removeFromSuperview];
    if (self.menuHideDone) {
        self.menuHideDone();
    }
}

- (void)showBy:(id)target withItems:(NSArray <RXPopMenuItem *>*)items keyboardHeight:(CGFloat)keyboardHeight {
    self.visibleHeight = RXScreenHeight - keyboardHeight;
    self.targetView = target;
    if (![target isKindOfClass:[UIView class]] &&
        ![target isKindOfClass:[UIBarButtonItem class]]) {
        return;
    }
    if ([NSStringFromClass([[self.targetView superview] class]) isEqualToString:@"_UITAMICAdaptorView"]) {
        self.inNaviBar = YES; // 在navigationBar上面
    }
    self.items = items;
    UIViewController * targetVC = [RXPopMenu VCForShowView:self.targetView];
    if (targetVC.navigationController) {
        [targetVC.navigationController.view addSubview:self];
    } else {
        [targetVC.view addSubview:self];
    }
    UIImpactFeedbackStyle style;
    if (@available(iOS 13.0, *)) {
        style = UIImpactFeedbackStyleSoft;
    } else {
        style = UIImpactFeedbackStyleMedium;
    }
    UIImpactFeedbackGenerator * generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:style];
    [generator impactOccurred];
}

- (void)showBy:(id)target withItems:(NSArray <RXPopMenuItem *>*)items {
    [self showBy:target withItems:items keyboardHeight:0];
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
        if (!_hideArrow) [self popArrow];
        [self.popTableView reloadData];
    }
}

- (CGSize)menuSize {
    if (CGSizeEqualToSize(CGSizeZero, _menuSize)) {
        switch (self.menuType) {
            case RXPopMenuList: {
                CGFloat MINWIDTH = self.hideImage ? 70.f : 100.f;
                RXPopMenuItem * maxItem;
                for (RXPopMenuItem * item in _items) {
                    if (item.title.length > maxItem.title.length) {
                        maxItem = item;
                    }
                }
                CGFloat otherWidth = 30 + (self.hideImage ? 0.f : 30.f);
                CGFloat maxTextWidth = [maxItem.title sizeWithAttributes:@{NSFontAttributeName:self.titleFont}].width;
                CGFloat itemWidth = maxTextWidth + 1 + otherWidth;
                itemWidth = itemWidth <= MINWIDTH ? MINWIDTH : itemWidth;
                _menuSize = CGSizeMake(itemWidth, self.itemHeight * _items.count);
            } break;
                
            case RXPopMenuBox: {
                NSInteger line = _items.count/5 + (_items.count%5>0);
                CGFloat width = MIN(_items.count, 5)*RXPopBoxItemWidth + 20;
                CGFloat height = line*self.itemHeight + (line-1)*10 + 20;
                _menuSize = CGSizeMake(width, height);
            } break;
            default:  break;
        }
    }
    return _menuSize;
}

- (void)setMenuSize:(CGSize)menuSize {
    if (!CGSizeEqualToSize(_menuSize, menuSize)) {
        _menuSize = menuSize;
        switch (self.menuType) {
            case RXPopMenuList: {
                self.popTableView.frame = CGRectMake(0, 0, _menuSize.width, _menuSize.height);
            } break;
            case RXPopMenuBox: {
                self.popCollectionView.frame = CGRectMake(0, 0, _menuSize.width, _menuSize.height);
            } break;
            default:
                break;
        }
    }
}

- (CGFloat)itemHeight {
    CGFloat height = self.menuType == RXPopMenuList ? 50.f : 54.f;
    return _itemHeight <= 0 ? height : _itemHeight;
}

- (void)setItemHeight:(CGFloat)itemHeight {
    if (_itemHeight != itemHeight) {
        _itemHeight = itemHeight;
        [_popTableView reloadData];
        [_popCollectionView reloadData];
    }
}

- (UIColor *)backColor {
    return _backColor ? : [[UIColor blackColor] colorWithAlphaComponent:0.8];
}

- (void)setBackColor:(UIColor *)backColor {
    _backColor = backColor;
}

- (CGFloat)cornerRadius {
    return _cornerRadius <= 0 ? 4.f : _cornerRadius;
}

- (UIFont *)titleFont {
    return _titleFont ? : [UIFont systemFontOfSize:_menuType == RXPopMenuList ? 16.f : 13.f];
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    [_popTableView reloadData];
}

- (UIColor *)titleColor {
    return _titleColor ? : [UIColor whiteColor];
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    [_popTableView reloadData];
    [_popCollectionView reloadData];
}

- (UIColor *)lineColor {
    return _lineColor ? : [UIColor whiteColor];
}

#pragma mark - Lazy Load

- (UITableView *)popTableView {
    if (!_popTableView) {
        _popTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.menuSize.width, self.menuSize.height)];
        _popTableView.bounces = NO;
        _popTableView.delegate = self;
        _popTableView.dataSource = self;
        _popTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _popTableView.tableFooterView = [[UIView alloc] init];
        _popTableView.backgroundColor = [UIColor clearColor];
        _popTableView.layer.cornerRadius = self.cornerRadius;
        _popTableView.layer.masksToBounds = YES;
        if (@available(iOS 11, *)) {
            _popTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_popTableView registerNib:[UINib nibWithNibName:RXPopMenuCellID bundle:[NSBundle mainBundle]]
            forCellReuseIdentifier:RXPopMenuCellID];
    }
    return _popTableView;
}

- (UICollectionView *)popCollectionView {
    if (!_popCollectionView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(RXPopBoxItemWidth, self.itemHeight);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 0;
        _popCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.menuSize.width, self.menuSize.height) collectionViewLayout:layout];
        _popCollectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
        _popCollectionView.delegate = (id)self;
        _popCollectionView.dataSource = self;
        _popCollectionView.bounces = NO;
        _popCollectionView.backgroundColor = self.backColor;;
        _popCollectionView.layer.cornerRadius = self.cornerRadius;
        _popCollectionView.layer.masksToBounds = YES;
        if (@available(iOS 11, *)) {
            _popCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_popCollectionView registerNib:[UINib nibWithNibName:RXPopBoxCellID bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:RXPopBoxCellID];
    }
    return _popCollectionView;
}

- (UIView *)popView {
    if (!_popView) {
        CGRect frame = [self getPopFrame];
        UIView * view = [[UIView alloc] initWithFrame:frame];
        view.layer.cornerRadius = self.cornerRadius;
        view.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.12].CGColor;
        view.layer.shadowOffset = CGSizeMake(0, 4);
        view.layer.shadowOpacity = 1;
        view.layer.shadowRadius = 10;
        _popView = view;
        
        switch (self.menuType) {
            case RXPopMenuList: {
                [_popView addSubview:self.popTableView];
            } break;
            case RXPopMenuBox: {
                [_popView addSubview:self.popCollectionView];
            } break;
            default: break;
        }
        [self addSubview:_popView];
    }
    return _popView;
}

- (RXPopMenuArrow *)popArrow {
    if (!_popArrow) {
        CGRect frame = [self getArrowFrame];
        _popArrow = [[RXPopMenuArrow alloc] initWithFrame:frame Color:self.backColor];
        [self addSubview:_popArrow];
        if (frame.origin.y <= self.targetViewFrame.origin.y) {
            _popArrow.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
        }
    }
    return _popArrow;
}

#pragma mark - Calculate Frame

- (CGRect)targetViewFrame {
    CGRect targetFrame;
    if (CGRectEqualToRect(_targetViewFrame, CGRectZero)) {
        CGRect targetRect = [self.targetView bounds];
        if (self.inNaviBar) {
            targetFrame = [self.targetView convertRect:targetRect toView:[RXPopMenu VCForShowView:self.targetView].navigationController.view];;
        } else {
            UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
            targetFrame = [self.targetView convertRect:targetRect toView:window];
            
            if (targetFrame.origin.y < 0) {
                targetFrame.size.height = MIN(self.visibleHeight, targetFrame.size.height + targetFrame.origin.y);
                targetFrame.origin.y = 0;
            } else {
                targetFrame.size.height = MIN(self.visibleHeight - targetFrame.origin.y, targetFrame.size.height);
            }
            CGFloat menuHei = self.menuSize.height + RXSafeTopHeight;
            if (targetFrame.origin.y < menuHei) {
                if (self.visibleHeight - targetFrame.origin.y - targetFrame.size.height < menuHei) {
                    targetFrame.origin.y = (targetFrame.origin.y + targetFrame.size.height)/2.0;
                }
            } else {
                targetFrame.size.height = self.visibleHeight - targetFrame.origin.y;
            }
        }
        targetFrame.origin.y = ceil(targetFrame.origin.y);
        _targetViewFrame = targetFrame;
    }
    return _targetViewFrame;
}

- (CGPoint)targetViewCenter {
    CGRect targetFrame = self.targetViewFrame;
    CGFloat centerX = targetFrame.origin.x + targetFrame.size.width/2.0;
    CGFloat centerY = targetFrame.origin.y + targetFrame.size.height/2.0;
    return CGPointMake(centerX, centerY);
}

- (CGRect)getPopFrame {
    CGRect targetFrame = self.targetViewFrame;
    CGPoint targetCenter = self.targetViewCenter;
    
    CGFloat menuWidth = self.menuSize.width;
    CGFloat menuHeight = self.menuSize.height;
    CGFloat spac = 10.f;
    
    CGRect popFrame = CGRectMake(targetCenter.x-menuWidth/2.0, 0, menuWidth, menuHeight);
    BOOL left = targetCenter.x / RXScreenWidth < 0.5;
    BOOL top = CGRectGetMinY(targetFrame) < menuHeight + RXSafeTopHeight;
    
    if (left) { // 左右边距控制
        popFrame.origin.x = MAX(popFrame.origin.x, spac);
    } else {
        popFrame.origin.x = MIN(popFrame.origin.x, RXScreenWidth-spac-menuWidth);
    }
    if (top) {  // 上下间距控制
        popFrame.origin.y = MAX(CGRectGetMaxY(targetFrame), spac) + RXArrowSize.height;
    } else {
        popFrame.origin.y = MIN(CGRectGetMinY(targetFrame) - menuHeight, self.visibleHeight-spac) - RXArrowSize.height;
    }
    popFrame.origin.y = ceil(popFrame.origin.y);
    return popFrame;
}

- (CGRect)getArrowFrame {
    CGRect targetFrame = self.targetViewFrame;
    
    CGFloat menuHeight = self.menuSize.height;
    BOOL top = CGRectGetMinY(targetFrame) < menuHeight + RXSafeTopHeight;
    
    CGRect arrowFrame = CGRectMake(0, 0, RXArrowSize.width, RXArrowSize.height);
    arrowFrame.origin.x = targetFrame.origin.x + targetFrame.size.width/2.0 - arrowFrame.size.width/2.0;
    
    if (top) {
        arrowFrame.origin.y = targetFrame.origin.y + targetFrame.size.height;
    } else {
        arrowFrame.origin.y = targetFrame.origin.y - RXArrowSize.height;
    }
    arrowFrame.origin.y = ceil(arrowFrame.origin.y);
    return arrowFrame;
}

- (void)setTargetView:(id)targetView {
    if (_targetView != targetView) {
        if ([targetView isKindOfClass:[UIView class]]) {
            _targetView = targetView;
        } else if ([targetView isKindOfClass:[UIBarButtonItem class]]) {
            if ([targetView customView]) {
                _targetView = [targetView customView];
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

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RXPopMenuItem * item = self.items[indexPath.row];
    item.index = indexPath.row;
    RXPopMenuCell * cell = [tableView dequeueReusableCellWithIdentifier:RXPopMenuCellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.rightLabel.text = item.title;
    cell.rightLabel.font = item.titleFont ? : self.titleFont;
    cell.rightLabel.textColor = item.titleColor ? : self.titleColor;
    cell.rightLabel.textAlignment = self.titleAlignment <= 0 ? (item.image ? NSTextAlignmentLeft : NSTextAlignmentCenter) : self.titleAlignment;
    cell.leftImageView.image = item.image ? [UIImage imageNamed:item.image] : nil;
    cell.imageViewWidth.constant = self.hideImage ? 0.f : 22.f;
    cell.spaceOfImageAndLabel.constant = self.hideImage ? 0.f : 8.f;
    cell.backColor = self.backColor;
    cell.lineView.backgroundColor = self.lineColor;
    
    BOOL lastOne = indexPath.row+1 == self.items.count;
    cell.lineView.hidden = lastOne;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.itemActions) {
        self.itemActions(self.items[indexPath.row]);
        [self hideMenu];
    }
}

#pragma mark - UICollectionView Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RXPopMenuItem * item = self.items[indexPath.row];
    item.index = indexPath.row;
    RXPopBoxCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:RXPopBoxCellID forIndexPath:indexPath];
    cell.bottomLabel.text = item.title;
    cell.bottomLabel.font = item.titleFont ? : self.titleFont;
    cell.bottomLabel.textColor = item.titleColor ? : self.titleColor;
    cell.bottomLabel.textAlignment = self.titleAlignment <= 0 ? NSTextAlignmentCenter : self.titleAlignment;
    cell.clipsToBounds = NO;
    cell.topImageView.image = item.image ? [UIImage imageNamed:item.image] : nil;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.itemActions) {
        self.itemActions(self.items[indexPath.row]);
        [self hideMenu];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hideMenu];
}

@end


@implementation RXPopMenuItem

+ (id)itemWithType:(RXPopMenuItemType)type {
    RXPopMenuItem * item = [[RXPopMenuItem alloc] init];
    NSString * title = nil;
    NSString * image = nil;
    switch (type) {
        case RXPopMenuItemRevoke:
            title = @"撤回"; image = @"im_longPress_revoke";
            break;
        case RXPopMenuItemEar:
            title = @"听筒播放"; image = @"im_longPress_ear";
            break;
        case RXPopMenuItemSpeaker:
            title = @"扬声器播放"; image = @"im_longPress_speaker";
            break;
        case RXPopMenuItemDelete:
            title = @"删除"; image = @"im_longPress_delete";
            break;
        case RXPopMenuItemQuote:
            title = @"引用"; image = @"im_longPress_quote";
            break;
        case RXPopMenuItemMulti:
            title = @"多选"; image = @"im_longPress_multi";
            break;
        case RXPopMenuItemTransfer:
            title = @"转文字"; image = @"im_longPress_transfer";
            break;
        case RXPopMenuItemCloseText:
            title = @"收起文字"; image = @"im_longPress_transfer";
            break;
        case RXPopMenuItemForward:
            title = @"转发"; image = @"im_longPress_forward";
            break;
        case RXPopMenuItemShare:
            title = @"分享"; image = @"im_longPress_share";
            break;
        case RXPopMenuItemRead:
            title = @"朗读"; image = @"im_longPress_read";
            break;
        case RXPopMenuItemCopy:
            title = @"复制"; image = @"im_longPress_copy";
            break;
        default:
            break;
    }
    item.itemType = type;
    item.title = title;
    item.image = image;
    return item;
}

+ (id)itemTitle:(NSString *)title image:(NSString *)image {
    RXPopMenuItem * item = [[RXPopMenuItem alloc] init];
    item.title = title;
    item.image = image;
    return item;
}

+ (id)itemTitle:(NSString *)title {
    RXPopMenuItem * item = [[RXPopMenuItem alloc] init];
    item.title = title;
    item.image = nil;
    return item;
}

+ (id)itemTitle:(NSString *)title titleColor:(UIColor *)color {
    RXPopMenuItem * item = [RXPopMenuItem itemTitle:title];
    item.titleColor = color;
    return item;
}

@end

