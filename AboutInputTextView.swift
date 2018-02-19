//
//  AboutInputTextView.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.01.18.
//  Copyright © 2018 com.pitStopMobil. All rights reserved.
//

import UIKit

class AboutInputTextView: UITextView {
  
  open var placeholder: String? {
    didSet {
      placeholderLabel.text = placeholder
    }
  }
  
  let placeholderLabel: UILabel = {
    let label = UILabel()
    label.text = "Расскажите о себе"
    label.textColor = UIColor(white: 0, alpha: 0.2)
    label.font = UIFont.systemFont(ofSize: 13)
    return label
  }()
  
  func showPlaceholderLabel() {
    placeholderLabel.isHidden = false
  }
  
  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    
    NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: .UITextViewTextDidChange, object: nil)
    
    addSubview(placeholderLabel)
    placeholderLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
  }
  
  @objc func handleTextChange() {
    placeholderLabel.isHidden = !self.text.isEmpty
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
