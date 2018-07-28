//
//  FirstViewController.swift
//  HorizontalPickerDemo
//
//  Created by Bernd Rabe on 13.12.15.
//  Copyright © 2015 RABE_IT Services. All rights reserved.
//

import UIKit
import HorizontalPicker

class FirstViewController: UIViewController, HorizontalPickerViewDataSource, HorizontalPickerViewDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var horizontalPicker: HorizontalPickerView!
    
    lazy var dataSource: Array<Int> = {
        let dataSource = [0, 1, 234, 3, 4, 5, 6000, 7, 8, 9890085]
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = .red
        horizontalPicker.dataSource = self
        horizontalPicker.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        label.text = "\(horizontalPicker.selectedRow())"
    }
    
    // MARK: - HorizontalPickerViewProvider
    
    func numberOfRowsInHorizontalPickerView(pickerView: HorizontalPickerView) -> Int {
        return dataSource.count
    }
    
    func horizontalPickerView(pickerView: HorizontalPickerView, titleForRow row: Int) -> String {
        return "\(dataSource[row])"
    }

    func horizontalPickerView(pickerView: HorizontalPickerView, didSelectRow row: Int) {
        label.text = "\(row)"
    }
    
    func textColorForHorizontalPickerView(pickerView: HorizontalPickerView) -> UIColor {
        return .lightGray
    }
    
    func textFontForHorizontalPickerView(pickerView: HorizontalPickerView) -> UIFont {
        return UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
    }
}

