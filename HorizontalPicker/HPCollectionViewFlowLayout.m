//
//  HPCollectionViewFlowLayout.m
//  HorizontalPicker
//
//  Created by Bernd Rabe on 02.08.13.
//  Copyright (c) 2013 RABE_IT Services. All rights reserved.
//

#import "HPCollectionViewFlowLayout.h"
#import "HPickerDefinitions.h"
#import "MathAdditions.h"

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
    CGFloat baseAngle = M_PI/180 * 40;

    NSMutableArray *mArray = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *attributes in array)
    {
        if (CGRectContainsRect(visibleRect, attributes.frame)) {
            CGFloat distance = doubleValueRoundedTo(midX - CGRectGetMidX(attributes.frame), FractionDigits2);
            [mArray addObject:@{@"attributes" : attributes, @"distance" : @(distance)}];
        }
        else {
            attributes.alpha = 0.1;
            attributes.zIndex = 200;
            if (DEBUG_HP == 1) {
                NSLog(@"%d (%@) alpha = %2.2f, zIndex = %d", attributes.indexPath.row, NSStringFromCGRect(attributes.frame), attributes.alpha, attributes.zIndex);
            }
        }
    }

    
    NSArray *sortedArray = [mArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CGFloat value1 = [obj1[@"distance"] floatValue];
        CGFloat value2 = [obj2[@"distance"] floatValue];
        if (value1 == value2) return NSOrderedSame;
        return value1 > value2 ? NSOrderedDescending : NSOrderedAscending;
    }];
    
    NSInteger range = activeDistance / sortedArray.count;
    [sortedArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat distance = [obj[@"distance"] floatValue];
        UICollectionViewLayoutAttributes *attributes = obj[@"attributes"];
        
        NSInteger moduloValue = ABS(distance) / range;
        NSLog(@"%2.2f (%d), %d", distance, range, moduloValue);
        CGFloat newAlpha = (activeDistance - ABS(distance)) / range;
        attributes.alpha = (range - moduloValue)/(CGFloat)range;
        
        CGFloat value = -distance/activeDistance;
        value *= baseAngle;
        attributes.transform3D = CATransform3DMakeRotation(value, 0, 1, 0);
        
        attributes.zIndex = ABS(distance)/activeDistance * 200;
        if (DEBUG_HP == 1) {
            NSLog(@"%d (%@) alpha = %2.2f, zIndex = %d", attributes.indexPath.row, NSStringFromCGRect(attributes.frame), attributes.alpha, attributes.zIndex);
        }
    }];

    NSLog(@"%@", array);
    return array;
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}


@end
