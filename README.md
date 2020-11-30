# ZDFlexLayout

#### 简介：

扩展`YGLayout`，增加对虚拟视图，异步计算、`UIScrollView`自适应的支持，修复了计算`UILabel`尺寸精度缺失导致文字截断问题。

#### 特色：

+ 支持虚拟视图（`virtual view`）

+ 支持链式调用

+ 支持异步(`runloop` / `thread`)计算布局

+ 支持利用`runloop`机制自动更新布局

+ 支持`UIScrollView`布局


    > 拒绝使用`runtime`的方法交换更新布局
    
> PS：开启自动更新布局时，当布局发生改变需要更新时需要手动调用 `markDirty`方法；`gone`不用，它内部会自己调用

#### 资料：

+ [Flex排版源码分析](https://juejin.im/post/5ad1c4a8f265da2389262828)

+ [LayoutPlayground](https://yogalayout.com/playground)

+ [Flex布局教程：语法篇](http://www.ruanyifeng.com/blog/2015/07/flex-grammar.html)


