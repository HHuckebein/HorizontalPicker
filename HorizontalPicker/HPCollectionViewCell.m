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
#import "HPickerDefinitions.h"
#import "RCReceptionist.h"

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
        
        [RCReceptionist receptionistForKeyPath:@"text" object:self queue:[NSOperationQueue mainQueue] task:^(NSString *keyPath, id object, NSDictionary *change) {
            self.label.text = self.text;
        }];

        if (DEBUG_HP == 1) {
            self.layer.borderColor = [UIColor redColor].CGColor;
            self.layer.borderWidth = 0.5;
        }
    }
    return self;
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

@end
