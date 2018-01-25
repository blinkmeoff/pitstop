//
//  MessagesCell.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

class MessagesCell: UITableViewCell {
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupViews()
  }
  
  
  
  var message: Message? {
    didSet{
      messageTextLabel.text = message?.text
      
      //time display
      guard let timestamp = message?.timestamp else { return }
      let messageDate = Date(timeIntervalSince1970: Double(timestamp))
      timeLabel.text = messageDate.timeAgoDisplay()
      
      //name and profile image
      setupUserNameAndProfileImage()
    }
  }
  
  fileprivate func setupUserNameAndProfileImage() {
    let chatPartnerId: String?
    
    if message?.fromId == Auth.auth().currentUser?.uid {
      chatPartnerId = message?.toId
    } else {
      chatPartnerId = message?.fromId
    }
    
    guard let id = chatPartnerId else { return }
    let ref = Database.database().reference().child("users").child(id)
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
      
      if let dictionary = snapshot.value as? [String: Any] {
        self.receiverNameLabel.text = dictionary["username"] as? String
        
        if let url = dictionary["profileImageUrl"] as? String {
            self.profileImageView.loadImage(urlString: url)
        }
      }

    }, withCancel: nil)
    
  }
  

  
  let profileImageView: CachedImageView = {
    let iv = CachedImageView()
    iv.contentMode = .scaleAspectFill
    iv.layer.borderWidth = 0.7
    iv.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor
    iv.clipsToBounds = true
    return iv
  }()
  
  let receiverNameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = UIFont.boldSystemFont(ofSize: 16)
    return label
  }()
  
  let messageTextLabel: UILabel = {
    let label = UILabel()
    label.textColor = .lightGray
    label.font = UIFont.systemFont(ofSize: 13)
    return label
  }()
  
  let separatorLine: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
    return view
  }()
  
  let timeLabel: UILabel = {
    let label = UILabel()
    label.textColor = .lightGray
    label.font = UIFont.systemFont(ofSize: 11)
    return label
  }()
  
  fileprivate func setupViews() {
    addSubview(profileImageView)
    addSubview(timeLabel)
    profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 12, paddingBottom: 8, paddingRight: 0, width: 60, height: 60)
    profileImageView.anchorCenterYToSuperview()
    profileImageView.layer.cornerRadius = 30
    
    setupLabels()
    
    timeLabel.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
    timeLabel.centerYAnchor.constraint(equalTo: receiverNameLabel.centerYAnchor).isActive = true
    timeLabel.sizeToFit()
    
    addSubview(separatorLine)
    separatorLine.anchor(top: nil, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
  }
  
  fileprivate func setupLabels() {
    let stackView = UIStackView(arrangedSubviews: [receiverNameLabel, messageTextLabel])
    stackView.axis = .vertical
    stackView.distribution = .fillEqually
    stackView.spacing = -10
    
    addSubview(stackView)
    stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 12, paddingRight: 80, width: 0, height: 0)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
