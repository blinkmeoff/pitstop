//
//  OrderImageCell.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.12.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import LBTAComponents

class OrderImageCell: BaseCell {
  
  var imageURL: String? {
    didSet {
      guard let url = imageURL else { return }
      problemImageView.loadImage(urlString: url) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
          self.problemImageView.alpha = 1
        }, completion: nil)
      }
    }
  }
  
  lazy var problemImageView: CachedImageView = {
    let iv = CachedImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.alpha = 0
    iv.isUserInteractionEnabled = true
    return iv
  }()
  
  override func setupUI() {
    super.setupUI()
    addSubview(problemImageView)
    problemImageView.fillSuperview()
  }
  
}
