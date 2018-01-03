//
//  FavoritesCell.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.12.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import LBTAComponents
import Firebase
import Shimmer

protocol FavoritesCellDelegate {
  func didTapRemoveFromFavorites(uid: String, cell: FavoritesCell)
}

class FavoritesCell: BaseCell {
  
  var delegate: FavoritesCellDelegate?
  
  var user: Master? {
    didSet {
      usernameLabel.text = user?.username
      
      setupProfileImage()
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
    button.setImage(#imageLiteral(resourceName: "like_pink").withRenderingMode(.alwaysOriginal), for: .normal)
    button.setBackgroundImage(UIImage(), for: .normal)
    button.addTarget(self, action: #selector(handleRemoveFromFavorites), for: .touchUpInside)
    return button
  }()
  
  @objc private func handleRemoveFromFavorites() {
    guard let uid = user?.uid else { return }
    delegate?.didTapRemoveFromFavorites(uid: uid, cell: self)
  }
  
  
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



