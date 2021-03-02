//
//  UIWebView+ZDUtility.m
//  ZDUtility
//
//  Created by Zero on 15/12/26.
//  Copyright © 2015年 Zero.D.Saber. All rights reserved.
//

#import "UIWebView+ZDUtility.h"
#import "ZDMacro.h"

ZD_AVOID_ALL_LOAD_FLAG_FOR_CATEGORY(UIWebView_ZDUtility)

@implementation UIWebView (ZDUtility)

#pragma mark -
#pragma mark 获取网页中的数据

///  获取某个标签的结点个数
- (NSInteger)nodeCountOfTag:(NSString *)tag {
	NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('%@').length", tag];
	NSInteger len = [[self stringByEvaluatingJavaScriptFromString:jsString] integerValue];

	return len;
}

///  获取当前页面URL
- (NSString *)getCurrentURL {
	return [self stringByEvaluatingJavaScriptFromString:@"document.location.href"];
}

///  获取标题
- (NSString *)getTitle {
	return [self stringByEvaluatingJavaScriptFromString:@"document.title"];
}

///  获取所有图片链接
- (NSArray<NSString *> *)getImgs {
	NSMutableArray<NSString *> *arrImgURL = [[NSMutableArray alloc] init];

	for (int i = 0; i < [self nodeCountOfTag:@"img"]; i++) {
		NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].src", i];
		[arrImgURL addObject:[self stringByEvaluatingJavaScriptFromString:jsString]];
	}

	return arrImgURL;
}

///  获取当前页面所有点击链接
- (NSArray<NSString *> *)getOnClicks {
	NSMutableArray<NSString *> *arrOnClicks = [[NSMutableArray alloc] init];

	for (int i = 0; i < [self nodeCountOfTag:@"a"]; i++) {
		NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('a')[%d].getAttribute('onclick')", i];
		NSString *clickString = [self stringByEvaluatingJavaScriptFromString:jsString];
		[arrOnClicks addObject:clickString];
	}

	return arrOnClicks;
}

#pragma mark -
#pragma mark 改变网页样式和行为

///  改变背景颜色
- (void)setBackgroundColor:(UIColor *)color {
	NSString *jsString = [NSString stringWithFormat:@"document.body.style.backgroundColor = '%@'", [color webColorString]];

	[self stringByEvaluatingJavaScriptFromString:jsString];
}

///  为所有图片添加点击事件(网页中有些图片添加无效,需要协议方法配合截取)
- (void)addClickEventOnImg {
	for (int i = 0; i < [self nodeCountOfTag:@"img"]; i++) {
		//利用重定向获取img.src，为区分，给url添加'img:'前缀
		NSString *jsString = [NSString stringWithFormat:
			@"document.getElementsByTagName('img')[%d].onclick = \
                              function() { document.location.href = 'img' + this.src; }", i];
		[self stringByEvaluatingJavaScriptFromString:jsString];
	}
}

///  改变所有图像的宽度
- (void)setImgWidth:(int)size {
	for (int i = 0; i < [self nodeCountOfTag:@"img"]; i++) {
		NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].width = '%d'", i, size];
		[self stringByEvaluatingJavaScriptFromString:jsString];

		jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].style.width = '%dpx'", i, size];
		[self stringByEvaluatingJavaScriptFromString:jsString];
	}
}

///  改变所有图像的高度
- (void)setImgHeight:(int)size {
	for (int i = 0; i < [self nodeCountOfTag:@"img"]; i++) {
		NSString *jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].height = '%d'", i, size];
		[self stringByEvaluatingJavaScriptFromString:jsString];

		jsString = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].style.height = '%dpx'", i, size];
		[self stringByEvaluatingJavaScriptFromString:jsString];
	}
}

///  改变指定标签的字体颜色
- (void)setFontColor:(UIColor *)color withTag:(NSString *)tagName {
	NSString *jsString = [NSString stringWithFormat:
		@"var nodes = document.getElementsByTagName('%@'); \
                          for(var i=0;i<nodes.length;i++){\
                          nodes[i].style.color = '%@';}", tagName, [color webColorString]];

	[self stringByEvaluatingJavaScriptFromString:jsString];
}

///  改变指定标签的字体大小
- (void)setFontSize:(int)size withTag:(NSString *)tagName {
	NSString *jsString = [NSString stringWithFormat:
		@"var nodes = document.getElementsByTagName('%@'); \
                          for(var i=0;i<nodes.length;i++){\
                          nodes[i].style.fontSize = '%dpx';}", tagName, size];

	[self stringByEvaluatingJavaScriptFromString:jsString];
}

@end

#pragma mark -
#pragma mark 在网页上画图

@implementation UIWebView (Canvas)

///  创建一个指定大小的透明画布
- (void)createCanvas:(NSString *)canvasId width:(NSInteger)width height:(NSInteger)height {
	NSString *jsString = [NSString stringWithFormat:
		@"var canvas = document.createElement('canvas');"
		"canvas.id = %@; canvas.width = %ld; canvas.height = %ld;"
		"document.body.appendChild(canvas);"
		"var g = canvas.getContext('2d');"
		"g.strokeRect(%ld,%ld,%ld,%ld);",
		canvasId, (long)width, (long)height, 0L, 0L, (long)width, (long)height];

	[self stringByEvaluatingJavaScriptFromString:jsString];
}

///  在指定位置创建一个指定大小的透明画布
- (void)createCanvas:(NSString *)canvasId width:(NSInteger)width height:(NSInteger)height x:(NSInteger)x y:(NSInteger)y {
	//[self createCanvas:canvasId width:width height:height];
	NSString *jsString = [NSString stringWithFormat:
		@"var canvas = document.createElement('canvas');"
		"canvas.id = %@; canvas.width = %ld; canvas.height = %ld;"
		"canvas.style.position = 'absolute';"
		"canvas.style.top = '%ld';"
		"canvas.style.left = '%ld';"
		"document.body.appendChild(canvas);"
		"var g = canvas.getContext('2d');"
		"g.strokeRect(%ld,%ld,%ld,%ld);",
		canvasId, (long)width, (long)height, (long)y, (long)x, 0L, 0L, (long)width, (long)height];

	[self stringByEvaluatingJavaScriptFromString:jsString];
}

///  绘制矩形填充  context.fillRect(x,y,width,height)
- (void)fillRectOnCanvas:(NSString *)canvasId
	x:(NSInteger)x y:(NSInteger)y
	width:(NSInteger)width
	height:(NSInteger)height
	color:(UIColor *)color {
	NSString *jsString = [NSString stringWithFormat:
		@"var canvas = document.getElementById('%@');"
		"var context = canvas.getContext('2d');"
		"context.fillStyle = '%@';"
		"context.fillRect(%ld,%ld,%ld,%ld);"
		, canvasId, [color canvasColorString], (long)x, (long)y, (long)width, (long)height];

	[self stringByEvaluatingJavaScriptFromString:jsString];
}

///  绘制矩形边框  strokeRect(x,y,width,height)
- (void)strokeRectOnCanvas:(NSString *)canvasId
	x:(NSInteger)x
	y:(NSInteger)y
	width:(NSInteger)width
	height:(NSInteger)height
	color:(UIColor *)color
	lineWidth:(NSInteger)lineWidth {
	NSString *jsString = [NSString stringWithFormat:
		@"var canvas = document.getElementById('%@');"
		"var context = canvas.getContext('2d');"
		"context.strokeStyle = '%@';"
		"context.lineWidth = '%ld';"
		"context.strokeRect(%ld,%ld,%ld,%ld);"
		, canvasId, [color canvasColorString], (long)lineWidth, (long)x, (long)y, (long)width, (long)height];

	[self stringByEvaluatingJavaScriptFromString:jsString];
}

///  清除矩形区域  context.clearRect(x,y,width,height)
- (void)clearRectOnCanvas:(NSString *)canvasId
	x:(NSInteger)x
	y:(NSInteger)y
	width:(NSInteger)width
	height:(NSInteger)height {
	NSString *jsString = [NSString stringWithFormat:
		@"var canvas = document.getElementById('%@');"
		"var context = canvas.getContext('2d');"
		"context.clearRect(%ld,%ld,%ld,%ld);"
		, canvasId, (long)x, (long)y, (long)width, (long)height];

	[self stringByEvaluatingJavaScriptFromString:jsString];
}

///  绘制圆弧填充  context.arc(x, y, radius, starAngle,endAngle, anticlockwise)
- (void)arcOnCanvas:(NSString *)canvasId
	centerX:(NSInteger)x
	centerY:(NSInteger)y
	radius:(NSInteger)r
	startAngle:(float)startAngle
	endAngle:(float)endAngle
	anticlockwise:(BOOL)anticlockwise
	color:(UIColor *)color {
	NSString *jsString = [NSString stringWithFormat:
		@"var canvas = document.getElementById('%@');"
		"var context = canvas.getContext('2d');"
		"context.beginPath();"
		"context.arc(%ld,%ld,%ld,%f,%f,%@);"
		"context.closePath();"
		"context.fillStyle = '%@';"
		"context.fill();",
		canvasId, (long)x, (long)y, (long)r, startAngle, endAngle, anticlockwise ? @"true" : @"false", [color canvasColorString]];

	[self stringByEvaluatingJavaScriptFromString:jsString];
}

///  绘制一条线段 context.moveTo(x,y)  context.lineTo(x,y)
- (void)lineOnCanvas:(NSString *)canvasId
	x1:(NSInteger)x1
	y1:(NSInteger)y1
	x2:(NSInteger)x2
	y2:(NSInteger)y2
	color:(UIColor *)color
	lineWidth:(NSInteger)lineWidth {
	NSString *jsString = [NSString stringWithFormat:
		@"var canvas = document.getElementById('%@');"
		"var context = canvas.getContext('2d');"
		"context.beginPath();"
		"context.moveTo(%ld,%ld);"
		"context.lineTo(%ld,%ld);"
		"context.closePath();"
		"context.strokeStyle = '%@';"
		"context.lineWidth = %ld;"
		"context.stroke();",
		canvasId, (long)x1, (long)y1, (long)x2, (long)y2, [color canvasColorString], (long)lineWidth];

	[self stringByEvaluatingJavaScriptFromString:jsString];
}

///  绘制一条折线
- (void)linesOnCanvas:(NSString *)canvasId
	points:(NSArray *)points
	unicolor:(UIColor *)color
	lineWidth:(NSInteger)lineWidth {
	NSString *jsString = [NSString stringWithFormat:
		@"var canvas = document.getElementById('%@');"
		"var context = canvas.getContext('2d');"
		"context.beginPath();",
		canvasId];

	for (int i = 0; i < [points count] / 2; i++) {
		jsString = [jsString stringByAppendingFormat:@"context.lineTo(%@,%@);",
			points[i * 2], points[i * 2 + 1]];
	}

	jsString = [jsString stringByAppendingFormat:@""
												 "context.strokeStyle = '%@';"
												 "context.lineWidth = %ld;"
												 "context.stroke();",
		[color canvasColorString], (long)lineWidth];
	[self stringByEvaluatingJavaScriptFromString:jsString];
}

///  绘制贝塞尔曲线 context.bezierCurveTo(cp1x,cp1y,cp2x,cp2y,x,y)
- (void)bezierCurveOnCanvas:(NSString *)canvasId
	x1:(NSInteger)x1
	y1:(NSInteger)y1
	cp1x:(NSInteger)cp1x
	cp1y:(NSInteger)cp1y
	cp2x:(NSInteger)cp2x
	cp2y:(NSInteger)cp2y
	x2:(NSInteger)x2
	y2:(NSInteger)y2
	unicolor:(UIColor *)color
	lineWidth:(NSInteger)lineWidth {
	NSString *jsString = [NSString stringWithFormat:
		@"var canvas = document.getElementById('%@');"
		"var context = canvas.getContext('2d');"
		"context.beginPath();"
		"context.moveTo(%ld,%ld);"
		"context.bezierCurveTo(%ld,%ld,%ld,%ld,%ld,%ld);"
		"context.strokeStyle = '%@';"
		"context.lineWidth = %ld;"
		"context.stroke();",
		canvasId, (long)x1, (long)y1, (long)cp1x, (long)cp1y, (long)cp2x, (long)cp2y, (long)x2, (long)y2, [color canvasColorString], (long)lineWidth];

	[self stringByEvaluatingJavaScriptFromString:jsString];
}

///  显示图像的一部分 context.drawImage(image,sx,sy,sw,sh,dx,dy,dw,dh)
- (void)drawImage:(NSString *)src
	onCanvas:(NSString *)canvasId
	sx:(NSInteger)sx
	sy:(NSInteger)sy
	sw:(NSInteger)sw
	sh:(NSInteger)sh
	dx:(NSInteger)dx
	dy:(NSInteger)dy
	dw:(NSInteger)dw
	dh:(NSInteger)dh {
	NSString *jsString = [NSString stringWithFormat:
		@"var image = new Image();"
		"image.src = '%@';"
		"var canvas = document.getElementById('%@');"
		"var context = canvas.getContext('2d');"
		"context.drawImage(image,%ld,%ld,%ld,%ld,%ld,%ld,%ld,%ld)",
		src, canvasId, (long)sx, (long)sy, (long)sw, (long)sh, (long)dx, (long)dy, (long)dw, (long)dh];

	[self stringByEvaluatingJavaScriptFromString:jsString];
}

@end

@implementation UIColor (Change)

///  获取canvas用的颜色字符串
- (NSString *)canvasColorString {
	CGFloat *arrRGBA = [self getRGB];
	int r = arrRGBA[0] * 255;
	int g = arrRGBA[1] * 255;
	int b = arrRGBA[2] * 255;
	float a = arrRGBA[3];

	return [NSString stringWithFormat:@"rgba(%d,%d,%d,%f)", r, g, b, a];
}

///  获取网页颜色字串
- (NSString *)webColorString {
	CGFloat *arrRGBA = [self getRGB];
	int r = arrRGBA[0] * 255;
	int g = arrRGBA[1] * 255;
	int b = arrRGBA[2] * 255;

	NSLog(@"%d,%d,%d", r, g, b);
	NSString *webColor = [NSString stringWithFormat:@"#%02X%02X%02X", r, g, b];
	return webColor;
}

/// 加亮
- (UIColor *)lighten {
	CGFloat *rgb = [self getRGB];
	CGFloat r = rgb[0];
	CGFloat g = rgb[1];
	CGFloat b = rgb[2];
	CGFloat alpha = rgb[3];

	r = r + (1 - r) / 6.18;
	g = g + (1 - g) / 6.18;
	b = b + (1 - b) / 6.18;

	UIColor *uiColor = [UIColor colorWithRed:r green:g blue:b alpha:alpha];
	return uiColor;
}

- (UIColor *)darken { //变暗
	CGFloat *rgb = [self getRGB];
	CGFloat r = rgb[0];
	CGFloat g = rgb[1];
	CGFloat b = rgb[2];
	CGFloat alpha = rgb[3];

	r = r * 0.618;
	g = g * 0.618;
	b = b * 0.618;

	UIColor *uiColor = [UIColor colorWithRed:r green:g blue:b alpha:alpha];
	return uiColor;
}

- (UIColor *)mix:(UIColor *)color {
	CGFloat *rgb1 = [self getRGB];
	CGFloat r1 = rgb1[0];
	CGFloat g1 = rgb1[1];
	CGFloat b1 = rgb1[2];
	CGFloat alpha1 = rgb1[3];

	CGFloat *rgb2 = [color getRGB];
	CGFloat r2 = rgb2[0];
	CGFloat g2 = rgb2[1];
	CGFloat b2 = rgb2[2];
	CGFloat alpha2 = rgb2[3];

	//mix them!!
	CGFloat r = (r1 + r2) / 2.0;
	CGFloat g = (g1 + g2) / 2.0;
	CGFloat b = (b1 + b2) / 2.0;
	CGFloat alpha = (alpha1 + alpha2) / 2.0;

	UIColor *uiColor = [UIColor colorWithRed:r green:g blue:b alpha:alpha];

	return uiColor;
}

- (CGFloat *)getRGB {
	UIColor *uiColor = self;

	CGColorRef cgColor = [uiColor CGColor];

	int numComponents = (int)CGColorGetNumberOfComponents(cgColor);

	if (numComponents == 4) {
		static CGFloat *components = Nil;
		components = (CGFloat *)CGColorGetComponents(cgColor);
		return (CGFloat *)components;
	}
	else {   //否则默认返回黑色
		static CGFloat components[4] = {0};
		CGFloat f = 0;

		//非RGB空间的系统颜色单独处理
		if ([uiColor isEqual:[UIColor whiteColor]]) {
			f = 1.0;
		}
		else if ([uiColor isEqual:[UIColor lightGrayColor]]) {
			f = 0.8;
		}
		else if ([uiColor isEqual:[UIColor grayColor]]) {
			f = 0.5;
		}
		components[0] = f;
		components[1] = f;
		components[2] = f;
		components[3] = 1.0;
		return (CGFloat *)components;
	}
}

@end
