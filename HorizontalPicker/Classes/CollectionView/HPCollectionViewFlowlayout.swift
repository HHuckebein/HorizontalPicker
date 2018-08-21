//
//  HPCollectionViewFlowlayout.swift
//  HorizontalPickerDemo
//
//  Created by Bernd Rabe on 13.12.15.
//  Copyright © 2015 RABE_IT Services. All rights reserved.
//

import UIKit
import GLKit

class HPCollectionViewFlowlayout: UICollectionViewFlowLayout {
    
    var activeDistance: CGFloat = 0.0
    var midX: CGFloat = 0
    var lastElementIndex = 0
    let maxAngle = CGFloat(GLKMathDegreesToRadians(HorizontalPickerViewConstants.maxRotationAngle))
    
    override func prepare () {
        minimumInteritemSpacing = 0.0
        scrollDirection = .horizontal
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let array = super.layoutAttributesForElements(in: rect) , let cv = collectionView else {
            return nil
        }
        
        let visibleRect = CGRect(origin: cv.contentOffset, size: cv.bounds.size)
        var attributesCopy = [UICollectionViewLayoutAttributes]()
        
        for itemAttributes in array {
            let itemAttributesCopy = itemAttributes.copy() as! UICollectionViewLayoutAttributes
            let distance        = visibleRect.midX - itemAttributesCopy.center.x
            let normalizedDistance = distance / activeDistance
            if abs(distance) < activeDistance {
                itemAttributesCopy.alpha = 1.0 - abs(normalizedDistance)
                let rotationAngle = maxAngle * normalizedDistance
                itemAttributesCopy.transform3D = CATransform3DMakeRotation(rotationAngle, 0, 1, 0)
            } else {
                itemAttributesCopy.transform3D = CATransform3DMakeRotation(maxAngle, 0, 1, 0)
                itemAttributesCopy.alpha = 0.1
            }
            attributesCopy.append(itemAttributesCopy)
        }
        
        return attributesCopy
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

}
