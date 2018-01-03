//
//  ClientProfileCell.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit

class ClientCarCell: UITableViewCell {
  
  var car: Car? {
    didSet {
      carMarkLabel.text = car?.mark
      carModelLabel.text = car?.model
    }
  }
  
  let separatorLineView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
    return view
  }()
  
  let carImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.image = #imageLiteral(resourceName: "car").withRenderingMode(.alwaysTemplate)
    iv.tintColor = .lightGray
    iv.clipsToBounds = true
    return iv
  }()
  
  let carMarkLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 15)
    return label
  }()
  
  let carModelLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 15)
    return label
  }()
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupViews() {
    addSubview(carImageView)
    addSubview(carMarkLabel)
    addSubview(carModelLabel)
    addSubview(separatorLineView)
    
    carImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 46, height: 22)
    carImageView.anchorCenterYToSuperview()
    
    carMarkLabel.anchor(top: nil, left: carImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    carMarkLabel.anchorCenterYToSuperview()
    
    carModelLabel.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
    carModelLabel.anchorCenterYToSuperview()
    
    separatorLineView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 70, paddingBottom: 0, paddingRight: 12, width: 0, height: 0.7)
  }
  
}
