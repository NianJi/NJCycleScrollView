//
//  SNCycleScrollView.m
//  SuningEBuy
//
//  Created by  liukun on 13-4-16.
//  Copyright (c) 2013年 Suning. All rights reserved.
//

#import "SNCycleScrollView.h"

@implementation SNCycleScrollView

@synthesize scrollView = _scrollView;
@synthesize currentPage = _currentPage;

- (void)dealloc
{
    _scrollView.delegate = nil;
    _scrollView.dataSource = nil;
    [_scrollView release]; _scrollView = nil;

    [_visiblePages release]; _visiblePages = nil;

    [self removeObserver:self forKeyPath:@"currentPage"];
    
    [super dealloc];
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.decelerationRate = 1.0;
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = YES;
        _scrollView.pagingEnabled = YES;
        _scrollView.userInteractionEnabled = YES;
        _scrollView.clipsToBounds = NO;
        _scrollView.scrollEnabled = YES;
    }
    return _scrollView;
}

- (void)changeScrollViewEnable:(BOOL)enAble
{
    if (enAble) {
        _scrollView.scrollEnabled = YES;
    }else{
        _scrollView.scrollEnabled = NO;
    }
}

- (void)setUp
{
    _numberOfPages = 1;
    _visiblePages = [[NSMutableArray alloc] initWithCapacity:3];
    
    [self addSubview:self.scrollView];
    
    [self addObserver:self
           forKeyPath:@"currentPage"
              options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
              context:NULL];
}

- (void)scrollToPage:(NSInteger)index
{
    if (_currentPage != index) {
        
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.35f];
        [animation setFillMode:kCAFillModeForwards];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromLeft];
        
        [self.layer addAnimation:animation forKey:nil];
        self.currentPage = index;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentPage"])
    {
        [self reloadData];
        
        int oldPage = [[change objectForKey:NSKeyValueChangeOldKey] intValue];
        if ([_delegate respondsToSelector:@selector(scrollView:scrollFromPage:toPage:)])
        {
            [_delegate scrollView:self scrollFromPage:oldPage toPage:self.currentPage];
        }
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (NSInteger)numberOfPages
{
    return _numberOfPages;
}

- (void)setNumberOfPages:(NSInteger)number
{
    _numberOfPages = number;
    if (_numberOfPages > 1)
    {
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * 3,
                                             _scrollView.frame.size.height);
    }
    else
    {
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width,
                                             _scrollView.frame.size.height);
    }
}

- (void)reloadData
{
    NSInteger numPages = 1;
	if ([self.dataSource respondsToSelector:@selector(numberOfPagesInScrollView:)])
    {
		numPages = [self.dataSource numberOfPagesInScrollView:self];
	}
    
    // remove all subviews from scrollView
    [[self.scrollView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
	[self setNumberOfPages:numPages];
    [self getDisplayImagesWithCurpage:self.currentPage];
    
    [self updateVisiblePages];
    
    if (self.scrollView.contentSize.width > self.scrollView.size.width)
    {
        [_scrollView setContentOffset:CGPointMake(self.scrollView.size.width, 0)];
    }
}

- (void)updateVisiblePages
{
    int i = 0;
    int count = [_visiblePages count];
    
    if (_numberOfPages == 2)
    {
        if (_isOffsetLeft) {
            count--;
        }else{
            i++;
        }
    }
    
    for (; i < count; i++)
    {
        
        UIView *view = [_visiblePages objectAtIndex:i];
        [self setFrameForPage:view atIndex:i];
        [_scrollView addSubview:view];
    }
    
}

- (void)setFrameForPage:(UIView *)page atIndex:(NSInteger)index
{
    CGRect frame = CGRectMake(self.scrollView.frame.size.width*index, 0.0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
	page.frame = frame;
    
}

- (UIView *)loadPageAtIndex:(NSInteger)index
{
	UIView *visiblePage = [self.dataSource scrollView:self viewAtPage:index];
    
    return visiblePage;
}

- (NSArray *)getDisplayImagesWithCurpage:(int)page
{
    if([_visiblePages count] != 0) [_visiblePages removeAllObjects];

    if (self.numberOfPages == 0)
    {
        return _visiblePages;
    }
    if (self.numberOfPages <= 1)
    {
        [_visiblePages addObject:[self loadPageAtIndex:self.currentPage]];
    }
    else
    {
        int pre = [self validPageValue:_currentPage-1];
        int last = [self validPageValue:_currentPage+1];
        
        
        [_visiblePages addObject:[self loadPageAtIndex:pre]];
        [_visiblePages addObject:[self loadPageAtIndex:_currentPage]];
        [_visiblePages addObject:[self loadPageAtIndex:last]];
        
    }
    
    return _visiblePages;
}


- (int)validPageValue:(NSInteger)value {
    
    if(value == -1) value = _numberOfPages-1; 
    if(value == _numberOfPages) value = 0;
    
    return value;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
    int x = aScrollView.contentOffset.x;
    
    // 水平滚动
    // 往下翻一张
    if(x >= (2*self.size.width)) {
        self.currentPage = [self validPageValue:_currentPage+1];
    }
    if(x <= 0) {
        self.currentPage = [self validPageValue:_currentPage-1];
    }
    
    if (x < self.size.width) {
        _isOffsetLeft = YES;
    }else{
        _isOffsetLeft = NO;
    }
    
    if (_numberOfPages == 2) {
        [self updateVisiblePages];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:self.scrollView];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [self.delegate scrollViewDidZoom:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_5_0){
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.delegate scrollViewWillBeginDecelerating:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.delegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [self.delegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_2)
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [self.delegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [self.delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        [self.delegate scrollViewShouldScrollToTop:scrollView];
    }
    return NO;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [self.delegate scrollViewDidScrollToTop:scrollView];
    }
}

@end
