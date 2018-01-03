//
//  ClientOrderCell.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.12.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import LBTAComponents
import Firebase


protocol PendingOrderCellDelegate {
  func didTapDeletePendingOrder(cell: PendingOrderCell)
}

class PendingOrderCell: BaseCell {
  
  var delegate: PendingOrderCellDelegate?
  

  
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
      
//      guard let username = order.clientName else { return }
      let creationDate = order.creationDate.timeAgoDisplay()
      
      let attributedText = NSMutableAttributedString(string: "Созданна: ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12)])
      attributedText.append(NSAttributedString(string: creationDate, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11), NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
      attributedText.append(NSAttributedString(string: "\nОписание:", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor.black]))
      
      usernameLabel.attributedText = attributedText
      
      textView.text = order.descriptionText
      setupMastersLabel(text: order.mastersAppliedCount)
      setupViewsCount(text: order.views)
    }
  }
  
  private func setupViewsCount(text: String) {
    let attributedText = NSMutableAttributedString(string: "Просмотров: ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor.black])
    attributedText.append(NSAttributedString(string: text, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13), NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
    
    viewsLabel.attributedText = attributedText
  }
  
  private func setupMastersLabel(text: String) {
    let attributedText = NSMutableAttributedString(string: "Откликов: ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor.black])
    attributedText.append(NSAttributedString(string: text, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13), NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
    
    mastersLabel.attributedText = attributedText
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
    return label
  }()
  
  let viewsLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    return label
  }()
  
  lazy var deleteButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "remove").withRenderingMode(.alwaysOriginal), for: .normal)
    button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
    return button
  }()
  
  @objc private func handleDelete() {
    delegate?.didTapDeletePendingOrder(cell: self)
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

    addSubview(deleteButton)
    deleteButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 20, height: 20)
    
    addSubview(usernameLabel)
    usernameLabel.anchor(top: topAnchor, left: carProblemImageView.rightAnchor, bottom: nil, right: deleteButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    
    addSubview(textView)
    textView.anchor(top: usernameLabel.bottomAnchor, left: carProblemImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 8, width: 0, height: 42)
    
    let stackView = UIStackView(arrangedSubviews: [viewsLabel, mastersLabel])
    stackView.distribution = .fillEqually
    stackView.axis = .horizontal
    addSubview(stackView)
    stackView.anchor(top: nil, left: carProblemImageView.rightAnchor, bottom: separatorLine.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
    
   
    
  }
  
}
