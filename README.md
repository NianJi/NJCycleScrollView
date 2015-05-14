NJCycleScrollView
=================

> 1. 这是一个可循环的scrollView, 使用方法类似于UITableView. 通过实现dataSource方法来管理子页面：

```
- (NSInteger)numberOfPagesInScrollView:(NJCycleScrollView *)pageScrollView;
- (NJCycleScrollReusableView *)scrollView:(NJCycleScrollView *)pageScrollView viewAtPage:(NSInteger)page;

```

> 2. 实现了重用机制，最多加载3张页面，不会担心页面过多的内存问题。

> 3. 自动滚动功能的实现，过渡平滑。 


