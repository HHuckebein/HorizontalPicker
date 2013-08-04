//
//  HPCollectionViewCell.m
//  HorizontalPicker
//
//  Created by Bernd Rabe on 02.08.13.
//  Copyright (c) 2013 RABE_IT Services. All rights reserved.
//

#import "HPCollectionViewCell.h"

#ifndef DefineContext
#define DefineContext(_X_) static NSString * _X_ = @#_X_
#endif

DefineContext(TextChanged);

#define TEXT_KEYPATH  @"text"

@interface HPGradientView : UIView
@end

@interface HPCollectionViewCell()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) HPGradientView *gradient;
@end

@implementation HPCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _font = [UIFont boldSystemFontOfSize:14];
        self.backgroundColor = [UIColor clearColor];
//        self.layer.borderColor = [UIColor redColor].CGColor;
//        self.layer.borderWidth = 0.5;
        
        [self addSubview:self.gradient];
        [self addSubview:self.label];
        [self collectionViewCellConstraints];
        
        [self addObserver:self forKeyPath:TEXT_KEYPATH options:NSKeyValueObservingOptionNew context:(__bridge void *)(TextChanged)];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:TEXT_KEYPATH context:(__bridge void *)(TextChanged)];
}

- (UILabel *)label
{
    if (nil == _label) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.backgroundColor = [UIColor clearColor];
//        _label.layer.borderColor = [UIColor blueColor].CGColor;
//        _label.layer.borderWidth = 0.5;
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        _label.textAlignment    = NSTextAlignmentCenter;
        _label.textColor        = [UIColor colorWithRed:142/255. green:142/255. blue:142/255. alpha:1.];
    }
    return _label;
}

- (HPGradientView *)gradient
{
    if (nil == _gradient) {
        _gradient = [[HPGradientView alloc] initWithFrame:CGRectMake(0, 0, 1, CGRectGetHeight(self.bounds))];
    }
    return _gradient;
}

- (void)collectionViewCellConstraints
{
    UIView *gradient = self.gradient;
    UILabel *label = self.label;
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(gradient, label);
    NSArray *horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[gradient]-[label]-(8)-|" options:0 metrics:0 views:viewsDict];
    NSArray *vertical   = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[gradient]|" options:0 metrics:nil views:viewsDict];
    
    [self addConstraints:horizontal];
    [self addConstraints:vertical];
}

#pragma mark - KeyValue Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == (__bridge void *)(TextChanged)) {
        self.label.text = self.text;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

@implementation HPGradientView

+ (Class)layerClass
{
	return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
        
        gradientLayer.startPoint = CGPointMake(0.5, 0.0);
        gradientLayer.endPoint = CGPointMake( 0.5, 1.0);
        
        gradientLayer.locations = @[@(.1), @(.5), @(.9)];
        gradientLayer.colors = @[(id)[UIColor colorWithWhite:0.8 alpha:0].CGColor, (id)[UIColor colorWithWhite:0.6 alpha:0.8].CGColor, (id)[UIColor colorWithWhite:0.8 alpha:0].CGColor];;
    }
    return self;
}

@end
