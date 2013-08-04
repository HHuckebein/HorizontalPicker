//
//  HPCollectionViewFlowLayout.m
//  HorizontalPicker
//
//  Created by Bernd Rabe on 02.08.13.
//  Copyright (c) 2013 RABE_IT Services. All rights reserved.
//

#import "HPCollectionViewFlowLayout.h"
#import "HPickerDefinitions.h"

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
    CGRect visibleRect = CGRectZero;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    CGFloat activeDistance = floorf(CGRectGetWidth(visibleRect) / 2);
    CGFloat midX = ceilf(CGRectGetMidX(visibleRect));
    CGFloat baseAngle = M_PI/180 * 35;
    for (UICollectionViewLayoutAttributes *attributes in array)
    {
        if (CGRectContainsRect(visibleRect, attributes.frame)) {
            CGFloat distance = midX - attributes.center.x;
            attributes.alpha = (activeDistance - ABS(distance))/activeDistance;
            
            CGFloat value = -distance/activeDistance;
            value *= baseAngle;
            NSLog(@"%d alpha = %2.2f, transform rotate y = %2.2f", attributes.indexPath.row, attributes.alpha, value);
            attributes.transform3D = CATransform3DMakeRotation(value, 0, 1, 0);
        }
        else {
            attributes.alpha = 0;
        }
    }
    return array;
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}


@end
