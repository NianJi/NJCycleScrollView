//
//  NJCycleScrollView.m
//  Fun
//
//  Created by 念纪 on 15/4/1.
//  Copyright (c) 2015年 cnbluebox.com. All rights reserved.
//

#import "NJCycleScrollView.h"

@interface NJCycleScrollReusableView ()
@property (nonatomic, copy) void (^touchedBlock) (NJCycleScrollReusableView *cell);
@end

@interface NJCycleScrollView ()
{
    NSTimer     *_autoscrollTimer;
}

@end

@implementation NJCycleScrollView

@synthesize scrollView = _scrollView;
@synthesize currentPage = _currentPage;

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"currentPage"];
    _scrollView.delegate = nil;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _scrollView.decelerationRate = 1.0;
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = YES;
        _scrollView.pagingEnabled = YES;
        _scrollView.userInteractionEnabled = YES;
        _scrollView.clipsToBounds = NO;
        _scrollView.scrollEnabled = YES;
        _scrollView.scrollsToTop = NO;
    }
    return _scrollView;
}

- (void)setUp
{
    _numberOfPages = 1;
    _visiblePages = [[NSMutableArray alloc] initWithCapacity:3];
    _reusablePages = [[NSMutableArray alloc] initWithCapacity:3];
    _autoscrollInterval = 5.;
    self.scrollView.frame = self.bounds;
    [self addSubview:self.scrollView];
    
    [self addObserver:self
           forKeyPath:@"currentPage"
              options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
              context:NULL];
}

- (void)didMoveToSuperview
{
    [self reloadData];
}

- (void)scrollToPage:(NSInteger)index
{
    [self scrollToPage:index animated:YES duration:0.35f];
}

- (void)scrollToPage:(NSInteger)index animated:(BOOL)animated duration:(CGFloat)duration
{
    if (_currentPage != index) {
        
        if (animated)
        {
            CATransition *animation = [CATransition animation];
            [animation setDuration:duration];
            [animation setFillMode:kCAFillModeForwards];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [animation setType:kCATransitionPush];
            [animation setSubtype:kCATransitionFromRight];
            
            [self.layer addAnimation:animation forKey:@"scroll"];
        }
        self.currentPage = index;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentPage"])
    {
        [self reloadData];
        
        NSInteger oldPage = [[change objectForKey:NSKeyValueChangeOldKey] integerValue];
        if ([_delegate respondsToSelector:@selector(scrollView:didScrollFromPage:toPage:)])
        {
            [_delegate scrollView:self didScrollFromPage:oldPage toPage:self.currentPage];
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
        [self setUp];
    }
    return self;
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
    if (!self.dataSource) {
        return;
    }
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
    
    if (self.scrollView.contentSize.width > self.scrollView.frame.size.width)
    {
        [_scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, 0)];
    }
}

- (void)updateVisiblePages
{
    int i = 0;
    NSUInteger count = [_visiblePages count];
    
    if (_numberOfPages == 2)
    {
        if (_isOffsetLeft) {
            if (count > 0) count--;
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

//将page的frame大小设置和scrollView一样大
- (void)setFrameForPage:(UIView *)page atIndex:(NSInteger)index
{
    page.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    CGRect frame = CGRectMake(self.scrollView.frame.size.width*index, 0.0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    page.frame = frame;
}

- (void)registerClass:(Class)pageClass forPageReuseIdentifier:(NSString *)identifier {
    
    NSAssert([pageClass isSubclassOfClass:[NJCycleScrollReusableView class]], @"pageClass should be a kind of NJCycleScrollReusableView");
    
    if (!_reusableClassesDic) {
        _reusableClassesDic = [NSMutableDictionary dictionary];
    }
    
    [_reusableClassesDic setObject:pageClass forKey:identifier];
}

- (id)dequeueReusablePageWithIdentifier:(NSString *)identifier {
    
    if ([_reusablePages count])
    {
        NSArray *pages = [_reusablePages copy];
        
        for (NJCycleScrollReusableView *pageView in pages)
        {
            if ([pageView.reuseIdentifier isEqualToString:identifier])
            {
                [_reusablePages removeObject:pageView];
                return pageView;
            }
        }
    }
    
    Class pageClass = [_reusableClassesDic objectForKey:identifier];
    if (pageClass) {
        NJCycleScrollReusableView *pageView = [[NJCycleScrollReusableView alloc] init];
        pageView.reuseIdentifier = identifier;
        return pageView;
    }
    
    return nil;
}

- (id)dequeueReusablePageWithClass:(Class)className
{
    if ([_reusablePages count])
    {
        NSArray *pages = [_reusablePages copy];
        
        for (id page in pages)
        {
            if ([page isKindOfClass:className])
            {
                [_reusablePages removeObject:page];
                return page;
            }
        }
    }
    return nil;
}

//keep _reusablePages max count 3
- (void)addPagesToReusableArray:(NSArray *)pages
{
    NSInteger totalCount = _reusablePages.count + pages.count;
    if (totalCount > 3)
    {
        NSInteger removeCount = totalCount - 3;
        NSInteger fRemoveCount = MIN(removeCount, _reusablePages.count);
        [_reusablePages removeObjectsInRange:NSMakeRange(0, fRemoveCount)];
    }
    
    [_reusablePages addObjectsFromArray:pages];
}

- (UIView *)loadPageAtIndex:(NSInteger)index
{
    NJCycleScrollReusableView *visiblePage = [self.dataSource scrollView:self viewAtPage:index];
    NSAssert([visiblePage isKindOfClass:[NJCycleScrollReusableView class]], @"page should be NJCycleScrollReusableView");
    visiblePage.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    __weak typeof(self) weakSelf = self;
    [visiblePage setTouchedBlock:^(NJCycleScrollReusableView *cell) {
        __strong typeof(weakSelf) sself = weakSelf;
        if (sself && [sself.delegate respondsToSelector:@selector(scrollView:didSelectPage:)]) {
            [sself.delegate scrollView:sself didSelectPage:index];
        }
    }];
    return visiblePage;
}

- (NSArray *)getDisplayImagesWithCurpage:(NSInteger)page
{
    if([_visiblePages count] != 0)
    {
        [self addPagesToReusableArray:_visiblePages];
        [_visiblePages removeAllObjects];
    }
    
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
        NSInteger pre = [self validPageValue:_currentPage-1];
        NSInteger last = [self validPageValue:_currentPage+1];
        
        
        [_visiblePages addObject:[self loadPageAtIndex:pre]];
        [_visiblePages addObject:[self loadPageAtIndex:_currentPage]];
        [_visiblePages addObject:[self loadPageAtIndex:last]];
        
    }
    
    return _visiblePages;
}


- (NSInteger)validPageValue:(NSInteger)value {
    
    if(value == -1) value = _numberOfPages-1;
    if(value == _numberOfPages) value = 0;
    
    return value;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
    int x = aScrollView.contentOffset.x;
    
    // 水平滚动
    // 往下翻一张
    if(x >= (2*self.frame.size.width)) {
        self.currentPage = [self validPageValue:_currentPage+1];
    }
    if(x <= 0) {
        self.currentPage = [self validPageValue:_currentPage-1];
    }
    
    if (x < self.frame.size.width) {
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
    [self stopAutoscroll];
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startAutoscroll];
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

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
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

#pragma mark - autoscroll

- (void)setAutoscroll:(BOOL)autoscroll {
    if (_autoscroll != autoscroll) {
        _autoscroll = autoscroll;
        if (autoscroll) {
            
            [self startAutoscroll];
            
        } else {
            
            [self stopAutoscroll];
        }
    }
}

- (void)setAutoscrollInterval:(NSTimeInterval)autoscrollInterval
{
    if (autoscrollInterval < 1)
    {
        autoscrollInterval = 1.0f;
    }
    _autoscrollInterval = autoscrollInterval;
}

- (void)startAutoscroll
{
    if (self.autoscroll && _numberOfPages > 1)
    {
        [_autoscrollTimer invalidate];
        _autoscrollTimer = [NSTimer scheduledTimerWithTimeInterval:_autoscrollInterval target:self selector:@selector(autoscrollTimerFired) userInfo:nil repeats:YES];
    }
}

- (void)stopAutoscroll
{
    [_autoscrollTimer invalidate];
    _autoscrollTimer = nil;
}

- (void)autoscrollTimerFired
{
    [self scrollToPage:_currentPage+1 <= _numberOfPages-1 ? _currentPage + 1 : 0];
}

@end

#pragma mark - NJCycleScrollReusableView

@implementation NJCycleScrollReusableView

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = self.bounds;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if (touch)
    {
        CGPoint location = [touch locationInView:self];
        if (location.x < self.width && location.x > 0 &&
            location.y < self.height && location.y > 0)
        {
            if (_touchedBlock) {
                _touchedBlock(self);
            }
        }
    }
}

@end
