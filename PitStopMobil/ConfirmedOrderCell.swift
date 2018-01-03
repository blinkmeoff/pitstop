//
//  ConfirmedOrderCell.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.12.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import LBTAComponents
import Firebase

protocol ConfirmedOrderCellDelegate {
  func sendFeedback(cell: ConfirmedOrderCell)
}

class ConfirmedOrderCell: BaseCell {
  
  var delegate: ConfirmedOrderCellDelegate?
  
  var confirmedOrder: ConfirmedOrder? {
    didSet {
      fetchOrder()
      fetchUser()
    }
  }
  
  var master: Master? {
    didSet {
      guard let profileImageUrl = master?.profileImageUrl else { return }
      userProfileImageView.loadImage(urlString: profileImageUrl)
      
      mastersLabel.text = master?.username
    }
  }
  
  private func fetchUser() {
    guard let userId = confirmedOrder?.masterUID else { return }
    let ref = Database.database().reference().child("users").child(userId)
    ref.observeSingleEvent(of: .value) { (snapshot) in
      guard let dictionary = snapshot.value as? [String: Any] else { return }
      self.master = Master(uid: userId, dictionary: dictionary)
    }
  }
  
  var order: Order? {
    didSet {
      guard let mainImage = order?.imageURLS?.components(separatedBy: ",") else { return }
      if !mainImage.isEmpty {
        if let imageUrl = mainImage.first {
          activityIndicatorView.startAnimating()
          carProblemImageView.loadImage(urlString: imageUrl, completion: {
            self.activityIndicatorView.stopAnimating()
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
              self.carProblemImageView.alpha = 1
            }, completion: nil)
            
          })
        }
      }
      
      textView.text = order?.descriptionText
      
      guard let creationDate = order?.creationDate.timeAgoDisplay() else { return }
      
      let attributedText = NSMutableAttributedString(string: "Созданна: ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12)])
      attributedText.append(NSAttributedString(string: creationDate, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11), NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
      attributedText.append(NSAttributedString(string: "\nОписание:", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor.black]))
      
      usernameLabel.attributedText = attributedText
      
      setupViewsLabel()
    }
  }
  
  private func fetchOrder() {
    guard let orderId = confirmedOrder?.orderUID else { return }
    let ref = Database.database().reference().child("orders").child(orderId)
    ref.observeSingleEvent(of: .value) { (snapshot) in
      guard let dictionary = snapshot.value as? [String: Any] else { return }
      self.order = Order(dictionary: dictionary)
    }
  }
  

  private func setupViewsLabel() {
    let attributedText = NSMutableAttributedString(string: "Мастер: ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: Settings.Color.orange])
    
    viewsLabel.attributedText = attributedText
  }
  
  let textView: UITextView = {
    let textView = UITextView()
    textView.textColor = .lightGray
    //    label.numberOfLines = 3
    textView.font = UIFont.systemFont(ofSize: 12)
    textView.isScrollEnabled = false
    textView.isEditable = false
    return textView
  }()
  
  let activityIndicatorView: UIActivityIndicatorView = {
    let aiv = UIActivityIndicatorView()
    aiv.activityIndicatorViewStyle = .gray
    aiv.translatesAutoresizingMaskIntoConstraints = false
    aiv.hidesWhenStopped = true
    return aiv
  }()
  
  let userProfileImageView: CachedImageView = {
    let iv = CachedImageView()
    iv.contentMode = .scaleAspectFill
    iv.layer.cornerRadius = 12.5
    iv.clipsToBounds = true
    return iv
  }()
  
  lazy var carProblemImageView: CachedImageView = {
    let iv = CachedImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.alpha = 0
    iv.isUserInteractionEnabled = true
    return iv
  }()
  
  let usernameLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    return label
  }()
  
  
  let separatorLine: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 0, alpha: 0.05)
    return view
  }()
  
  let mastersLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.textColor = Settings.Color.orange
    label.font = UIFont.boldSystemFont(ofSize: 13)
    return label
  }()
  
  let viewsLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    return label
  }()
  
  lazy var confirmedButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "done").withRenderingMode(.alwaysOriginal), for: .normal)
    button.imageView?.contentMode = .scaleAspectFill
    button.contentVerticalAlignment = .fill
    button.contentHorizontalAlignment = .fill
    button.addTarget(self, action: #selector(sendFeedback), for: .touchUpInside)
    return button
  }()
  
  @objc private func sendFeedback() {
    delegate?.sendFeedback(cell: self)
  }
  
  override func setupUI() {
    super.setupUI()
    addSubview(separatorLine)
    separatorLine.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 1, paddingRight: 0, width: 0, height: 0.75)
    
    addSubview(carProblemImageView)
    addSubview(activityIndicatorView)
    carProblemImageView.anchor(top: topAnchor, left: leftAnchor, bottom: separatorLine.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 1, paddingRight: 0, width: 100, height: 0)
    activityIndicatorView.centerXAnchor.constraint(equalTo: carProblemImageView.centerXAnchor).isActive = true
    activityIndicatorView.centerYAnchor.constraint(equalTo: carProblemImageView.centerYAnchor).isActive = true
    
    addSubview(confirmedButton)
    confirmedButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 20, height: 20)

    
    addSubview(usernameLabel)
    usernameLabel.anchor(top: topAnchor, left: carProblemImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    
    addSubview(textView)
    textView.anchor(top: usernameLabel.bottomAnchor, left: carProblemImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 8, width: 0, height: 42)
    
    addSubview(viewsLabel)
    viewsLabel.anchor(top: nil, left: carProblemImageView.rightAnchor, bottom: separatorLine.topAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
    
    addSubview(userProfileImageView)
    userProfileImageView.anchor(top: nil, left: viewsLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 25, height: 25)
    userProfileImageView.centerYAnchor.constraint(equalTo: viewsLabel.centerYAnchor).isActive = true
    
    addSubview(mastersLabel)
    mastersLabel.anchor(top: nil, left: userProfileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    mastersLabel.centerYAnchor.constraint(equalTo: viewsLabel.centerYAnchor).isActive = true
  }
  
}
