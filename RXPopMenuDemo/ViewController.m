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

- (IBAction)openBtnAction:(UIButton *)sender {
    NSArray * showItems = @[[RXPopMenuItem itemTitle:@"发起讨论组" image:@"im_groupadd"],
                            [RXPopMenuItem itemTitle:@"扫一扫" image:@"im_sweep"],
                            [RXPopMenuItem itemTitle:@"发到电脑" image:@"im_sendpc"]
                            ];
    RXPopMenu * menu = [RXPopMenu menu];
    [menu showBy:sender withItems:showItems];
    menu.itemActions = ^(RXPopMenuItem *item) {
        NSLog(@"%@", item.title);
        UIViewController * vc = [[UIViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
