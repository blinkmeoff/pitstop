//
//  MasterProfileCell.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

class MasterProfileCell: UICollectionViewCell {
  
  var feedback: Feedback? {
    didSet {
      guard let feedback = feedback else { return }
      
      
      textView.text = feedback.comment
      fetchUser()
      setupDate()
      
      setupFeedbackRatingImage(feedback.rating)
    }
  }
  
  private func setupFeedbackRatingImage(_ rating: Int) {
    switch rating {
    case 0:
      ratingImageView.image = #imageLiteral(resourceName: "0_stars")
  
    case 1:
      ratingImageView.image = #imageLiteral(resourceName: "1_stars")
    
    case 2:
      ratingImageView.image = #imageLiteral(resourceName: "2_stars")
    
    case 3:
      ratingImageView.image = #imageLiteral(resourceName: "3_stars")
    
    case 4:
      ratingImageView.image = #imageLiteral(resourceName: "4_stars")
   
    case 5:
      ratingImageView.image = #imageLiteral(resourceName: "5_stars")
    default:
      ratingImageView.image = #imageLiteral(resourceName: "0_stars")
    }
  }
  
  let ratingImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.image = #imageLiteral(resourceName: "0_stars")
    iv.backgroundColor = .clear
    iv.translatesAutoresizingMaskIntoConstraints = false
    return iv
  }()
  
  private func setupDate() {
    guard let dateValue = feedback?.finishedDate else { return }
    let date = Date(timeIntervalSince1970: dateValue)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.YYYY"
    let creationDate = dateFormatter.string(from: date)
    self.creationDateLabel.text = creationDate
  }
  
  private func fetchUser() {
    guard let uid = feedback?.client else { return }
    Database.fetchUserWithUID(uid: uid, isMaster: false) { (client) in
      if let client = client as? Client {
        self.profileImageView.loadImage(urlString: client.profileImageUrl)
        self.usernameLabel.text = client.username
      }
    }
  }
  
  let noFeedbackLabel: UILabel = {
    let label = UILabel()
    label.text = "Нет отзывов"
    label.textColor = .lightGray
    label.font = UIFont.systemFont(ofSize: 15)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  let creationDateLabel: UILabel = {
    let label = UILabel()
    label.textColor = .lightGray
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()
  
  let usernameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = UIFont.boldSystemFont(ofSize: 13)
    return label
  }()
  
  let separatorLine: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 0, alpha: 0.4)
    return view
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(noFeedbackLabel)
    noFeedbackLabel.anchorCenterSuperview()
    
    addSubview(profileImageView)
    profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
    profileImageView.layer.cornerRadius = 40 / 2
    
    addSubview(usernameLabel)
    addSubview(creationDateLabel)
    addSubview(ratingImageView)
    
    usernameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    creationDateLabel.anchor(top: nil, left: usernameLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    creationDateLabel.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor).isActive = true
    
    ratingImageView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 100, height: 20)
    ratingImageView.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor).isActive = true
    
    addSubview(textView)
    textView.anchor(top: creationDateLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
    
    addSubview(separatorLine)
    separatorLine.anchor(top: nil, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.75)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  let textView: UITextView = {
    let textView = UITextView()
    textView.font = UIFont.systemFont(ofSize: 13)
    textView.isScrollEnabled = false
    return textView
  }()
  
  let profileImageView: CachedImageView = {
    let iv = CachedImageView()
    iv.clipsToBounds = true
    iv.contentMode = .scaleAspectFill
    return iv
  }()
  
 
}
