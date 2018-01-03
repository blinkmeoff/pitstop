//
//  LoadingIndicator.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit

class LoadingIndicator: NSObject {
  
  static let shared = LoadingIndicator()
  
  let blackView = UIView()
  
  let blackCenteredView : UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 10
    view.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0.9)
    return view
  }()
  
  let activityIndicator: UIActivityIndicatorView = {
    let aiv = UIActivityIndicatorView()
    aiv.activityIndicatorViewStyle = .whiteLarge
    aiv.hidesWhenStopped = true
    aiv.translatesAutoresizingMaskIntoConstraints = false
    return aiv
  }()
  
  let loadingLabel: UILabel = {
    let label = UILabel()
    label.text = "Загрузка"
    label.textColor = .white
    label.font = UIFont.systemFont(ofSize: 13)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  func showLoadingIndicator() {
    
    if let window = UIApplication.shared.keyWindow {
      
      blackView.backgroundColor = UIColor(white: 0, alpha: 0.3)
      blackView.frame = window.frame
      blackView.alpha = 0
      blackCenteredView.alpha = 0
      activityIndicator.startAnimating()
      
      setupViews(for: window)
      
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        self.blackCenteredView.alpha = 1
        self.blackView.alpha = 1
      }, completion: { (_) in
        
      })
    }
  }
  
  func hideLoadingIndicator() {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.blackCenteredView.alpha = 0
      self.blackView.alpha = 0
    }) { (_) in
      self.blackView.removeFromSuperview()
      self.blackCenteredView.removeFromSuperview()
    }
  }
  
  func setupViews(for window: UIWindow) {
    
    window.addSubview(blackView)
    window.addSubview(blackCenteredView)
    blackCenteredView.addSubview(activityIndicator)
    blackCenteredView.addSubview(loadingLabel)
    
    blackCenteredView.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
    blackCenteredView.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
    blackCenteredView.widthAnchor.constraint(equalToConstant: 100).isActive = true
    blackCenteredView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    
    activityIndicator.centerXAnchor.constraint(equalTo: blackCenteredView.centerXAnchor).isActive = true
    activityIndicator.centerYAnchor.constraint(equalTo: blackCenteredView.centerYAnchor).isActive = true
    
    loadingLabel.centerXAnchor.constraint(equalTo: blackCenteredView.centerXAnchor).isActive = true
    loadingLabel.anchor(nil, left: nil, bottom: blackCenteredView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 0)
  }
  
}
