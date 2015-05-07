//
//  NJCycleScrollView.h
//  Fun
//
//  Created by 念纪 on 15/4/1.
//  Copyright (c) 2015年 cnbluebox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NJCycleScrollView;
@class NJCycleScrollReusableView;
@protocol NJCycleScrollViewDataSource;

@protocol NJCycleScrollViewDelegate <NSObject, UIScrollViewDelegate>

@optional
- (void)scrollView:(NJCycleScrollView *)scrollView didScrollFromPage:(NSInteger)oldPage toPage:(NSInteger)page;
- (void)scrollView:(NJCycleScrollView *)scrollView didSelectPage:(NSInteger)page;

@end

#pragma mark - NJCycleScrollView
/**
 *  一个可以横向循环滚动的scrollView, 适用于banner
 */
@interface NJCycleScrollView : UIView <UIScrollViewDelegate>
{
@protected
    NSInteger               _currentPage;
    
    UIScrollView            *_scrollView;
    
    NSInteger               _numberOfPages;
    NSMutableArray          *_visiblePages;
    NSMutableArray          *_reusablePages;
    NSMutableDictionary     *_reusableClassesDic;
    
    BOOL                    _isOffsetLeft;
}

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, weak) id <NJCycleScrollViewDataSource> dataSource;
@property (nonatomic, weak) id <NJCycleScrollViewDelegate>   delegate;

@property (nonatomic, readonly, strong) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL autoscroll;
@property (nonatomic, assign) NSTimeInterval autoscrollInterval;

- (NSInteger)numberOfPages;
- (void)reloadData;
- (void)scrollToPage:(NSInteger)index;
- (void)scrollToPage:(NSInteger)index animated:(BOOL)animated duration:(CGFloat)duration;

- (void)registerClass:(Class)pageClass forPageReuseIdentifier:(NSString *)identifier;
- (id)dequeueReusablePageWithIdentifier:(NSString *)identifier;

@end

#pragma mark - NJCycleScrollViewDataSource

@protocol NJCycleScrollViewDataSource <NSObject>

@required
- (NSInteger)numberOfPagesInScrollView:(NJCycleScrollView *)pageScrollView;
- (NJCycleScrollReusableView *)scrollView:(NJCycleScrollView *)pageScrollView viewAtPage:(NSInteger)page;

@end

#pragma mark - NJCycleScrollReusableView

@interface NJCycleScrollReusableView : UIView

@property (nonatomic, copy) NSString *reuseIdentifier;
@property (nonatomic, strong) UIImageView *imageView;

@end