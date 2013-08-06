//
//  HPCollectionViewFlowLayout.m
//  HorizontalPicker
//
//  Created by Bernd Rabe on 02.08.13.
//  Copyright (c) 2013 RABE_IT Services. All rights reserved.
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
            if (CGRectContainsRect(visibleRect, attributes.frame)) {
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
            else {
                attributes.alpha = 0.1;
                attributes.zIndex = 200;
                if (DEBUG_HP == 1) {
                    NSLog(@"%d (%@) alpha = %2.2f, zIndex = %d", attributes.indexPath.row, NSStringFromCGRect(attributes.frame), attributes.alpha, attributes.zIndex);
                }
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
