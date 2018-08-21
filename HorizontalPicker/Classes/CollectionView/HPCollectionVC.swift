//
//  HPCollectionVC.swift
//  HorizontalPickerDemo
//
//  Created by Bernd Rabe on 13.12.15.
//  Copyright © 2015 RABE_IT Services. All rights reserved.
//

import UIKit

protocol HPCollectionVCProvider: class {
    func numberOfRowsInCollectionViewController (controller: HPCollectionVC) -> Int
    func collectionViewController (controller: HPCollectionVC, titleForRow row: Int) -> String
    func collectionViewController (controller: HPCollectionVC, didSelectRow row: Int)
}

class HPCollectionVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    weak var provider: HPCollectionVCProvider?
    
    var maxElementWidth: CGFloat = 0.0
    var font: UIFont = UIFont.preferredFont(forTextStyle: .title1)
    var useTwoLineMode = true
    var textColor = UIColor.lightGray
    var selectedCellIndexPath = IndexPath(item: 0, section: 0)

    // MARK: - Public API
    
    var selectedRow: Int {
        return selectedCellIndexPath.row
    }
    
    func selectRow(at indexPath: IndexPath, animated: Bool) {
        if let collectionView = collectionView {
            selectedCellIndexPath = indexPath
            scrollToIndex(indexPath.item, animated: animated)
            changeSelectionForCell(at: indexPath, collectionView: collectionView, animated: animated)
        }
    }
    
    // MARK: - UICollectionViewDelegate/UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return provider?.numberOfRowsInCollectionViewController(controller: self) ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseId = HPCollectionViewCellConstants.reuseIdentifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! HPCollectionViewCell
        configureCollectionViewCell(cell, at: indexPath)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectRow(at: indexPath, animated: true)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = provider?.collectionViewController(controller: self, titleForRow: indexPath.row) ?? " "
        return sizeForText(text, maxSize: CGSize(width: maxElementWidth, height: collectionView.bounds.height))
    }
    
    // MARK: - UIScrollviewDelegate
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToPosition(scrollView: scrollView)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            scrollToPosition(scrollView: scrollView)
        }
    }
    
    func scrollToPosition(scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView, let item = indexPathForCenterCellFromCollectionview(collectionView: collectionView) {
            scrollToIndex(item.row, animated: true)
            changeSelectionForCell(at: item, collectionView: collectionView, animated: true)
        }
    }
    
    func indexPathForCenterCellFromCollectionview (collectionView: UICollectionView) -> IndexPath? {
        let point = collectionView.convert(collectionView.center, from: collectionView.superview)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return collectionView.indexPathsForVisibleItems.first }
        return indexPath
    }
    
    // MARK: - Helper
    
    func sizeForText(_ text: String, maxSize: CGSize) -> CGSize {
        let attr: [NSAttributedStringKey: Any] = [.font : font]
        var frame = (text as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: attr, context: NSStringDrawingContext())
        frame = frame.integral
        frame.size.width += 16.0 // give it some room at both ends
        frame.size.height = maxSize.height

        return frame.size
    }
    
    private func configureCollectionViewCell(_ cell: HPCollectionViewCell, at indexPath: IndexPath) {
        if let provider = provider {
            cell.text = provider.collectionViewController(controller: self, titleForRow: indexPath.row)
            cell.isSelected = selectedCellIndexPath == indexPath
            cell.delegate = self
        }
    }
    
    private func scrollToIndex(_ index: Int, animated: Bool) {
        let indexPath = IndexPath(item: index, section: 0)
        guard let cv = collectionView, let attributes = cv.layoutAttributesForItem(at: indexPath) else {
            return
        }
        
        let halfWidth = cv.frame.width / CGFloat(2.0)
        let offset = CGPoint(x: attributes.frame.midX - halfWidth, y: 0)
        cv.setContentOffset(offset, animated: animated)
    }
    
    private func changeSelectionForCell(at indexPath: IndexPath, collectionView: UICollectionView, animated: Bool) {
        delay(inSeconds: 0.25) {
            collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: .centeredHorizontally)
        }
    }
    
    private func delay(inSeconds delay:TimeInterval, closure:  @escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            closure()
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
