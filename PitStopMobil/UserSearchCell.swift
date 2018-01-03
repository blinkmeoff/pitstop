//
//  UserSearchCell.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import LBTAComponents
import Firebase
import Shimmer

class UserSearchCell: UICollectionViewCell {
  
  var user: Master? {
    didSet {
      usernameLabel.text = user?.username
      
      setupProfileImage()
      setupFavoriteButton()
    }
  }
  
  fileprivate func setupProfileImage() {
    guard let profileImageUrl = user?.profileImageUrl else { return }
    
    if profileImageUrl == "" {
      profileImageView.image = #imageLiteral(resourceName: "user").withRenderingMode(.alwaysTemplate)
      profileImageView.tintColor = UIColor(white: 0.8, alpha: 0.5)
    } else {
      profileImageView.loadImage(urlString: profileImageUrl) {
        self.shimmerImageView.isShimmering = false
      }
    }
  }
  
  fileprivate func setupFavoriteButton() {
      guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
      
      guard let userId = user?.uid else { return }
    
      //check for favorite
      Database.database().reference().child("favorites").child(currentLoggedInUserId).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let isFavorite = snapshot.value as? Int, isFavorite == 1 {
          self.setupRemoveFromFavoriteStyle()
        } else {
          self.setupAddToFavoriteStyle()
        }
        
        self.addToFavoriteButton.isHidden = false
        
      }, withCancel: { (err) in
        print("Failed to check if following:", err)
      })
  }
  
  @objc func handleAddToFavorite() {
    print("Execute add or remove favorite master")
    
    guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
    
    guard let userId = user?.uid else { return }
    
    if addToFavoriteButton.isSelected {
      
      //add to favorite
      Database.database().reference().child("favorites").child(currentLoggedInUserId).child(userId).removeValue(completionBlock: { (err, ref) in
        if let err = err {
          print("Failed to remove master from favorites:", err)
          return
        }
        
        print("Successfully removed master from favorites:", self.user?.username ?? "")
        self.setupAddToFavoriteStyle()
      })
      
    } else {
      //remove from favorites
      let ref = Database.database().reference().child("favorites").child(currentLoggedInUserId)
      
      let values = [userId: 1]
      ref.updateChildValues(values) { (err, ref) in
        if let err = err {
          print("Failed to add master to favorites:", err)
          return
        }
        print("Successfully added master to favorites: ", self.user?.username ?? "")
        self.setupRemoveFromFavoriteStyle()
      }
    }
  }
  
  fileprivate func setupAddToFavoriteStyle() {
    addToFavoriteButton.isSelected = false
    addToFavoriteButton.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
    addToFavoriteButton.tintColor = .black
  }
  
  fileprivate func setupRemoveFromFavoriteStyle() {
    addToFavoriteButton.isSelected = true
    addToFavoriteButton.setImage(#imageLiteral(resourceName: "like_pink").withRenderingMode(.alwaysOriginal), for: .selected)
    addToFavoriteButton.setBackgroundImage(UIImage(), for: .selected)
  }
  

  let shimmerImageView : FBShimmeringView = {
    let shimmer = FBShimmeringView()
    shimmer.clipsToBounds = true
    shimmer.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
    shimmer.shimmeringPauseDuration = 0.8
    shimmer.shimmeringSpeed = 100
    return shimmer
  }()
  
  lazy var profileImageView: CachedImageView = {
    let iv = CachedImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
    iv.layer.borderColor = UIColor(white: 0.8, alpha: 0.5).cgColor
    iv.layer.borderWidth = 1
    return iv
  }()
  
  let usernameLabel: UILabel = {
    let label = UILabel()
    label.text = "Мастер"
    label.font = UIFont.boldSystemFont(ofSize: 14)
    return label
  }()
  
  lazy var addToFavoriteButton: UIButton = {
    let button = UIButton(type: .custom)
    button.contentMode = .scaleAspectFit
    button.clipsToBounds = true
    button.backgroundColor = .clear
    button.isHidden = true
    button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
    button.addTarget(self, action: #selector(handleAddToFavorite), for: .touchUpInside)
    return button
  }()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(shimmerImageView)
    shimmerImageView.addSubview(profileImageView)
    addSubview(usernameLabel)
    addSubview(addToFavoriteButton)
    
    shimmerImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
    shimmerImageView.layer.cornerRadius = 50 / 2
    shimmerImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    
    profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 14, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
    profileImageView.layer.cornerRadius = 50 / 2
    profileImageView.anchorCenterYToSuperview()
    
    usernameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
    addToFavoriteButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 22, width: 24, height: 22)
    addToFavoriteButton.anchorCenterYToSuperview()
    
    let separatorView = UIView()
    separatorView.backgroundColor = UIColor(white: 0, alpha: 0.5)
    addSubview(separatorView)
    separatorView.anchor(top: nil, left: usernameLabel.leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    
    shimmerImageView.contentView = profileImageView
    shimmerImageView.isShimmering = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}


