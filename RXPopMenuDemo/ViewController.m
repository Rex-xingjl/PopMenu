//
//  ViewController.m
//  RXPopMenuDemo
//
//  Created by Rex on 2018/3/7.
//  Copyright © 2018年 Rex. All rights reserved.
//

#import "ViewController.h"
#import "RXPopMenu.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (IBAction)popListAction:(id)sender {
    NSArray * showItems = @[[RXPopMenuItem itemTitle:@"发起讨论组" image:@"im_groupadd"],
                            [RXPopMenuItem itemTitle:@"扫一扫" image:@"im_sweep"],
                            [RXPopMenuItem itemTitle:@"发到电脑" image:@"im_sendpc"]
    ];
    RXPopMenu * menu = [RXPopMenu menu];
    [menu showBy:sender withItems:showItems];
    __weak typeof(self) weak = self;
    menu.itemActions = ^(RXPopMenuItem *item) {
        __strong typeof(self) strong = weak;
        NSLog(@"%@", item.title);
        UIViewController * vc = [[UIViewController alloc] init];
        [strong.navigationController pushViewController:vc animated:YES];
    };
}

- (IBAction)popBoxAction:(id)sender {
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:@(RXPopMenuItemRevoke)];
    [items addObject:@(RXPopMenuItemEar)];
    [items addObject:@(RXPopMenuItemTransfer)];
    [items addObject:@(RXPopMenuItemCopy)];
    [items addObject:@(RXPopMenuItemRead)];
    [items addObject:@(RXPopMenuItemForward)];
    [items addObject:@(RXPopMenuItemShare)];
    [items addObject:@(RXPopMenuItemQuote)];
    [items addObject:@(RXPopMenuItemMulti)];
    [items addObject:@(RXPopMenuItemDelete)];
    
    NSMutableArray * menuItems = [[NSMutableArray alloc] init];
    for (id item in items) {
        RXPopMenuItemType itemType = [item integerValue];
        [menuItems addObject:[RXPopMenuItem itemWithType:itemType]];
    }
    RXPopMenu * menu = [RXPopMenu menuWithType:RXPopMenuBox];
    [menu showBy:sender withItems:menuItems];
    __weak typeof(self) weak = self;
    menu.itemActions = ^(RXPopMenuItem *item) {
//        __strong typeof(self) strong = weak;
    };
    menu.menuHideDone = ^{
//        __strong typeof(self) strong = weak;
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
