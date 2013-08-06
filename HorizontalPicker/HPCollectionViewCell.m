//
//  HPCollectionViewCell.m
//  HorizontalPicker
//
//  Created by Bernd Rabe on 02.08.13.
//  Copyright (c) 2013 RABE_IT Services. All rights reserved.
//

#import "HPCollectionViewCell.h"
#import "HPickerDefinitions.h"

DefineContext(TextChanged);
#define TEXT_KEYPATH    @"text"

@interface HPCollectionViewCell()
@property (nonatomic, strong) UILabel *label;
@end

@implementation HPCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.label.textColor = self.selected && [self style] == HPStyleNormal ? [self tintColor] : [self baseColor];
}


- (UILabel *)label
{
    if (nil == _label) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.backgroundColor                              = [UIColor clearColor];
        _label.translatesAutoresizingMaskIntoConstraints    = NO;
        _label.textAlignment                                = NSTextAlignmentCenter;
        _label.lineBreakMode                                = NSLineBreakByWordWrapping;
        _label.adjustsFontSizeToFitWidth                    = YES;
        _label.textColor                                    = [self baseColor];
        _label.font                                         = [self font];

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

- (void)setDelegate:(id<HPCollectionViewCellDelegate>)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        
        if (_delegate) {
            self.label.textColor = [self baseColor];
            self.label.font      = [self font];
        }
    }
}

- (UIColor *)tintColor
{
    return [_delegate tintColorForCell:self];
}

- (UIColor *)baseColor
{
    return [self style] == HPStyle_iOS7 ? BASE_COLOR_iOS7 : [UIColor blackColor];
}

- (UIFont *)font
{
    return [_delegate fontForCell:self];
}

- (HPStyle)style
{
    return [_delegate styleForCell:self];
}

- (id)notificationObject
{
    return [_delegate notificationObjectForCell:self];
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
