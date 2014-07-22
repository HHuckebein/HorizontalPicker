//  The MIT License (MIT)
//  Copyright (c) 2013 <RABE_IT Services>
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
//
//  HPCollectionViewCell.m
//  HorizontalPicker
//

#import "HPCollectionViewCell.h"

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
        
        [self addObserver:self forKeyPath:TEXT_KEYPATH options:NSKeyValueObservingOptionNew context:TextChanged];
        
        if (DEBUG_HP == 1) {
            self.layer.borderColor = [UIColor redColor].CGColor;
            self.layer.borderWidth = 0.5;
        }
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:TEXT_KEYPATH context:TextChanged];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.label.textColor = self.selected && [self style] == HPStyleNormal ? [self tintColor] : [self baseColor];
}


- (UILabel *)label
{
    if (nil == _label) {
        _label                                              = [[UILabel alloc] initWithFrame:self.bounds];
        _label.backgroundColor                              = [UIColor clearColor];
        _label.translatesAutoresizingMaskIntoConstraints    = NO;
        _label.textAlignment                                = NSTextAlignmentCenter;
        
        if ([self cropStringIfNecessary] == NO) {
            _label.lineBreakMode                             = NSLineBreakByWordWrapping;
            _label.numberOfLines                             = 2;
        }
        
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
    UILabel *label          = self.label;
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(label);
    NSArray *horizontal     = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(8)-[label]-(8)-|" options:0 metrics:0 views:viewsDict];
    NSArray *vertical       = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[label]-(8)-|" options:0 metrics:0 views:viewsDict];
    
    [self addConstraints:horizontal];
    [self addConstraints:vertical];
}

- (void)setDelegate:(id<HPCollectionViewCellDelegate>)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        
        if (_delegate) {
            self.label.textColor     = [self baseColor];
            self.label.font          = [self font];
            if ([self cropStringIfNecessary] == NO) {
                self.label.lineBreakMode = NSLineBreakByWordWrapping;
                self.label.numberOfLines = 2;
            }
            else {
                self.label.numberOfLines = 1;
                self.label.lineBreakMode = NSLineBreakByTruncatingTail;
            }
        }
    }
}

- (BOOL)cropStringIfNecessary {
    return [_delegate cropStringIfNecessaryForCell:self];
}

- (UIColor *)tintColor {
    return [_delegate tintColorForCell:self];
}

- (UIFont *)font {
    return [_delegate fontForCell:self];
}

- (HPStyle)style {
    return [_delegate styleForCell:self];
}

- (UIColor *)baseColor {
    return [self style] == HPStyle_iOS7 ? BASE_COLOR_iOS7 : [UIColor blackColor];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == TextChanged) {
        self.label.text = self.text;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
