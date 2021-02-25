# ZDFlexLayout

#### 简介：

扩展`YGLayout`，增加对虚拟视图，异步计算、`UIScrollView`自适应的支持，修复了计算`UILabel`尺寸精度缺失导致文字截断问题。

#### 特色：

+ 支持虚拟视图（`virtual view`）

+ 支持链式调用

+ 支持异步(`runloop` / `thread`)计算布局

+ 支持利用`runloop`机制自动更新布局

+ 支持`UIScrollView`布局

    
> PS：开启自动更新布局后，在布局发生改变需要更新时需要手动调用 `markDirty`方法（`gone`不需要调用`markDirty`，它内部会自己处理）

#### 安装：

```ruby
pod 'ZDFlexLayoutKit'
```

> 默认是包含`Objective-C`与`Swift`的混编`pod`，如果只是用于纯`OC`工程，可以仅引用`OC`版本
>
> 从 `0.1.2` 开始支持 `Swift`

```ruby
pod 'ZDFlexLayoutKit', :subspecs => ['OCMaker']
```

> 支持编译为静态库，但如果想使用`Literal`字面量特性，需要把这个`repo`编译为`framework`的形式，比如在`podfile`中开启`use_framework!`或者其他方式让它以动态库的形式存在
>
> 如果它被编译为了动态库，其依赖`yoga`也需要以动态库的形式存在，即动态库不能依赖静态库

#### 资料：

+ [Flex排版源码分析](https://juejin.im/post/5ad1c4a8f265da2389262828)

+ [LayoutPlayground](https://yogalayout.com/playground)

+ [Flex布局教程：语法篇](http://www.ruanyifeng.com/blog/2015/07/flex-grammar.html)


