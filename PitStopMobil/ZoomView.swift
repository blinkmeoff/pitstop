//
//  ZoomView.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.12.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit


class ZoomImageView: NSObject {
  
  var masterHomeController: MasterHomeController?
  
  var startingImageView: UIImageView?
  var zoomingImageView: UIImageView?
  
  var startingFrame: CGRect?
  
  var height: CGFloat?
  var width: CGFloat?
  
  lazy var blackBackgroundView: UIView = {
    let view = UIView()
    view.alpha = 0
    view.backgroundColor = UIColor(white: 0, alpha: 0.8)
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
    return view
  }()
  
  @objc func handleDismiss() {
    self.zoomingImageView?.isHidden = false
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      UIApplication.shared.isStatusBarHidden = false
      
      self.zoomingImageView?.frame = self.startingFrame!
      self.blackBackgroundView.alpha = 0
    }) { (completed) in
      self.startingImageView?.isHidden = false
      self.zoomingImageView?.removeFromSuperview()
      self.blackBackgroundView.removeFromSuperview()
    }
  }
  
  
  func performZoomImageView(startingImageView: UIImageView) {
    
    self.startingImageView = startingImageView
    self.startingImageView?.isHidden = true
    
    startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
    
    zoomingImageView = UIImageView(frame: startingFrame!)
    zoomingImageView?.image = startingImageView.image
    zoomingImageView?.contentMode = .scaleAspectFill
    zoomingImageView?.clipsToBounds = true
    
    
    if let keyWindow = UIApplication.shared.keyWindow {
      
      
      keyWindow.addSubview(blackBackgroundView)
      keyWindow.addSubview(zoomingImageView!)
      
      blackBackgroundView.anchor(keyWindow.topAnchor, left: keyWindow.leftAnchor, bottom: keyWindow.bottomAnchor, right: keyWindow.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
      
      width = startingFrame?.width
      height = startingFrame!.height / startingFrame!.width * keyWindow.frame.width
      
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        self.blackBackgroundView.alpha = 1
        self.zoomingImageView?.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: self.height!)
        self.zoomingImageView?.center = keyWindow.center
        
      }, completion: { (completed) in
        //
      })
    }
  }
  
}
