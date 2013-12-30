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
#import "HPCollectionVC.h"
#import "HPCollectionViewFlowLayout.h"
#import "HPCollectionViewCell.h"

DefineContext(TintColorChanged);
DefineContext(FontChanged);
DefineContext(CropStringIfNecessaryChanged);

#define FONT_KEYPATH                        @"font"
#define TINT_COLOR_KEYPATH                  @"tintColor"
#define CROP_STRING_IF_NECESSARY_KEYPATH    @"cropStringIfNecessary"

typedef NS_ENUM(NSUInteger, AdjustEdgeInset) {
    AdjustEdgeInsetLeft,
    AdjustEdgeInsetRight
};


@interface HPBlackGradientView : UIView
@end

@interface HPWhiteGradientView : UIView
@end

@interface HPTopFrameView : UIView
@property(strong, nonatomic) CAShapeLayer  *maskLayer;

- (UIBezierPath *)maskPath;
@end

@interface HorizontalPickerView() <HPCollectionVCProvider>

@property (strong, nonatomic) HPTopFrameView *topFrameView;
@property (nonatomic, strong) CAShapeLayer   *shapeLayer;
@property (nonatomic, strong) HPCollectionVC *collectionController;
@property (nonatomic, assign) BOOL           isInitialized;
@end

@implementation HorizontalPickerView

#pragma mark - System Init

- (void)setup
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    _tintColor             = [UIColor blueColor];
    _font                  = [UIFont boldSystemFontOfSize:20.f];
    _cropStringIfNecessary = YES;
}

- (void)prepareForAppearance
{
    _isInitialized = TRUE;
    
    self.backgroundColor = _style == HPStyle_iOS7 ? [UIColor clearColor] : [UIColor blackColor];
    
    CGRect gradientRect = CGRectInset(self.bounds, kTopFrameXOffset, kTopFrameYOffset);
    
    if (_style == HPStyle_iOS7) {
        [self.layer addSublayer:self.shapeLayer];
        [self addSubview:self.collectionController.collectionView];
    }
    else {
        [self addSubview:[[HPWhiteGradientView alloc] initWithFrame:gradientRect]];
        [self addSubview:[[HPBlackGradientView alloc] initWithFrame:gradientRect]];
        [self addSubview:self.collectionController.collectionView];
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
    
    if (_isInitialized == FALSE) {
        _isInitialized = TRUE;
        [self prepareForAppearance];
    }
    
    self.topFrameView.maskLayer.path = [self.topFrameView maskPath].CGPath;
    self.shapeLayer.path             = [self shapePathForFrame:self.bounds].CGPath;
    [self makeBaseAdjustmentsForCollectionView:self.collectionController.collectionView];
}

- (void)dealloc
{
//    [self removeObserver:self forKeyPath:TINT_COLOR_KEYPATH                 context:(__bridge void *)(TintColorChanged)];
//    [self removeObserver:self forKeyPath:FONT_KEYPATH                       context:(__bridge void *)(FontChanged)];
//    [self removeObserver:self forKeyPath:CROP_STRING_IF_NECESSARY_KEYPATH   context:(__bridge void *)(CropStringIfNecessaryChanged)];
}


#pragma mark -  Setter

- (void)setEnabled:(BOOL)enabled
{
    self.userInteractionEnabled = enabled;
}

- (void)setCornerRadius:(CGFloat)radius
{
    self.layer.cornerRadius = radius;
}

#pragma mark - Getter

- (CAShapeLayer *)shapeLayer
{
    if (nil == _shapeLayer) {
        _shapeLayer                 = [CAShapeLayer layer];
        _shapeLayer.frame           = CGRectInset(self.bounds, 0, 0);
        _shapeLayer.contentsScale   = [[UIScreen mainScreen] scale];
        _shapeLayer.path            = [self shapePathForFrame:_shapeLayer.bounds].CGPath;
        _shapeLayer.strokeColor     = [STROKE_COLOR_iOS7 CGColor];
        _shapeLayer.lineWidth       = .5;
        _shapeLayer.fillColor       = nil;
    }
    return _shapeLayer;
}

- (HPCollectionVC *)collectionController
{
    if (nil == _collectionController) {
        HPCollectionViewFlowLayout *layout = [[HPCollectionViewFlowLayout alloc] init];
        layout.style                       = _style;
        
        _collectionController = [[HPCollectionVC alloc] initWithCollectionViewLayout:layout collectionVCProvider:self];
        _collectionController.collectionView.showsHorizontalScrollIndicator = NO;
        _collectionController.maxWidth                                      = floorf(CGRectGetWidth(self.bounds) * kMaxLabelWidthFactor);
        _collectionController.font                                          = self.font;
        _collectionController.tintColor                                     = self.tintColor;
        _collectionController.style                                         = _style;
        _collectionController.cropStringIfNecessary                         = _cropStringIfNecessary;
        
        [_collectionController.collectionView registerClass:[HPCollectionViewCell class] forCellWithReuseIdentifier:kTVReuseID_HPCollectionViewStyle];
        _collectionController.collectionView.backgroundColor = [UIColor clearColor];
        
        CGRect frame = _collectionController.collectionView.bounds;
        frame.size   = self.bounds.size;
        _collectionController.collectionView.frame = frame;
    }
    return _collectionController;
}

- (HPTopFrameView *)topFrameView
{
    if (nil == _topFrameView) {
        _topFrameView = [[HPTopFrameView alloc] initWithFrame:self.bounds];
    }
    return _topFrameView;
}

#pragma mark - Helper

- (UIBezierPath *)shapePathForFrame:(CGRect)frame
{
    return [UIBezierPath bezierPathWithRoundedRect:frame byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(0, 0)];
}

- (void)makeBaseAdjustmentsForCollectionView:(UICollectionView *)collectionView
{
    NSIndexPath *indexPath = nil;
    UICollectionViewLayoutAttributes *attributes = nil;

    // first cell
    indexPath = [NSIndexPath indexPathForItem:[self selectedRow] inSection:0];
    attributes = [collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
    [self adjustEdgeInsetForScrollView:collectionView forFrame:attributes.frame edgeInset:AdjustEdgeInsetLeft];

    [collectionView setContentOffset:CGPointMake(CGRectGetMidX(attributes.frame) - floorf(CGRectGetWidth(collectionView.bounds)/2), 0)];
    [self.collectionController changeSelectionInCollectionView:collectionView indexPath:indexPath];

    // last cell
    indexPath = [NSIndexPath indexPathForItem:[_dataSource numberOfRowsInPickerView:self] - 1 inSection:0];
    attributes = [collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
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
    [_delegate pickerView:self didSelectRow:row];
}

#pragma mark - External affairs

- (UIView *)viewForRow:(NSInteger)row;
{
    UIView *view = nil;
    if (row < [_dataSource numberOfRowsInPickerView:self]) {
        view = [self.collectionController.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:row inSection:0]];
    }
    return view;
}

- (void)reloadAllComponents;
{
    [self.collectionController.collectionView reloadData];
}

- (void)selectRow:(NSInteger)row animated:(BOOL)animated;
{
    if (row < [_dataSource numberOfRowsInPickerView:self]) {
        [self.collectionController scrollToIndex:row animated:animated];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
        [self.collectionController changeSelectionInCollectionView:self.collectionController.collectionView indexPath:indexPath];
        
        [_delegate pickerView:self didSelectRow:row];
    }
}

- (NSInteger)selectedRow;
{
    return [self.collectionController selectedRow];
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
    self = [super initWithFrame:frame];
    if (self) {
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
