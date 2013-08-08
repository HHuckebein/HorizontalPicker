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
//  HPCollectionViewFlowLayout.m
//  HorizontalPicker
//

#import "HPCollectionViewFlowLayout.h"
#import "HPickerDefinitions.h"
#import "HorizontalPickerGlobal.h"

@implementation HPCollectionViewFlowLayout

- (void)prepareLayout
{
    self.itemSize                = CGSizeMake(self.itemSize.width, PICKER_HEIGHT);
    self.minimumInteritemSpacing = 0.0;
    self.minimumLineSpacing      = 0.0;
    self.scrollDirection         = UICollectionViewScrollDirectionHorizontal;
    self.sectionInset            = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    if (_style == HPStyle_iOS7) {
        CGRect visibleRect = CGRectZero;
        visibleRect.origin = self.collectionView.contentOffset;
        visibleRect.size = self.collectionView.bounds.size;
        
        CGFloat activeDistance = floorf(CGRectGetWidth(visibleRect) / 2);
        CGFloat midX = ceilf(CGRectGetMidX(visibleRect));
        CGFloat baseAngle = M_PI/180 * 40;
        
        for (UICollectionViewLayoutAttributes *attributes in array)
        {
            CGFloat distance = midX - CGRectGetMidX(attributes.frame);
            attributes.alpha = (activeDistance - ABS(distance))/activeDistance;
            
            CGFloat value = -distance/activeDistance;
            value *= baseAngle;
            attributes.transform3D = CATransform3DMakeRotation(value, 0, 1, 0);
            
            attributes.zIndex = ABS(distance)/activeDistance * 200;
            
            if (DEBUG_HP == 1) {
                NSLog(@"%d (%@) alpha = %2.2f, zIndex = %d", attributes.indexPath.row, NSStringFromCGRect(attributes.frame), attributes.alpha, attributes.zIndex);
            }
        }
    }
    return array;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}


@end
