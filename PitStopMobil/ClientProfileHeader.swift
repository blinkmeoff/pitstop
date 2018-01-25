//
//  ClientProfileHeader.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

protocol ClientProfileHeaderDelegate {
  func didTapImageProfile()
  func didTapFavorites()
}

class ClientProfileHeader: UICollectionViewCell {
  
  var delegate: ClientProfileHeaderDelegate?
  
  var client: Client? {
    didSet {
      activityIndicatorView.startAnimating()
      
      guard let profileImageUrl = client?.profileImageUrl else { return }
      profileImageView.loadImage(urlString: profileImageUrl) {
        self.activityIndicatorView.stopAnimating()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
          self.profileImageView.alpha = 1
        }, completion: nil)
      }
      
      guard let username = client?.username else { return }
      
      let attributedText = NSMutableAttributedString(string: "\(username)", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17)])
      
      usernameLabel.attributedText = attributedText
      
      setupUserStats()
    }
  }
  
  fileprivate func setupUserStats() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    let ref = Database.database().reference().child("favorites").child(uid)
    
    ref.observe(.value, with: { (snapshot) in
      
      guard let userIdsDictionary = snapshot.value as? [String: Any] else {
        self.setupFavoritesButtonCount(count: 0)
        return
      }
      
      let favorites = userIdsDictionary.count
      self.setupFavoritesButtonCount(count: favorites)
      
    }) { (err) in
      print(err)
    }
  }
  
  fileprivate func setupFavoritesButtonCount(count: Int) {
    let attributedText = NSMutableAttributedString(string: "\(count)\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 15), NSAttributedStringKey.foregroundColor: UIColor.black])
    
    attributedText.append(NSAttributedString(string: "Избранных", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)]))
    
    favoriteButton.setAttributedTitle(attributedText, for: .normal)
  }
  
  lazy var profileImageView: CachedImageView = {
    let iv = CachedImageView()
    iv.translatesAutoresizingMaskIntoConstraints = false
    iv.contentMode = .scaleAspectFill
    iv.alpha = 0
    iv.isUserInteractionEnabled = true
    iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAddNewProfileImage)))
    iv.layer.borderColor = UIColor(white: 0.3, alpha: 0.5).cgColor
    iv.layer.borderWidth = 0.3
    
    return iv
  }()
  
  @objc func handleAddNewProfileImage() {
    delegate?.didTapImageProfile()
  }
  
  let activityIndicatorView: UIActivityIndicatorView = {
    let aiv = UIActivityIndicatorView()
    aiv.activityIndicatorViewStyle = .gray
    aiv.hidesWhenStopped = true
    return aiv
  }()
  
  lazy var addNewImageView: UIImageView = {
    let iv = UIImageView()
    iv.image = #imageLiteral(resourceName: "new_photo")
    iv.clipsToBounds = true
    iv.contentMode = .scaleAspectFill
    iv.isUserInteractionEnabled = true
    iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAddNewProfileImage)))
    return iv
  }()
  
  let feedbackLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.text = "Автомобили"
    label.font = UIFont.boldSystemFont(ofSize: 17)
    label.textAlignment = .center
    return label
  }()
  
  let usernameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 14)
    label.numberOfLines = 0
    return label
  }()
  
  lazy var favoriteButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = .clear
    button.setTitleColor(.black, for: .normal)
    button.titleLabel?.lineBreakMode = .byWordWrapping
    button.titleLabel?.textAlignment = .center
    button.addTarget(self, action: #selector(handleFavorites), for: .touchUpInside)
    return button
  }()
  
  @objc private func handleFavorites() {
    delegate?.didTapFavorites()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubview(profileImageView)
    addSubview(activityIndicatorView)
    addSubview(addNewImageView)
    
    
    profileImageView.anchor(top: topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
    profileImageView.layer.cornerRadius = 100 / 2
    profileImageView.clipsToBounds = true
    
    addNewImageView.anchor(top: nil, left: nil, bottom: profileImageView.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 24, height: 24)
    
    activityIndicatorView.anchor(top: profileImageView.topAnchor, left: profileImageView.leftAnchor, bottom: profileImageView.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
    setupBottomToolbar()
    
    addSubview(usernameLabel)
    usernameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
    
    addSubview(favoriteButton)
    favoriteButton.anchor(top: nil, left: profileImageView.rightAnchor, bottom: profileImageView.bottomAnchor, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
  }
  
 
  
  
  fileprivate func setupBottomToolbar() {
    
    let topDividerView = UIView()
    topDividerView.backgroundColor = UIColor.lightGray
    
    let bottomDividerView = UIView()
    bottomDividerView.backgroundColor = UIColor.lightGray
    
    let stackView = UIStackView(arrangedSubviews: [feedbackLabel])
    
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    
    addSubview(stackView)
    addSubview(topDividerView)
    addSubview(bottomDividerView)
    
    stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    
    topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    
    bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


