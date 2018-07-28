//  HorizontalPickerView.swift
//  HorizontalPickerDemo
//
//  Created by Bernd Rabe on 13.12.15.
//  Copyright © 2015 RABE_IT Services. All rights reserved.
//

import UIKit

/** Constants
 - pathCornerRadii: The corner radii used for the mask shape.
 - strokeColor: The color use for the shapeLayers' strokeColor
 - maxLabelWidthFactor: Defines the max width of one entry as percentage of the picker views width.
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
    
    @objc optional func textFontForHorizontalPickerView (pickerView: HorizontalPickerView) -> UIFont
    @objc optional func textColorForHorizontalPickerView (pickerView: HorizontalPickerView) -> UIColor
    @objc optional func useTwoLineModeForHorizontalPickerView (pickerView: HorizontalPickerView) -> Bool
    @objc optional func pickerViewShouldMask (pickerView: HorizontalPickerView) -> Bool
}

/** A similar to UIPicker but horizontal picker view.
*/
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
                if let view = collectionController.collectionView {
                    view.frame = self.bounds
                    addSubview(view)
                }
            }
            
            if let view = collectionController.collectionView, let layout = collectionController.collectionViewLayout as? HPCollectionViewFlowlayout {
                layout.activeDistance   = floor(view.bounds.width / 2.0)
                layout.midX             = ceil(view.bounds.midX)
                if let numberOfElements = self.dataSource?.numberOfRowsInHorizontalPickerView(pickerView: self) {
                    layout.lastElementIndex = numberOfElements - 1
                }
                
                collectionController.maxElementWidth = self.bounds.width * HorizontalPickerViewConstants.maxLabelWidthFactor
                
                if let firstElement = delegate?.horizontalPickerView(pickerView: self, titleForRow: 0),
                    let lastElement = delegate?.horizontalPickerView(pickerView: self, titleForRow: layout.lastElementIndex) {
                    layout.sectionInset.left  = layout.midX - collectionController.sizeForText(firstElement, maxSize: view.bounds.size).width / CGFloat(2)
                    layout.sectionInset.right = layout.midX - collectionController.sizeForText(lastElement,  maxSize: view.bounds.size).width / CGFloat(2)
                }
                
                HorizontalPickerView.delay(inSeconds: 0.1, closure: {
                    view.selectItem(at: self.collectionController.selectedCellIndexPath, animated: false, scrollPosition: .centeredHorizontally)
                })
            }
            if delegate?.pickerViewShouldMask?(pickerView: self) ?? false {
                layer.mask = shapeLayer
                shapeLayer.path = shapePathForFrame(frame: bounds).cgPath
            }
        }
    }
    
    // MARK:
    
    public func selectedRow () -> Int {
        return collectionController.selectedCellIndexPath.row
    }
    
    public func selectRow (rowIndex: Int, animated: Bool) {
        collectionController.selectRowAtIndex(index: rowIndex, animated: animated)
    }
    
    public func reloadAll () {
        collectionController.collectionView?.reloadData()
    }
    
    // MARK: - Helper
    
    static func delay(inSeconds delay:TimeInterval, closure:  @escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            closure()
        }
    }
    
    // MARK: - Private Interface
    
    private var isInitialized = false
    
    private lazy var shapeLayer: CAShapeLayer = {
        let shapeLayer           = CAShapeLayer()
        shapeLayer.frame         = self.bounds
        shapeLayer.contentsScale = UIScreen.main.scale
        
        return shapeLayer
    }()
    
    private lazy var collectionController: HPCollectionVC = {
        let layout = HPCollectionViewFlowlayout()
        let collectionController = HPCollectionVC(collectionViewLayout: layout)
        collectionController.provider               = self
        collectionController.maxElementWidth        = self.bounds.width * HorizontalPickerViewConstants.maxLabelWidthFactor
        collectionController.font                   = self.delegate?.textFontForHorizontalPickerView?(pickerView: self) ?? UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        collectionController.textColor              = self.delegate?.textColorForHorizontalPickerView?(pickerView: self) ?? UIColor.lightGray
        collectionController.useTwoLineMode         = self.delegate?.useTwoLineModeForHorizontalPickerView?(pickerView: self) ?? false
        collectionController.collectionView?.register(HPCollectionViewCell.self, forCellWithReuseIdentifier: HPCollectionViewCellConstants.reuseIdentifier)
        collectionController.collectionView?.backgroundColor = UIColor.clear
        collectionController.collectionView?.showsHorizontalScrollIndicator = false
        collectionController.clearsSelectionOnViewWillAppear = false
        
        return collectionController
    }()
    
    private func setUp () {
        autoresizingMask = [.flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
    }
    
    private func shapePathForFrame(frame: CGRect) -> UIBezierPath {
        return UIBezierPath(roundedRect: frame, byRoundingCorners: .allCorners, cornerRadii: HorizontalPickerViewConstants.pathCornerRadii)
    }
}

extension HorizontalPickerView: HPCollectionVCProvider {
    func numberOfRowsInCollectionViewController(controller: HPCollectionVC) -> Int {
        return self.dataSource?.numberOfRowsInHorizontalPickerView(pickerView: self) ?? 0
    }
    
    func collectionViewController(controller: HPCollectionVC, didSelectRow row: Int) {
        self.delegate?.horizontalPickerView(pickerView: self, didSelectRow: row)
    }
    
    func collectionViewController(controller: HPCollectionVC, titleForRow row: Int) -> String {
        return self.delegate?.horizontalPickerView(pickerView: self, titleForRow: row) ?? ""
    }
}
