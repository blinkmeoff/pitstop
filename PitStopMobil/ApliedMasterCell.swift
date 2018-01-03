//
//  ApliedMasterCell.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.12.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import LBTAComponents

protocol ApliedMasterCellDelegate {
  func confirm(uid: String, cell: ApliedMasterCell)
}

class ApliedMasterCell: BaseCell {
  
  var delegate: MasterProfileHeaderDelegate?
  var apliedMasterCellDelegate: ApliedMasterCellDelegate?
  
  var user: Master? {
    didSet {
      
      guard let imageURL = user?.profileImageUrl else { return }
      userProfileImageView.loadImage(urlString: imageURL)
      
      setUsername()
    }
  }
  
  private func setUsername() {
    guard let username = user?.username else { return }
    guard let address = user?.address else { return }
    let attrString = NSMutableAttributedString(string: "\(username)\n", attributes: [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 15)])
    attrString.append(NSAttributedString(string: address, attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13)]))
    usernameLabel.attributedText = attrString
  }
  
  let userProfileImageView: CachedImageView = {
    let iv = CachedImageView()
    iv.contentMode = .scaleAspectFill
    iv.layer.cornerRadius = 20
    iv.clipsToBounds = true
    return iv
  }()
  
  let usernameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.numberOfLines = 0
    label.font = UIFont.boldSystemFont(ofSize: 15)
    return label
  }()
  
  lazy var callButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "phone").withRenderingMode(.alwaysOriginal), for: .normal)
    button.backgroundColor = UIColor(r: 72, g: 179, b: 46)
    button.layer.cornerRadius = 3
    button.addTarget(self, action: #selector(handleShowPhoneNumber), for: .touchUpInside)
    return button
  }()
  
  lazy var messageButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "message").withRenderingMode(.alwaysOriginal), for: .normal)
    button.backgroundColor = UIColor.rgb(red: 22, green: 129, blue: 250)
    button.layer.cornerRadius = 3
    button.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
    return button
  }()
  
  lazy var confirmButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Подтвердить", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = Settings.Color.orange
    button.layer.cornerRadius = 3
    button.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
    return button
  }()
  
  let separatorLine: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 0, alpha: 0.4)
    return view
  }()
  
  @objc private func handleConfirm() {
    guard let uid = user?.uid else { return }
    apliedMasterCellDelegate?.confirm(uid: uid, cell: self)
  }
  
  @objc private func handleSendMessage() {
    guard let uid = user?.uid else { return }
    guard let imageURL = user?.profileImageUrl else { return }
    delegate?.showChatControllerForUser(uid: uid, profileImageUrl: imageURL)
  }
  
  @objc private func handleShowPhoneNumber() {
    guard let phonenumber = user?.phoneNumber else { return }
    delegate?.didTapShowPhoneNumber(phone: phonenumber)
  }
  
  override func setupUI() {
    super.setupUI()
    
    addSubview(messageButton)
    addSubview(callButton)
    addSubview(confirmButton)
    addSubview(userProfileImageView)
    addSubview(usernameLabel)
    addSubview(separatorLine)
    
    messageButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 60, height: 30)
    callButton.anchor(top: topAnchor, left: nil, bottom: nil, right: messageButton.leftAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 60, height: 30)
    
    confirmButton.anchor(top: callButton.bottomAnchor, left: callButton.leftAnchor, bottom: nil, right: messageButton.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
    
    userProfileImageView.anchorCenterYToSuperview()
    userProfileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
    
    usernameLabel.anchor(top: nil, left: userProfileImageView.rightAnchor, bottom: nil, right: callButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    usernameLabel.centerYAnchor.constraint(equalTo: userProfileImageView.centerYAnchor).isActive = true
    
    separatorLine.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.75)
    
  }
}