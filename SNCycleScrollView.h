//
//  SNCycleScrollView.h
//  SuningEBuy
//
//  Created by  liukun on 13-4-16.
//  Copyright (c) 2013年 Suning. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNCycleScrollView;
@protocol SNCycleScrollViewDataSource;

@protocol SNCycleScrollViewDelegate <NSObject, UIScrollViewDelegate>

@optional
- (void)scrollView:(SNCycleScrollView *)scrollView
    scrollFromPage:(NSInteger)oldPage
            toPage:(NSInteger)page;


@end

// ------------------------------------------------------------------------------------------------------------------------------------------------------



@interface SNCycleScrollView : UIView <UIScrollViewDelegate>
{
    @protected
    NSInteger       _currentPage;
    
    id<SNCycleScrollViewDataSource>  _dataSource;        //weak
    id<SNCycleScrollViewDelegate>    _delegate;          //weak 注意不能将delegate设为self
    
    UIScrollView                    *_scrollView;
    
    NSInteger               _numberOfPages;
    NSMutableArray          *_visiblePages;
    
    BOOL                    _isOffsetLeft;
}

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, assign)   id <SNCycleScrollViewDataSource> dataSource;
@property (nonatomic, assign)   id <SNCycleScrollViewDelegate>   delegate;

@property (nonatomic, readonly, retain) UIScrollView *scrollView;

- (NSInteger)numberOfPages;
- (void)reloadData;
- (void)scrollToPage:(NSInteger)index;
- (void)changeScrollViewEnable:(BOOL)enAble;
@end

// ------------------------------------------------------------------------------------------------------------------------------------------------------

@protocol SNCycleScrollViewDataSource <NSObject>

@required

- (NSInteger)numberOfPagesInScrollView:(SNCycleScrollView *)pageScrollView;


- (UIView *)scrollView:(SNCycleScrollView *)pageScrollView viewAtPage:(NSInteger)page;

@end



