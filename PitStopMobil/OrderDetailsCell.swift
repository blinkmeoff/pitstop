//
//  OrderDetailsCell.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.12.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import LBTAComponents

class OrderDetailsCell: BaseCell {
  
  var order: Order? {
    didSet {
      guard let order = order else {
        return
      }
      guard let profileImageUrl = order.clientProfileImageUrl else { return }
      userProfileImageView.loadImage(urlString: profileImageUrl)
      
      guard let username = order.clientName else { return }
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "dd.MM.YYYY hh:mm"
      let creationDate = dateFormatter.string(from: order.creationDate)
      
      let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17)])
      attributedText.append(NSMutableAttributedString(string: "\n", attributes: nil))
      attributedText.append(NSAttributedString(string: creationDate, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15), NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
      
      usernameLabel.attributedText = attributedText
      
      textView.text = order.descriptionText
    }
  }
  
  let userProfileImageView: CachedImageView = {
    let iv = CachedImageView()
    iv.contentMode = .scaleAspectFill
    iv.layer.cornerRadius = 25
    iv.clipsToBounds = true
    return iv
  }()
  
  let usernameLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    return label
  }()
  
  let textView: UITextView = {
    let textView = UITextView()
    textView.textColor = .darkGray
    //    label.numberOfLines = 3
    textView.font = UIFont.systemFont(ofSize: 16)
    textView.isScrollEnabled = false
    textView.isEditable = false
    return textView
  }()
  
  override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    super.apply(layoutAttributes)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.02) {
      self.layer.zPosition = 0
    }
  }
  
  override func setupUI() {
    super.setupUI()
    addSubview(userProfileImageView)
    userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
    
    addSubview(usernameLabel)
    usernameLabel.anchor(top: nil, left: userProfileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    usernameLabel.centerYAnchor.constraint(equalTo: userProfileImageView.centerYAnchor).isActive = true
    
    addSubview(textView)
    textView.anchor(top: userProfileImageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
  }
}
