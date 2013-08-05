//
//  HPCollectionViewCell.m
//  HorizontalPicker
//
//  Created by Bernd Rabe on 02.08.13.
//  Copyright (c) 2013 RABE_IT Services. All rights reserved.
//

#import "HPCollectionViewCell.h"
#import "HPickerDefinitions.h"

#ifndef DefineContext
#define DefineContext(_X_) static NSString * _X_ = @#_X_
#endif

DefineContext(TextChanged);

#define TEXT_KEYPATH  @"text"

@interface HPCollectionViewCell()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIFont *font;
@end

@implementation HPCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _font = [UIFont boldSystemFontOfSize:14];
        self.backgroundColor = [UIColor clearColor];
        
        CATransform3D perspective = CATransform3DIdentity;
        perspective.m34 = -1./750;
        self.layer.sublayerTransform = perspective;
        
        [self addSubview:self.label];
        [self collectionViewCellConstraints];
        
        [self addObserver:self forKeyPath:TEXT_KEYPATH options:NSKeyValueObservingOptionNew context:(__bridge void *)(TextChanged)];
        
        if (DEBUG_HP == 1) {
            self.layer.borderColor = [UIColor redColor].CGColor;
            self.layer.borderWidth = 0.5;
        }
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
        
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        _label.textAlignment    = NSTextAlignmentCenter;
        _label.lineBreakMode    = NSLineBreakByWordWrapping;
        _label.adjustsFontSizeToFitWidth = YES;
        _label.textColor        = [UIColor colorWithRed:142/255. green:142/255. blue:142/255. alpha:1.];

        if (DEBUG_HP == 1) {
            _label.layer.borderColor = [UIColor blueColor].CGColor;
            _label.layer.borderWidth = 0.5;
        }
    }
    return _label;
}

- (void)collectionViewCellConstraints
{
    UILabel *label = self.label;
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(label);
    NSArray *horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(8)-[label]-(8)-|" options:0 metrics:0 views:viewsDict];
    
    [self addConstraints:horizontal];
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
