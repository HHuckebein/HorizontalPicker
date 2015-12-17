//
//  HPCollectionVC.swift
//  HorizontalPickerDemo
//
//  Created by Bernd Rabe on 13.12.15.
//  Copyright © 2015 RABE_IT Services. All rights reserved.
//

import UIKit

protocol HPCollectionVCProvider {
    func numberOfRowsInCollectionViewController (controller: HPCollectionVC) -> Int
    func collectionViewController (controller: HPCollectionVC, titleForRow row: Int) -> String
    func collectionViewController (controller: HPCollectionVC, didSelectRow row: Int)
}

class HPCollectionVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var provider: HPCollectionVCProvider?
    
    var maxElementWidth: CGFloat = 0.0
    var font: UIFont             = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
    var useTwoLineMode           = true
    var textColor                = UIColor.lightGrayColor()
    var selectedCellIndexPath    = NSIndexPath(forItem: 0, inSection: 0) {
        didSet {
            self.provider?.collectionViewController(self, didSelectRow: selectedCellIndexPath.row)
        }
    }
    
    
    // MARK: - Public API
    
    func selectedRow () -> Int {
        return selectedCellIndexPath.row
    }
    
    func selectRowAtIndex (index: Int, animated: Bool) {
        if let collectionView = collectionView {
            scrollToIndex(index, animated: animated)
            changeSelectionForCellAtIndexPath(NSIndexPath(forItem: index, inSection: 0), collectionView: collectionView)
        }
    }
    
    // MARK: - UICollectionViewDelegate/UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return provider?.numberOfRowsInCollectionViewController(self) ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reuseId = HPCollectionViewCellConstants.reuseIdentifier
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseId, forIndexPath: indexPath) as! HPCollectionViewCell
        configureCollectionViewCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        scrollToIndex(indexPath.row, animated: true)
        selectedCellIndexPath = indexPath
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let text = provider?.collectionViewController(self, titleForRow: indexPath.row) ?? " "
        return sizeForText(text, maxSize: CGSize(width: maxElementWidth, height: CGRectGetHeight(collectionView.bounds)))
    }
    
    // MARK: - UIScrollviewDelegate
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollToPosition(scrollView)
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            scrollToPosition(scrollView)
        }
    }
    
    func scrollToPosition(scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView, let item = indexPathForCenterCellFromCollectionview(collectionView) {
            scrollToIndex(item.row, animated: true)
            changeSelectionForCellAtIndexPath(item, collectionView: collectionView)
        }
    }
    
    func indexPathForCenterCellFromCollectionview (collectionView: UICollectionView) -> NSIndexPath? {
        let point = collectionView.convertPoint(collectionView.center, fromView: collectionView.superview)
        return collectionView.indexPathForItemAtPoint(point)
    }
    
    // MARK: - Helper
    
    func sizeForText (text: String, maxSize: CGSize) -> CGSize {
        var frame = (text as NSString).boundingRectWithSize(maxSize, options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: NSStringDrawingContext())
        frame = CGRectIntegral(frame)
        frame.size.width += 16.0 // give it some room at both ends
        
        return frame.size
    }
    
    private func configureCollectionViewCell (cell: HPCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        if let provider = provider {
            cell.text = provider.collectionViewController(self, titleForRow: indexPath.row)
            cell.selected = selectedCellIndexPath == indexPath
            cell.delegate = self
        }
    }
    
    private func scrollToIndex (index: Int, animated: Bool) {
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        guard let cv = collectionView, let attributes = cv.layoutAttributesForItemAtIndexPath(indexPath) else {
            return
        }
        
        let halfWidth = CGRectGetWidth(cv.frame) / CGFloat(2.0)
        let offset = CGPoint(x: CGRectGetMidX(attributes.frame) - halfWidth, y: 0)
        cv.setContentOffset(offset, animated: animated)
    }
    
    private func changeSelectionForCellAtIndexPath (indexPath: NSIndexPath, collectionView: UICollectionView) {
        HorizontalPickerView.delay(0.1) { [unowned self] () -> () in
            collectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .CenteredHorizontally)
            self.selectedCellIndexPath = indexPath
        }
    }
    
}

extension HPCollectionVC: HPCollectionViewCellDelegate {
    func useTwolineModeForCollectionViewCell(cvCell: HPCollectionViewCell) -> Bool {
        return useTwoLineMode
    }
    
    func fontForCollectionViewCell(cvCell: HPCollectionViewCell) -> UIFont {
        return font
    }
    
    func textColorForCollectionViewCell(cvCell: HPCollectionViewCell) -> UIColor {
        return textColor
    }
}


