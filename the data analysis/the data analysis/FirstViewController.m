//
//  FirstViewController.m
//  the data analysis
//
//  Created by yinghu on 2017/6/6.
//  Copyright © 2017年 yinghu. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()
@property (nonatomic, copy) NSString *growingTag;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    self.growingTag = @"FirstViewController";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
