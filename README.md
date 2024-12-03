# ZDFlexLayoutKit

## Intro

基于 `Yoga` 引擎二次开发的给 `iOS` 用的盒子布局~

## Feature

+ 虚拟视图

+ 链式调用

+ 异步计算

+ 自动更新布局

+ 支持`UIScrollView`布局

+ `UITableViewCell`、`UICollectionViewCell` 高度自动计算


> PS：开启自动更新布局后，在布局发生改变需要更新时需要手动调用 `markDirty` ，`gone` 不需要调用 `markDirty` ，它内部会自己处理

## Install

```ruby
pod 'ZDFlexLayoutKit'
pod 'Yoga', :podspec => 'https://github.com/faimin/ZDFlexLayoutKit/blob/master/Yoga.podspec' # 你也可以指定自己的`Yoga podspec`
```

> 从 `0.1.2` 开始支持 `Swift`
>
> 支持编译为静态库，但如果想使用`Literal`字面量特性，需要把这个`repo`编译为`framework`的形式，比如在`podfile`中开启`use_framework!`或者[其他方式](#dynamic_framework_setting)让它以`framework`的形式存在
>
> 如果它被编译为了动态库，其依赖的 `yoga` 也需要以动态库的形式集成，即动态库不能依赖静态库

## Usage

> Swift

```swift
avatarImgView.zd.makeFlexLayout {
    $0.position(.absolute)
    $0.width(100%).height(100%)
}
gradientView.zd.makeFlexLayout {
    $0.position(.relative).flexDirection(.column)
    $0.paddingHorizontal(8)
    $0.width(100%)
}
titleLabel.zd.makeFlexLayout { (make) in
    make.marginTop(3.5)
    make.width(100%)
    make.flexShrink(1)
}
// 虚拟视图
let userInfoDiv = ZDFlexLayoutDiv.zd.makeFlexLayout { (make) in
    make.flexDirection(.row)
    make.alignItems(.center)
    make.marginTop(2.5)
    make.marginBottom(6)
}

// 这里需要调用 `addChildren` 函数，因为我们重新构建了视图树
gradientView.addChildren([titleLabel, avatarImgView])
userInfoDiv.addChildren([gradientView])

// 计算布局，以下2种方式皆可，第二种会当你标记为mark之后会在runloop空闲时自动计算布局
//userInfoDiv.calculateLayoutPreservingOrigin(true, dimensionFlexibility: .flexibleHeight)
userInfoDiv.calculateLayout(withAutoRefresh: true, preservingOrigin: false, dimensionFlexibility: .flexibleHeight)
```

> Objective-C

```objective-c
[self zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
    make.flexDirection(YGFlexDirectionColumn).flexWrap(YGWrapWrap).alignContent(YGAlignCenter);
}];
[self.iconimageV zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
    // 属性设置支持链式调用
    make.marginLeft(YGPointValue(10)).marginTop(YGPointValue(6)).marginBottom(YGPointValue(6)).width(YGPointValue(20)).height(YGPointValue(20));
}];
[self.contentLabel zd_makeFlexLayout:^(ZDFlexLayoutMaker * _Nonnull make) {
    make.marginLeft(YGPointValue(5)).marginRight(YGPointValue(10));
}];
[self calculateLayoutWithAutoRefresh:YES preservingOrigin:YES dimensionFlexibility:ZDDimensionFlexibilityFlexibleHeight];
```

## dynamic_framework_setting

```ruby
pre_install do |installer|
    dynamic_framework = ['ZDFlexLayoutKit','Yoga']
    Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
    installer.pod_targets.each do |pod|
      if dynamic_framework.include?(pod.name)
        def pod.build_type;
          Pod::BuildType.dynamic_framework
        end
      end
    end
end
```

## Learning materials

+ [由 FlexBox 算法强力驱动的 Weex 布局引擎](https://halfrost.com/weex_flexbox/)

+ [Flex排版源码分析](https://juejin.im/post/5ad1c4a8f265da2389262828)

+ [LayoutPlayground](https://yogalayout.com/playground)

+ [Flex布局教程：语法篇](http://www.ruanyifeng.com/blog/2015/07/flex-grammar.html)


