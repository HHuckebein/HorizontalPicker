//  The MIT License (MIT)
//  Copyright (c) 2011-2013 <RABE_IT Services>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//
//
//  HPLabel.m
//  HorizontalPicker
//
//  Created by Bernd Rabe on 18.04.13.
//  Copyright (c) 2011-2013 RABE_IT Services. All rights reserved.
//

#import "HPLabel.h"
#import <QuartzCore/QuartzCore.h>

@implementation HPLabel

+ (id)labelWithFrame:(CGRect)frame title:(NSString *)title font:(UIFont *)font tag:(NSInteger)tag
{
    return [[self alloc] initWithFrame:frame title:title font:font tag:tag];
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title font:(UIFont *)font tag:(NSInteger)tag
{
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        self.font            = font;
        self.text            = title;
        self.tag             = tag;
        self.textColor       = [UIColor blackColor];
        self.textAlignment   = NSTextAlignmentCenter;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
    
    CGRect gradientRect = CGRectMake(rect.origin.x, rect.origin.y, 1., rect.size.height);
    
    CGContextAddRect(context, gradientRect);
	CGContextClip(context);
	
    CGFloat locations[] = { .2, .5, .8 };
    CGFloat colorsTop[] =
    {
        20.0 / 255.0,  20.0 / 255.0,  20.0 / 255.0, 0.,
        100.0 / 255.0, 100.0 / 255.0, 100.0 / 255.0, 0.7,
        20.0 / 255.0,  20.0 / 255.0,  20.0 / 255.0, 0.,
    };
    _HP_fillRectWithLinearGradient(context, gradientRect, colorsTop, sizeof(colorsTop)/(sizeof(colorsTop[0])*4), locations);
    
    CGContextRestoreGState(context);
    
    CGSize size = [self.text sizeWithFont:self.font];
    CGPoint point = CGPointMake((rect.size.width - size.width)/2, (rect.size.height - size.height)/2);
    
    [self.textColor set];
    [self.text drawAtPoint:point withFont:self.font];
}

void _HP_fillRectWithLinearGradient(CGContextRef context, CGRect rect, CGFloat colors[], int numberOfColors, CGFloat locations[]);
void _HP_fillRectWithLinearGradient(CGContextRef context, CGRect rect, CGFloat colors[], int numberOfColors, CGFloat locations[]) {
	CGContextSaveGState(context);
	
	if(!CGContextIsPathEmpty(context))
		CGContextClip(context);
	
	CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
	CGPoint start = CGPointMake(0, 0);
	CGPoint end = CGPointMake(0, rect.size.height);
	
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, colors, locations, numberOfColors);
	CGContextDrawLinearGradient(context, gradient, end, start, kCGGradientDrawsAfterEndLocation);
	CGContextRestoreGState(context);
	
	CGColorSpaceRelease(space);
	CGGradientRelease(gradient);
}

@end
