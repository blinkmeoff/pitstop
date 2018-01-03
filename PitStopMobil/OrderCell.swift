//
//  OrderCell.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.12.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import LBTAComponents

class OrderCell: BaseCell {
  
  var masterHomeController: MasterHomeController?
  
  var order: Order? {
    didSet {
      guard let order = order else {
        return
      }
      guard let profileImageUrl = order.clientProfileImageUrl else { return }
      userProfileImageView.loadImage(urlString: profileImageUrl)
      
      guard let mainImage = order.imageURLS?.components(separatedBy: ",") else { return }
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
      
      guard let username = order.clientName else { return }
      let creationDate = order.creationDate.timeAgoDisplay()

      let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
      attributedText.append(NSMutableAttributedString(string: "\n", attributes: nil))
      attributedText.append(NSAttributedString(string: creationDate, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11), NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
      
      usernameLabel.attributedText = attributedText
      
      textView.text = order.descriptionText
    }
  }
  
  let textView: UITextView = {
    let textView = UITextView()
    textView.textColor = .lightGray
//    label.numberOfLines = 3
    textView.isUserInteractionEnabled = true
    textView.font = UIFont.systemFont(ofSize: 11)
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
    iv.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleZoom)))
    return iv
  }()
  
  @objc func handleZoom(_ tapGesture: UILongPressGestureRecognizer) {
    tapGesture.minimumPressDuration = 0.5
    tapGesture.numberOfTouchesRequired = 1
    
    switch tapGesture.state {
    case .cancelled:
      masterHomeController?.zoomImageView.handleDismiss()
    case .ended:
      masterHomeController?.zoomImageView.handleDismiss()
    case .began:
      if let startingImageView = tapGesture.view as? UIImageView {
        if startingImageView.image == nil {
          return
        }
        masterHomeController?.performZoomForStartingImageView(startingImageView: startingImageView)
      }
    default:
      return
    }
  }
  
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
  
  override func setupUI() {
    super.setupUI()
    
    addSubview(separatorLine)
    separatorLine.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 1, paddingRight: 0, width: 0, height: 2)
    
    addSubview(carProblemImageView)
    addSubview(activityIndicatorView)
    carProblemImageView.anchor(top: topAnchor, left: leftAnchor, bottom: separatorLine.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 1, paddingRight: 0, width: 100, height: 0)
    activityIndicatorView.centerXAnchor.constraint(equalTo: carProblemImageView.centerXAnchor).isActive = true
    activityIndicatorView.centerYAnchor.constraint(equalTo: carProblemImageView.centerYAnchor).isActive = true
    
    addSubview(userProfileImageView)
    userProfileImageView.anchor(top: topAnchor, left: carProblemImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 25, height: 25)
    
    addSubview(usernameLabel)
    usernameLabel.anchor(top: nil, left: userProfileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    usernameLabel.centerYAnchor.constraint(equalTo: userProfileImageView.centerYAnchor).isActive = true
    
    addSubview(textView)
    textView.anchor(top: nil, left: carProblemImageView.rightAnchor, bottom: separatorLine.topAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 0, paddingRight: 8, width: 0, height: 52)
    
  }
}


class BaseCell: UICollectionViewCell {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupUI() {}
}
