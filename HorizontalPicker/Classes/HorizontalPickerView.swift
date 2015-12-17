//  HorizontalPickerView.swift
//  HorizontalPickerDemo
//
//  Created by Bernd Rabe on 13.12.15.
//  Copyright © 2015 RABE_IT Services. All rights reserved.
//

import UIKit

/** Constants
 strokeColor: The color use for the shapeLayers' strokeColor
 maxLabelWidthFactor: Defines the max width of one entry as percentage of the picker views width.
 */
struct HorizontalPickerViewConstants {
    static let pathCornerRadii              = CGSize(width: 10, height: 5)
    
    static let maxLabelWidthFactor: CGFloat = 0.5    // defines how man width space a single element can occupy as portion of the total width
    static let maxRotationAngle: Float      = -60.0  // elements are rotated around the y axis depending on the distance from the center
}

public protocol HorizontalPickerViewDataSource {
    func numberOfRowsInHorizontalPickerView (pickerView: HorizontalPickerView) -> Int
}

@objc public protocol HorizontalPickerViewDelegate {
    func horizontalPickerView (pickerView: HorizontalPickerView, titleForRow: Int) -> String
    func horizontalPickerView (pickerView: HorizontalPickerView, didSelectRow: Int)
    
    optional func textFontForHorizontalPickerView (pickerView: HorizontalPickerView) -> UIFont
    optional func textColorForHorizontalPickerView (pickerView: HorizontalPickerView) -> UIColor
    optional func useTwoLineModeForHorizontalPickerView (pickerView: HorizontalPickerView) -> Bool
}


public class HorizontalPickerView: UIView {
    
    // MARK: - Public API
    
    public var dataSource: HorizontalPickerViewDataSource?
    public var delegate: HorizontalPickerViewDelegate?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if dataSource != nil && delegate != nil {
            if isInitialized == false {
                isInitialized = true
                layer.mask = shapeLayer
                if let view = collectionController.collectionView {
                    view.frame = self.bounds
                    addSubview(view)
                }
            }
            
            if let view = collectionController.collectionView, let layout = collectionController.collectionViewLayout as? HPCollectionViewFlowlayout {
                layout.activeDistance   = floor(CGRectGetWidth(view.bounds) / 2.0)
                layout.midX             = ceil(CGRectGetMidX(view.bounds))
                if let numberOfElements = self.dataSource?.numberOfRowsInHorizontalPickerView(self) {
                    layout.lastElementIndex = numberOfElements - 1
                }
                
                collectionController.maxElementWidth = CGRectGetWidth(self.bounds) * HorizontalPickerViewConstants.maxLabelWidthFactor
                
                if let firstElement = delegate?.horizontalPickerView(self, titleForRow: 0), let lastElement = delegate?.horizontalPickerView(self, titleForRow: layout.lastElementIndex) {
                    layout.sectionInset.left  = layout.midX - collectionController.sizeForText(firstElement, maxSize: view.bounds.size).width / CGFloat(2)
                    layout.sectionInset.right = layout.midX - collectionController.sizeForText(lastElement,  maxSize: view.bounds.size).width / CGFloat(2)
                }
                
                HorizontalPickerView.delay(0.1, completion: { () -> () in
                    view.selectItemAtIndexPath(self.collectionController.selectedCellIndexPath, animated: false, scrollPosition: .CenteredHorizontally)
                })
            }
            
            shapeLayer.path = shapePathForFrame(bounds).CGPath
        }
    }
    
    public func selectedRow () -> Int {
        return collectionController.selectedCellIndexPath.row
    }
    
    public func selectRow (rowIndex: Int, animated: Bool) {
        collectionController.selectRowAtIndex(rowIndex, animated: animated)
    }
    
    public func reloadAll () {
        collectionController.collectionView?.reloadData()
    }
    
    // MARK: - Helper
    
    static func delay (duration: NSTimeInterval, completion:()->() ) {
        dispatch_after( dispatch_time( DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), completion)
    }
    
    // MARK: - Private Interface
    
    private var isInitialized = false
    
    private lazy var shapeLayer: CAShapeLayer = {
        let shapeLayer           = CAShapeLayer()
        shapeLayer.frame         = self.bounds
        shapeLayer.contentsScale = UIScreen.mainScreen().scale
        
        return shapeLayer
    }()
    
    private lazy var collectionController: HPCollectionVC = {
        let layout = HPCollectionViewFlowlayout()
        let collectionController = HPCollectionVC(collectionViewLayout: layout)
        collectionController.provider               = self
        collectionController.maxElementWidth        = CGRectGetWidth(self.bounds) * HorizontalPickerViewConstants.maxLabelWidthFactor
        collectionController.font                   = self.delegate?.textFontForHorizontalPickerView?(self) ?? UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        collectionController.textColor              = self.delegate?.textColorForHorizontalPickerView?(self) ?? UIColor.lightGrayColor()
        collectionController.useTwoLineMode         = self.delegate?.useTwoLineModeForHorizontalPickerView?(self) ?? false
        collectionController.collectionView?.registerClass(HPCollectionViewCell.self, forCellWithReuseIdentifier: HPCollectionViewCellConstants.reuseIdentifier)
        collectionController.collectionView?.backgroundColor = UIColor.clearColor()
        collectionController.collectionView?.showsHorizontalScrollIndicator = false
        collectionController.clearsSelectionOnViewWillAppear = false
        
        return collectionController
    }()
    
    private func setUp () {
        autoresizingMask = [.FlexibleWidth, .FlexibleLeftMargin, .FlexibleRightMargin]
    }
    
    private func shapePathForFrame(frame: CGRect) -> UIBezierPath {
        return UIBezierPath(roundedRect: frame, byRoundingCorners: .AllCorners, cornerRadii: HorizontalPickerViewConstants.pathCornerRadii)
    }
}

extension HorizontalPickerView: HPCollectionVCProvider {
    func numberOfRowsInCollectionViewController(controller: HPCollectionVC) -> Int {
        return self.dataSource?.numberOfRowsInHorizontalPickerView(self) ?? 0
    }
    
    func collectionViewController(controller: HPCollectionVC, didSelectRow row: Int) {
        self.delegate?.horizontalPickerView(self, didSelectRow: row)
    }
    
    func collectionViewController(controller: HPCollectionVC, titleForRow row: Int) -> String {
        return self.delegate?.horizontalPickerView(self, titleForRow: row) ?? ""
    }
}
