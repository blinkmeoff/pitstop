//
//  YearPickerView.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.01.18.
//  Copyright © 2018 com.pitStopMobil. All rights reserved.
//

import UIKit

class YearPickerView: NSObject {
  
  var updateCarController: UpdateCarController?
  var selectedRow = "1970"
  
  let blackView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 0, alpha: 0.5)
    return view
  }()
  
  let whiteView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    return view
  }()
  
  lazy var doneButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Готово", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
    return button
  }()
  
  @objc func handleDone() {
    updateCarController?.isYearValid = true
    let attrTitle = NSAttributedString(string: selectedRow, attributes: [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)])
    updateCarController?.yearTextField.setAttributedTitle(attrTitle, for: .normal)
    updateCarController?.handleTextInputChange()
    handleDismiss()
  }
  
  lazy var yearPicker: UIPickerView = {
    let picker = UIPickerView()
    picker.delegate = self
    picker.dataSource = self
    return picker
  }()
  
  var pickerData = [String]()
  
  @objc func handleDismiss() {
    if let keyWindow = UIApplication.shared.keyWindow {
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        self.blackView.alpha = 0
        self.whiteView.frame = CGRect(x: 0, y: keyWindow.frame.height, width: keyWindow.frame.width, height: 200)
      }) { (_) in
        self.blackView.removeFromSuperview()
        self.whiteView.removeFromSuperview()
      }
    }
  }
  
  func setupPickerData() {
    for value in 1970...2018 {
      pickerData.append(String(value))
    }
    yearPicker.selectRow(pickerData.count - 5, inComponent: 0, animated: true)
    selectedRow = pickerData[pickerData.count - 5]
  }
  
  func presentPicker() {
    setupPickerData()
    if let keyWindow = UIApplication.shared.keyWindow {
      blackView.alpha = 0
      blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
      blackView.frame = keyWindow.frame
      
      whiteView.frame = CGRect(x: 0, y: keyWindow.frame.height, width: keyWindow.frame.width, height: 200)
      
      
      keyWindow.addSubview(blackView)
      keyWindow.addSubview(whiteView)
      
      whiteView.addSubview(yearPicker)
      whiteView.addSubview(doneButton)
      doneButton.anchor(top: whiteView.topAnchor, left: whiteView.leftAnchor, bottom: nil, right: whiteView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 36)
      yearPicker.anchor(top: doneButton.bottomAnchor, left: whiteView.leftAnchor, bottom: whiteView.bottomAnchor, right: whiteView.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
      
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        self.blackView.alpha = 1
        self.whiteView.frame = CGRect(x: 0, y: keyWindow.frame.height - 200, width: keyWindow.frame.width, height: 200)
      }, completion: nil)
      
    }
  }
  
}


extension YearPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  // The number of rows of data
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerData.count
  }
  
  // The data to return for the row and component (column) that's being passed in
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerData[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    let year = pickerData[row]
    selectedRow = String(year)
  }
  
}
