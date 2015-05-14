//
//  ViewController.m
//  NJCycleScrollViewDemo
//
//  Created by 念纪 on 15/5/14.
//  Copyright (c) 2015年 bluebox. All rights reserved.
//

#import "ViewController.h"
#import "NJCycleScrollView.h"

@interface ViewController () <NJCycleScrollViewDataSource, NJCycleScrollViewDelegate>
{
    NSArray *list;
}

@property (nonatomic, strong) NJCycleScrollView *cycleScrollView;

@end

@implementation ViewController

- (void)awakeFromNib {
    list = @[
                  [UIColor redColor],
                  [UIColor grayColor],
                  [UIColor blueColor],
                  [UIColor greenColor],
                  [UIColor cyanColor],
                  ];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.cycleScrollView registerClass:[NJCycleScrollReusableView class] forPageReuseIdentifier:@"cell"];
    [self.view addSubview:self.cycleScrollView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_cycleScrollView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cycleScrollView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_cycleScrollView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cycleScrollView)]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.cycleScrollView.autoscroll = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.cycleScrollView.autoscroll = NO;
}

#pragma mark - datasource

- (NSInteger)numberOfPagesInScrollView:(NJCycleScrollView *)pageScrollView {
    
    return list.count;
}

- (NJCycleScrollReusableView *)scrollView:(NJCycleScrollView *)pageScrollView viewAtPage:(NSInteger)page {
    
    NJCycleScrollReusableView *cell = [pageScrollView dequeueReusablePageWithIdentifier:@"cell"];
    
    cell.backgroundColor = [list objectAtIndex:page];
    UILabel *label = (UILabel *)[cell viewWithTag:2];
    if (!label) {
        label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont systemFontOfSize:80];
        label.textColor = [UIColor whiteColor];
        label.tag = 2;
        [cell addSubview:label];
        
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:cell
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:cell
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:0
                                                        multiplier:1
                                                          constant:80]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:0
                                                        multiplier:1
                                                          constant:80]];
    }
    label.text = [NSString stringWithFormat:@"%ld", page];
    return cell;
}

#pragma mark - views

- (NJCycleScrollView *)cycleScrollView {
    
    if (!_cycleScrollView) {
        _cycleScrollView = [[NJCycleScrollView alloc] init];
        _cycleScrollView.backgroundColor = [UIColor lightGrayColor];
        _cycleScrollView.delegate = self;
        _cycleScrollView.dataSource = self;
        _cycleScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _cycleScrollView;
}


@end
