//
//  ClientProfileCell.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import LBTAComponents

class ClientCarCell: UITableViewCell {
  
  var car: Car? {
    didSet {
      carMarkLabel.attributedText = setupLabelWithValues(header: "Марка", body: car?.mark ?? "-")
      carModelLabel.attributedText = setupLabelWithValues(header: "Модель", body: car?.model ?? "-")
      
      let carYear = car?.year ?? "-"
      carYearLabel.attributedText = setupLabelWithValues(header: "Год выпуска", body: carYear.isEmpty ? "-" : carYear)
      
      let carVin = car?.vin ?? "-"
      carVINLabel.attributedText = setupLabelWithValues(header: "VIN номер", body: carVin.isEmpty ? "-" : carVin)
      
      if let firstImageURL = car?.firstImage, firstImageURL.count > 0 {
        realCarPhotoImageView.loadImage(urlString: firstImageURL, completion: {
          self.carImageView.isHidden = true
          UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.realCarPhotoImageView.alpha = 1
          }, completion: nil)
        })
      } else {
        self.realCarPhotoImageView.alpha = 0
        carImageView.isHidden = false
      }
    }
  }
  
  private func setupLabelWithValues(header: String, body: String) -> NSAttributedString {
    
    let attrStr = NSMutableAttributedString(string: header, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.black])
    attrStr.append(NSAttributedString(string: ": "))
    attrStr.append(NSAttributedString(string: body, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
    return attrStr
  }
  
  let separatorLineView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
    return view
  }()
  
  let carImageView: CachedImageView = {
    let iv = CachedImageView()
    iv.contentMode = .scaleAspectFill
    iv.image = #imageLiteral(resourceName: "car").withRenderingMode(.alwaysTemplate)
    iv.tintColor = .lightGray
    iv.clipsToBounds = true
    return iv
  }()
  
  let realCarPhotoImageView: CachedImageView = {
    let iv = CachedImageView()
    iv.contentMode = .scaleAspectFill
    iv.tintColor = .lightGray
    iv.alpha = 0
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
  
  let carYearLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 15)
    return label
  }()
  
  let carVINLabel: UILabel = {
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
    addSubview(realCarPhotoImageView)
    addSubview(carImageView)
    
    realCarPhotoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 0)
    
    carImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: 70, height: 36)
    carImageView.anchorCenterYToSuperview()
    
    let stackView = UIStackView(arrangedSubviews: [carMarkLabel, carModelLabel, carYearLabel, carVINLabel])
    stackView.distribution = .fillEqually
    stackView.axis = .vertical
    addSubview(stackView)
    stackView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 132, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)
    
    addSubview(separatorLineView)
    separatorLineView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 70, paddingBottom: 0, paddingRight: 12, width: 0, height: 0.7)
  }
  
}
