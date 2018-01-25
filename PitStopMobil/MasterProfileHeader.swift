//
//  MasterProfileHeader.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

protocol MasterProfileHeaderDelegate {
  
  func didTapShowPhoneNumber(phone: String)
  func showChatControllerForUser(uid: String, profileImageUrl: String)
  func didTapOrders()
  func didTapEditProfile(master: Master)
}

class MasterProfileHeader: UICollectionViewCell {
  
  var delegate: MasterProfileHeaderDelegate?
  
  
  var ordersCount: Int? {
    didSet {
      guard let count = ordersCount else { return }
      setupOrdersCount(count: count)
    }
  }
  
  var feedbacks: [Feedback]? {
    didSet {
      guard let feedbacks = feedbacks else { return }
      if !feedbacks.isEmpty {
        
        var rating: Float = 0
        feedbacks.forEach { (feedback) in
          rating += Float(feedback.rating)
        }
        
        setupRating(rating: rating / Float(feedbacks.count))
        setupFeedbacksCount(count: feedbacks.count)
        setupStars(rating: rating / Float(feedbacks.count))
      }
      
    }
  }
  
  private func setupStars(rating: Float) {
    switch rating {
    case 0..<0.5:
      ratingImageView.image = #imageLiteral(resourceName: "0_stars")
    case 0.5..<1:
      ratingImageView.image = #imageLiteral(resourceName: "05_stars")
    case 1..<1.5:
      ratingImageView.image = #imageLiteral(resourceName: "1_stars")
    case 1.5..<2:
      ratingImageView.image = #imageLiteral(resourceName: "15_stars")
    case 2..<2.5:
      ratingImageView.image = #imageLiteral(resourceName: "2_stars")
    case 2.5..<3:
      ratingImageView.image = #imageLiteral(resourceName: "25_stars")
    case 3..<3.5:
      ratingImageView.image = #imageLiteral(resourceName: "3_stars")
    case 3.5..<4:
      ratingImageView.image = #imageLiteral(resourceName: "35_stars")
    case 4..<4.5:
      ratingImageView.image = #imageLiteral(resourceName: "4_stars")
    case 4.5..<5:
      ratingImageView.image = #imageLiteral(resourceName: "45_stars")
    case 5:
      ratingImageView.image = #imageLiteral(resourceName: "5_stars")
    default:
      ratingImageView.image = #imageLiteral(resourceName: "0_stars")
    }
  }
  
  private func setupFeedbacksCount(count: Int) {
    let attributedText = NSMutableAttributedString(string: "\(count)\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
  
    attributedText.append(NSAttributedString(string: "Отзывов", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
    followersLabel.attributedText = attributedText
  }
  
  private func setupOrdersCount(count: Int) {
    let attributedText = NSMutableAttributedString(string: "\(count)\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
    
    attributedText.append(NSAttributedString(string: "Заказов", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
    followingLabel.attributedText = attributedText
  }
  
  private func setupRating(rating: Float) {
  
    let attributedText = NSMutableAttributedString(string: String(format: "%.1f \n", rating), attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.black])
    
    attributedText.append(NSAttributedString(string: "Рейтинг", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
    postsLabel.attributedText = attributedText
  }
  
  var master: Master? {
    didSet {
      guard let profileImageUrl = master?.profileImageUrl else { return }
      activityIndicatorView.startAnimating()
      profileImageView.loadImage(urlString: profileImageUrl) {
        self.activityIndicatorView.stopAnimating()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
          self.profileImageView.alpha = 1
        }, completion: nil)
      }
      
      guard let username = master?.username else { return }
      guard let city = master?.city else { return }
      guard let address = master?.address else { return }
      
      let attributedText = NSMutableAttributedString(string: "\(username)\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 15)])
      
      attributedText.append(NSAttributedString(string: " \(city)\n", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)]))
      
      attributedText.append(NSAttributedString(string: " \(address)", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)]))
      
      usernameLabel.attributedText = attributedText
      setupEditMessageButton()
      setupAboutInfo()
    }
  }
  
  fileprivate func setupAboutInfo() {
    let aboutText = master?.about ?? ""
    aboutLabel.isHidden = aboutText.isEmpty
    
    let attributedText = NSMutableAttributedString(string: "О себе: ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
    
    attributedText.append(NSAttributedString(string: "\(aboutText)", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)]))
    
    aboutLabel.attributedText = attributedText
  }
  
  fileprivate func setupEditMessageButton() {
    guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
    
    guard let userId = master?.uid else { return }
    
    if currentLoggedInUserId == userId {
      //edit profile
      setupEditButton()
    } else {
      // call and message
      setupCallAndMessageButton()
    }
  }
  
  
  fileprivate func setupCallAndMessageButton() {
    self.editProfileMessageButton.backgroundColor = UIColor.rgb(red: 22, green: 129, blue: 250)
    self.editProfileMessageButton.layer.cornerRadius = 3
    self.editProfileMessageButton.setImage(#imageLiteral(resourceName: "message").withRenderingMode(.alwaysOriginal), for: .normal)
    self.editProfileMessageButton.tag = 2
    
    let stackView = UIStackView(arrangedSubviews: [editProfileMessageButton, callButton])
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.spacing = 8
    
    addSubview(stackView)
    stackView.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 6, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
  }
  
  fileprivate func setupEditButton() {
    self.editProfileMessageButton.setImage(UIImage(), for: .normal)
    self.editProfileMessageButton.setTitle("Редактировать профиль", for: .normal)
    self.editProfileMessageButton.backgroundColor = .white
    self.editProfileMessageButton.setTitleColor(.black, for: .normal)
    self.editProfileMessageButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    self.editProfileMessageButton.layer.borderWidth = 1
    self.editProfileMessageButton.layer.cornerRadius = 3
    
    addSubview(editProfileMessageButton)
    editProfileMessageButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 6, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)

  }
  
  let profileImageView: CachedImageView = {
    let iv = CachedImageView()
    iv.translatesAutoresizingMaskIntoConstraints = false
    iv.contentMode = .scaleAspectFill
    iv.alpha = 0
    iv.layer.borderColor = UIColor(white: 0.3, alpha: 0.5).cgColor
    iv.layer.borderWidth = 0.3
    
    return iv
  }()
  
  let feedbackLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.text = "Отзывы"
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
  
  
  
  let aboutLabel: UITextView = {
    let textView = UITextView()
    textView.font = UIFont.systemFont(ofSize: 14)
    //        label.numberOfLines = 0
    //        label.backgroundColor = .lightGray
    textView.isScrollEnabled = false
    return textView
  }()
  
  let postsLabel: UILabel = {
    let label = UILabel()
    
    let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.black])
    
    attributedText.append(NSAttributedString(string: "Рейтинг", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
    
    label.attributedText = attributedText
    
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  let followersLabel: UILabel = {
    let label = UILabel()
    
    let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
    
    attributedText.append(NSAttributedString(string: "Отзывов", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
    
    label.attributedText = attributedText
    
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  lazy var followingLabel: UILabel = {
    let label = UILabel()
    
    let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
    
    attributedText.append(NSAttributedString(string: "Заказов", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
    label.isUserInteractionEnabled = true
    label.attributedText = attributedText
    label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowActiveOrders)))
    label.numberOfLines = 0
    label.textAlignment = .center
    return label
  }()
  
  @objc private func handleShowActiveOrders() {
    delegate?.didTapOrders()
  }
  
  let ratingImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.image = #imageLiteral(resourceName: "0_stars")
    iv.backgroundColor = .clear
    iv.translatesAutoresizingMaskIntoConstraints = false
    return iv
  }()
  
  lazy var editProfileMessageButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitleColor(.black, for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    button.addTarget(self, action: #selector(handleEditProfileOrMessage), for: .touchUpInside)
    return button
  }()
  
  lazy var callButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "phone").withRenderingMode(.alwaysOriginal), for: .normal)
    button.backgroundColor = UIColor(r: 72, g: 179, b: 46)
    button.layer.cornerRadius = 3
    button.addTarget(self, action: #selector(handleShowPhoneNumber), for: .touchUpInside)
    return button
  }()
  
  let activityIndicatorView: UIActivityIndicatorView = {
    let aiv = UIActivityIndicatorView()
    aiv.activityIndicatorViewStyle = .gray
    aiv.hidesWhenStopped = true
    return aiv
  }()
  
  @objc func handleShowPhoneNumber() {
    guard let phoneNumber = master?.phoneNumber else { return }
    delegate?.didTapShowPhoneNumber(phone: phoneNumber)
  }
  
  @objc func handleEditProfileOrMessage() {
    print("Execute edit profile / send message logic ...")
    
    guard let userId = master?.uid else { return }
    
    if editProfileMessageButton.tag == 2 {
      
      //send message
      guard let profileImageUrl = master?.profileImageUrl else { return }
      delegate?.showChatControllerForUser(uid: userId, profileImageUrl: profileImageUrl)
    } else {
      
      //edit profile
      if let master = self.master {
        delegate?.didTapEditProfile(master: master)
      }
      
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    addSubview(profileImageView)
    addSubview(activityIndicatorView)
    
    profileImageView.anchor(top: topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
    profileImageView.layer.cornerRadius = 100 / 2
    profileImageView.clipsToBounds = true
    
    activityIndicatorView.anchor(top: profileImageView.topAnchor, left: profileImageView.leftAnchor, bottom: profileImageView.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
    setupBottomToolbar()
    addSubview(usernameLabel)
    usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
    
    addSubview(aboutLabel)
    aboutLabel.anchor(top: usernameLabel.bottomAnchor, left: leftAnchor, bottom: feedbackLabel.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)

    addSubview(ratingImageView)
    ratingImageView.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 58, paddingBottom: 0, paddingRight: 58, width: 0, height: 25)

    setupUserStatsView()
  }
  
  fileprivate func setupUserStatsView() {
    let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
    
    stackView.distribution = .fillEqually
    
    addSubview(stackView)
    stackView.anchor(top: ratingImageView.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 38)
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
    
    stackView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    
    topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    
    bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
