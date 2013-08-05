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
//  HPickerView.m
//  HorizontalPicker
//
//  Created by Bernd Rabe on 02.05.11.
//  Copyright 2011-2013 RABE_IT Services. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HorizontalPickerView.h"
#import "HPickerDefinitions.h"
#import "HPLabel.h"
#import "HPCollectionVC.h"
#import "HPCollectionViewFlowLayout.h"
#import "HPCollectionViewCell.h"

#ifndef DefineContext
#define DefineContext(_X_) static NSString * _X_ = @#_X_
#endif

DefineContext(TintColorChanged);

#define kTintColorKeyPath  @"tintColor"

typedef NS_ENUM(NSUInteger, AdjustEdgeInset) {
    AdjustEdgeInsetLeft,
    AdjustEdgeInsetRight
};


@interface HPBlackGradientView : UIView
@end

@interface HPWhiteGradientView : UIView
@end

@interface HPTopFrameView : UIView
@property(strong, nonatomic) CAShapeLayer                   *maskLayer;

- (UIBezierPath *)maskPath;
@end

@interface HorizontalPickerView() <UIScrollViewDelegate, HPCollectionViewProvider>

@property (strong, nonatomic) UIScrollView   *hpScrollView;
@property (strong, nonatomic) NSMutableArray *tables;
@property (strong, nonatomic) HPLabel        *centerLabel;
@property (strong, nonatomic) HPTopFrameView *topFrameView;
@property (assign, nonatomic) BOOL           configured;
@property (assign, nonatomic) BOOL           is_iOS7;
@property (nonatomic, strong) CAShapeLayer   *shapeLayer;
@property (nonatomic, strong) HPCollectionVC *collectionController;

@end

@implementation HorizontalPickerView

#pragma mark - system init

- (void)setup
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    _tintColor = [UIColor blueColor];
    
    [self addObserver:self forKeyPath:kTintColorKeyPath options:NSKeyValueObservingOptionNew context:(__bridge void *)(TintColorChanged)];
}

- (void)prepareForAppearance
{
    // make the whiteGradient's height a bit smallerso that the background shines through
    CGRect gradientRect = CGRectInset(self.bounds, kTopFrameXOffset, kTopFrameYOffset + kScrollViewPadding);
    
    if (_style == HPStyle_iOS7) {
        [self.layer addSublayer:self.shapeLayer];
        [self addSubview:self.collectionController.collectionView];
        [self performSelector:@selector(adjustContentInsetsForCollectionView:) withObject:self.collectionController.collectionView afterDelay:0.2];
        [self performSelector:@selector(scrollToBase) withObject:nil afterDelay:0.1];
    }
    else {
        [self addSubview:[[HPWhiteGradientView alloc] initWithFrame:gradientRect]];
        [self addSubview:[[HPBlackGradientView alloc] initWithFrame:gradientRect]];
        
        [self addSubview:self.topFrameView];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setup];
        [self prepareForAppearance];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_configured == FALSE) {
        _configured = TRUE;
        
        [self prepareForAppearance];
        //        [self configureHorizontalPickerWith:[_dataSource numberOfRowsInPickerView:self]];
    }
    
    //    self.topFrameView.maskLayer.path = [self.topFrameView maskPath].CGPath;
    //
    //    HPLabel *label = _centerLabel ? self.centerLabel : [self findCenterLabel:self.hpScrollView];
    //    [self centerLabel:label animated:YES];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:kTintColorKeyPath context:(__bridge void *)(TintColorChanged)];
}

- (void)setStyle:(HPStyle)style
{
    if (_style != style) {
        _style = style;
        
        if (_style == HPStyle_iOS7) {
            self.tintColor = [UIColor colorWithRed:142/255. green:142/255. blue:147/255. alpha:1.];
        }
        self.backgroundColor = style == HPStyle_iOS7 ? [UIColor clearColor] : [UIColor blackColor];
    }
}

- (CAShapeLayer *)shapeLayer
{
    if (nil == _shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.frame = CGRectInset(self.bounds, 0, 0);
        _shapeLayer.contentsScale = [[UIScreen mainScreen] scale];
        _shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:_shapeLayer.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(0, 0)].CGPath;
        _shapeLayer.strokeColor = [UIColor colorWithRed:142/255. green:142/255. blue:147/255. alpha:1.].CGColor;
        _shapeLayer.lineWidth = .5;
        _shapeLayer.fillColor = nil;
    }
    return _shapeLayer;
}

- (HPCollectionVC *)collectionController
{
    if (nil == _collectionController) {
        HPCollectionViewFlowLayout *layout = [[HPCollectionViewFlowLayout alloc] init];
        _collectionController = [[HPCollectionVC alloc] initWithCollectionViewLayout:layout];
        _collectionController.collectionViewProvider = self;
        _collectionController.font = [UIFont boldSystemFontOfSize:14];
        _collectionController.maxWidth = floorf(CGRectGetWidth(self.bounds) * kMaxLabelWidthFactor);
        _collectionController.collectionView.showsHorizontalScrollIndicator = NO;
        
        [_collectionController.collectionView registerClass:[HPCollectionViewCell class] forCellWithReuseIdentifier:kTVReuseID_HPCollectionViewStyle];
        _collectionController.collectionView.backgroundColor = [UIColor clearColor];
        
        CGRect frame = _collectionController.collectionView.frame;
        frame.size.height = CGRectGetHeight(self.bounds);
        _collectionController.collectionView.frame = frame;
    }
    return _collectionController;
}

- (void)adjustContentInsetsForCollectionView:(UICollectionView *)collectionView
{
    NSIndexPath *indexPath = nil;
    UICollectionViewLayoutAttributes *attributes = nil;

    // first cell
    indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    attributes = [self.collectionController.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
    [self adjustEdgeInsetForScrollView:collectionView forFrame:attributes.frame edgeInset:AdjustEdgeInsetLeft];
    
    // last cell
    indexPath = [NSIndexPath indexPathForItem:[_dataSource numberOfRowsInPickerView:self] - 1 inSection:0];
    attributes = [self.collectionController.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
    [self adjustEdgeInsetForScrollView:collectionView forFrame:attributes.frame edgeInset:AdjustEdgeInsetRight];
}

- (void)adjustEdgeInsetForScrollView:(UIScrollView *)scrollView forFrame:(CGRect)frame edgeInset:(AdjustEdgeInset)edgeInset
{
    CGFloat centerX = scrollView.center.x;
    UIEdgeInsets insets = scrollView.contentInset;
    
    switch (edgeInset) {
        case AdjustEdgeInsetLeft:
            insets.left = lroundf(centerX - CGRectGetWidth(frame)/2);
            break;
            
        case AdjustEdgeInsetRight:
            insets.right = lroundf(centerX - CGRectGetWidth(frame)/2);
            break;
            
        default:
            break;
    }
    scrollView.contentInset = insets;
}


- (void)scrollToBase
{
    [self selectRow:0 animated:NO];
}

#pragma mark -  Setter

- (void)setEnabled:(BOOL)enabled
{
    self.userInteractionEnabled = enabled;
}

#pragma mark - HPCollectionViewProvider

- (NSInteger)numberOfRowsInCollectionViewController:(HPCollectionVC *)collectionVC
{
    return [_dataSource numberOfRowsInPickerView:self];
}

- (NSString *)collectionViewController:(HPCollectionVC *)collectionVC titleForRow:(NSInteger)row
{
    return [_delegate pickerView:self titleForRow:row];
}

- (void)collectionViewController:(HPCollectionVC *)collectionVC didSelectRow:(NSInteger)row
{
    NSLog(@"%d", row);
}

#pragma mark - External affairs

- (NSInteger)numberOfRows;
{
    if (self.tables.count == 1 && [(self.tables)[0] isEqualToString:@"???"]) {
        return 0;
    }
    return self.tables.count;
}

- (UIView *)viewForRow:(NSInteger)row;
{
    return [self.hpScrollView viewWithTag:row + 1];
}

- (void)reloadAllComponents;
{
    for (UIView *view in self.hpScrollView.subviews) {
        [view removeFromSuperview];
    }
    [self configureHorizontalPickerWith:[_dataSource numberOfRowsInPickerView:self]];
}

- (void)selectRow:(NSInteger)row animated:(BOOL)animated;
{
    if (_style == HPStyle_iOS7) {
        [self.collectionController scrollToIndex:row animated:animated];
    }
    else {
        [self centerLabel:(HPLabel *)[self.hpScrollView viewWithTag:row + 1] animated:animated];
    }
}

- (NSInteger)selectedRow;
{
    return [[self findCenterLabel:self.hpScrollView] tag] - 1;
}

#pragma mark - Crop Label Text

- (NSString *)cropStringFromString:(NSString *)text width:(CGFloat)maxWidth font:(UIFont *)font
{
    NSMutableString *newText = [NSMutableString string];
    [newText setString:text];
    NSRange range = NSMakeRange(newText.length, 1);
    
    BOOL needsCut = NO;
    
    CGSize size = [newText sizeWithFont:font];
    
    while (size.width > maxWidth) {
        range.location -= 1;
        [newText deleteCharactersInRange:range];
        needsCut = YES;
        size = [newText sizeWithFont:font];
    };
    
    if (needsCut == YES) {
        range.location -= 3;
        range.length    = 3;
        [newText replaceCharactersInRange:range withString:@"..."];
    }
    return [newText copy];
}

#pragma mark - Init Picker

- (void)configureHorizontalPickerWith:(NSInteger)numberOfRows
{
    UIFont *font = [UIFont boldSystemFontOfSize:20];
    NSString *title = @"???";
    
    if (numberOfRows) {
        CGFloat maxWidth = floorf(self.bounds.size.width * kMaxLabelWidthFactor);
        CGRect frame = CGRectMake(0, 0, 0, self.frame.size.height - 2*(kTopFrameYOffset + kScrollViewPadding));
        
        for (int i = 0; i < numberOfRows; i++) {
            
            title = [_delegate pickerView:self titleForRow:i];
            [self.tables addObject:title ? title : @"??"];
            
            CGFloat width = [title sizeWithFont:font].width;
            frame.size.width = MIN(maxWidth, width) + kLabelPadding;
            
            if (width > maxWidth) {
                title = [self cropStringFromString:title width:maxWidth font:font];
            }
            
            [self.hpScrollView addSubview:[HPLabel labelWithFrame:frame title:title font:font tag:i + 1]];
        }
    }
    else {
        CGFloat width = [title sizeWithFont:font].width + kLabelPadding;
        CGRect frame = CGRectMake(0, 0, width, self.frame.size.height - 2*(kTopFrameYOffset + kScrollViewPadding));
        
        [self.hpScrollView addSubview:[HPLabel labelWithFrame:frame title:title font:font tag:1]];
    }
    
    [self layoutLabels];
}

- (void)centerLabel:(HPLabel *)label animated:(BOOL)animated
{
    self.centerLabel.textColor = [UIColor blackColor];
    
    self.centerLabel = label;
    self.centerLabel.textColor = self.tintColor;
    
    CGPoint newOffset = CGPointMake(self.centerLabel.center.x - self.hpScrollView.center.x, 0.);
    [self.hpScrollView setContentOffset:newOffset animated:animated];
}

- (void)findHitLabel:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.hpScrollView];
    
    UILabel *hitLabel = nil;
    for (UILabel *label in [self.hpScrollView subviews]) {
        CGPoint point = [label convertPoint:location fromView:self.hpScrollView];
        if ([label pointInside:point withEvent:nil]) {
            hitLabel = label;
            break;
        }
    }
    
    if ([hitLabel isKindOfClass:[HPLabel class]] && hitLabel != self.centerLabel) {
        [self centerLabel:(HPLabel *)hitLabel animated:YES];
        
        [_delegate pickerView:self didSelectRow:hitLabel.tag - 1];
    }
}

- (void)layoutLabels
{
	// reposition all label subviews in a horizontal serial fashion
	CGFloat curXLoc = 0;
	for (UILabel *label in [self.hpScrollView subviews])
	{
        CGRect frame = label.frame;
        frame.origin = CGPointMake(curXLoc, 0);
        label.frame = frame;
        
        curXLoc += frame.size.width;
	}
	
	// set the content size so it can be scrollable
	[self.hpScrollView setContentSize:CGSizeMake(curXLoc, self.hpScrollView.bounds.size.height)];
    
    CGFloat rightInset = self.hpScrollView.center.x - [self.hpScrollView viewWithTag:self.tables.count].bounds.size.width/2;
    CGFloat leftInset  = self.hpScrollView.center.x - [self.hpScrollView viewWithTag:1].bounds.size.width/2;
    self.hpScrollView.contentInset = UIEdgeInsetsMake(0, leftInset, 0, rightInset);
    
    HPLabel *label = (HPLabel *)[self.hpScrollView viewWithTag:1];
    [self centerLabel:label animated:NO];
}

- (HPLabel *)findCenterLabel:(UIScrollView *)scrollView
{
    HPLabel *hitLabel = nil;
    CGPoint offset = scrollView.contentOffset;
    CGPoint labelPoint = CGPointMake(scrollView.center.x + offset.x, offset.y);
    
    for (HPLabel *label in [scrollView subviews]) {
        CGPoint point = [label convertPoint:labelPoint fromView:scrollView];
        if ([label pointInside:point withEvent:nil]) {
            hitLabel = label;
            break;
        }
    }
    return [hitLabel isKindOfClass:[HPLabel class]] ? hitLabel : nil;
}

- (NSMutableArray *)tables
{
    if (nil == _tables) {
        _tables = [NSMutableArray array];
    }
    return _tables;
}

- (HPTopFrameView *)topFrameView
{
    if (nil == _topFrameView) {
        _topFrameView = [[HPTopFrameView alloc] initWithFrame:self.bounds];
    }
    return _topFrameView;
}

#pragma mark - Label

- (UILabel *)labelWithFrame:(CGRect)frame title:(NSString *)title font:(UIFont *)font tag:(NSInteger)tag
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    if (DEBUG_HP == 1) {
        label.layer.borderColor = [UIColor greenColor].CGColor;
        label.layer.borderWidth = 1.;
    }
    
    label.backgroundColor = [UIColor clearColor];
    label.font            = font;
    label.text            = title;
    label.tag             = tag;
    label.textColor       = [UIColor blackColor];
    label.textAlignment   = NSTextAlignmentCenter;
    
    return label;
}

#pragma mark - UIScrollView Creation

- (UIScrollView *)hpScrollView
{
    if (nil == _hpScrollView) {
        _hpScrollView = [[UIScrollView alloc] initWithFrame:CGRectInset(self.bounds, 0, kTopFrameYOffset + kScrollViewPadding)];
        if (DEBUG_HP == 1) {
            _hpScrollView.layer.borderWidth = 1.;
            _hpScrollView.layer.borderColor = [UIColor redColor].CGColor;
        }
        _hpScrollView.backgroundColor = [UIColor clearColor];
        _hpScrollView.showsVerticalScrollIndicator   = NO;
        _hpScrollView.showsHorizontalScrollIndicator = NO;
        _hpScrollView.delegate = self;
        _hpScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(findHitLabel:)];
        [_hpScrollView addGestureRecognizer:tapRecognizer];
    }
    return _hpScrollView;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    HPLabel *label = [self findCenterLabel:scrollView];
    if (label) {
        [self centerLabel:label animated:YES];
        if ([_delegate respondsToSelector:@selector(pickerView:didSelectRow:)]) {
            [_delegate pickerView:self didSelectRow:label.tag - 1];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        HPLabel *label = [self findCenterLabel:scrollView];
        if (label) {
            [self centerLabel:label animated:YES];
            if ([_delegate respondsToSelector:@selector(pickerView:didSelectRow:)]) {
                [_delegate pickerView:self didSelectRow:label.tag - 1];
            }
        }
    }
}

#pragma mark - KeyValue Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)(TintColorChanged)) {
        [[self findCenterLabel:_hpScrollView] setTextColor:self.tintColor];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

#pragma mark - HPBlackGradientView

@implementation HPBlackGradientView

+ (Class)layerClass
{
	return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    if (([super initWithFrame:frame])) {
        self.userInteractionEnabled = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
		CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
		gradientLayer.startPoint = CGPointMake(0.0, 0.5);
		gradientLayer.endPoint = CGPointMake( 1.0, 0.5);
        
        gradientLayer.locations = @[@0.f, @0.25f, @0.5f, @0.75f, @1.f];
        
        gradientLayer.colors =
		@[(id)[UIColor colorWithRed: 50/255. green: 50/255. blue: 50/255. alpha:1.0].CGColor,
    (id)[UIColor colorWithRed: 20/255. green: 20/255. blue: 20/255. alpha:0.1].CGColor,
    (id)[UIColor colorWithRed: 10/255. green: 10/255. blue: 10/255. alpha:0.0].CGColor,
    (id)[UIColor colorWithRed: 20/255. green: 20/255. blue: 20/255. alpha:0.1].CGColor,
    (id)[UIColor colorWithRed: 50/255. green: 50/255. blue: 50/255. alpha:1.0].CGColor];
        
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end

#pragma mark - HPWhiteGradientView

@implementation HPWhiteGradientView

+ (Class)layerClass
{
	return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];
        
        CGFloat outerBorderWidth = 0.02;
        CGFloat innerBorderWidth = 0.035;
        
		CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
        gradientLayer.locations = @[@0.0f, @(outerBorderWidth), @(outerBorderWidth), @(outerBorderWidth + innerBorderWidth), @(outerBorderWidth + innerBorderWidth),
                                    @(1 - innerBorderWidth - outerBorderWidth), @(1 - innerBorderWidth - outerBorderWidth), @(1 - outerBorderWidth), @(1 - outerBorderWidth), @1.0f];
        
        gradientLayer.colors =
		@[(id)[UIColor colorWithRed:143/255. green:143/255. blue:155/255. alpha:1.0].CGColor,
    (id)[UIColor colorWithRed:143/255. green:143/255. blue:155/255. alpha:1.0].CGColor,
    (id)[UIColor colorWithRed:136/255. green:136/255. blue:162/255. alpha:1.0].CGColor,
    (id)[UIColor colorWithRed:136/255. green:136/255. blue:162/255. alpha:1.0].CGColor,
    (id)[UIColor colorWithRed:252/255. green:252/255. blue:252/255. alpha:1.0].CGColor,
    (id)[UIColor colorWithRed:252/255. green:252/255. blue:252/255. alpha:1.0].CGColor,
    (id)[UIColor colorWithRed:136/255. green:136/255. blue:162/255. alpha:1.0].CGColor,
    (id)[UIColor colorWithRed:136/255. green:136/255. blue:162/255. alpha:1.0].CGColor,
    (id)[UIColor colorWithRed:143/255. green:143/255. blue:155/255. alpha:1.0].CGColor,
    (id)[UIColor colorWithRed:143/255. green:143/255. blue:155/255. alpha:1.0].CGColor];
        
 		gradientLayer.startPoint = CGPointMake(0.5, 0.0);
		gradientLayer.endPoint = CGPointMake( 0.5, 1.0);
        
    }
    return self;
}

@end

#pragma mark - HPTopFrameView

@implementation HPTopFrameView

+ (Class)layerClass
{
	return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = NO;
        self.autoresizingMask       = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor        = [UIColor clearColor];
        
		CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
        gradientLayer.locations = @[@0.0f, @0.015f, @0.025f, @0.5f, @0.5f, @1.0f];
        
        gradientLayer.colors =
		@[(id)[UIColor colorWithRed: 48/255. green: 57/255. blue: 69/255. alpha:1.0].CGColor,
    (id)[UIColor colorWithRed:217/255. green:217/255. blue:220/255. alpha:1.0].CGColor,
    (id)[UIColor colorWithRed:162/255. green:163/255. blue:170/255. alpha:1.0].CGColor,
    (id)[UIColor colorWithRed: 72/255. green: 75/255. blue: 86/255. alpha:1.0].CGColor,
    (id)[UIColor colorWithRed: 40/255. green: 40/255. blue: 54/255. alpha:1.0].CGColor,
    (id)[UIColor colorWithRed: 40/255. green: 43/255. blue: 58/255. alpha:1.0].CGColor];
        
 		gradientLayer.startPoint = CGPointMake(0.5, 0.0);
		gradientLayer.endPoint = CGPointMake( 0.5, 1.0);
        
        gradientLayer.mask = [self maskLayer];
        
    }
    return self;
}

- (CAShapeLayer *)maskLayer
{
    if (nil == _maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.frame = self.bounds;
        _maskLayer.contentsScale = [[UIScreen mainScreen] scale];
        
        _maskLayer.backgroundColor = [UIColor clearColor].CGColor;
        _maskLayer.fillColor       = [UIColor whiteColor].CGColor;
        _maskLayer.fillRule        = kCAFillRuleEvenOdd;
        
        _maskLayer.path = [self maskPath].CGPath;
    }
    
    return _maskLayer;
}

- (UIBezierPath *)maskPath
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    [maskPath appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, kTopFrameXOffset, kTopFrameYOffset) cornerRadius:kCornerRadius]];
    
    return maskPath;
}

@end
