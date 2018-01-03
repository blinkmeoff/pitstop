//
//  Extensions.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.08.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit



extension UIViewController {
  
  func showAlert(with message: String, completion: (() -> ())? = nil) {
    let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
      completion?()
    }))
    present(alertController, animated: true, completion: nil)
  }
  
  func presentConfirmAlert(message: String?, title: String?, completion: @escaping (Bool) -> ()) {
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
      completion(false)
    }
    let confirmAction = UIAlertAction(title: "OK", style: .destructive) { (_) in
      completion(true)
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(confirmAction)
    
    present(alertController, animated: true, completion: nil)
  }
}

extension UIColor {
  
  static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
    return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
  }
  
}

extension UIView {
  func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
    
    translatesAutoresizingMaskIntoConstraints = false
    
    if let top = top {
      self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
    }
    
    if let left = left {
      self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
    }
    
    if let bottom = bottom {
      bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
    }
    
    if let right = right {
      rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
    }
    
    if width != 0 {
      widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    if height != 0 {
      heightAnchor.constraint(equalToConstant: height).isActive = true
    }
  }
  
}

extension Date {
  
  static func formattedDateString(timeSince1970: Double, _ format: String, timeZone: TimeZone? = TimeZone(secondsFromGMT: 0)) -> String {
    let timestampDate = Date(timeIntervalSince1970: Double(timeSince1970))
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = timeZone
    dateFormatter.dateFormat = format
    
    let formattedDateString = dateFormatter.string(from: timestampDate)
    return formattedDateString
  }
    
  func timeAgoDisplay() -> String {
    let secondsAgo = Int(Date().timeIntervalSince(self))
    
    let minute = 60
    let hour = 60 * minute
    let day = 24 * hour
    let week = 7 * day
    let month = 4 * week
    let year = 12 * month
    
    let quotient: Int
    var unit = String()
    if secondsAgo < minute {
      quotient = secondsAgo
      unit = "сек"
    } else if secondsAgo < hour {
      quotient = secondsAgo / minute
      unit = "мин"
    } else if secondsAgo < day {
      quotient = secondsAgo / hour
      if quotient == 1 {
        unit = "час"
      } else if quotient == 2 || quotient == 3 || quotient == 4 || quotient == 22 || quotient == 23 {
        unit = "часа"
      } else if quotient >= 5 {
        unit = "часов"
      }
    } else if secondsAgo < week {
      quotient = secondsAgo / day
      if quotient == 1 {
        unit = "день"
      } else if quotient == 2 || quotient == 3 || quotient == 4 {
        unit = "дня"
      } else if quotient >= 5 {
        unit = "дней"
      }
    } else if secondsAgo < month {
      quotient = secondsAgo / week
      if quotient == 1 {
        unit = "неделя"
      } else if quotient == 2 || quotient == 3 || quotient == 4 {
        unit = "недели"
      } else if quotient >= 5 {
        unit = "недель"
      }
    } else if secondsAgo < year {
      quotient = secondsAgo / month
      if quotient == 1 {
        unit = "месяц"
      } else if quotient == 2 || quotient == 3 || quotient == 4 {
        unit = "месяца"
      } else if quotient >= 5 {
        unit = "месяцев"
      }
    } else {
      quotient = secondsAgo / year
      if quotient == 1 {
        unit = "год"
      } else if quotient == 2 || quotient == 3 || quotient == 4 {
        unit = "года"
      } else if quotient >= 5 {
        unit = "лет"
      }
    }
    
    return "\(quotient) \(unit) назад"
    
  }
}

extension UITextField {
  
  //set bottom border
  func setBottomBorder(withColor color: UIColor) {
    self.borderStyle = .none
    self.layer.backgroundColor = UIColor.white.cgColor
    
    self.layer.masksToBounds = false
    self.layer.shadowColor = color.cgColor
    self.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
    self.layer.shadowOpacity = 1.0
    self.layer.shadowRadius = 0.0
  }
}

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
  
  func loadImageUsingCacheWithUrlString(_ urlString: String) {
    
    self.image = nil
    
    //check cache for image first
    if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
      self.image = cachedImage
      return
    }
    
    //otherwise fire off a new download
    let url = URL(string: urlString)
    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
      
      //download hit an error so lets return out
      if error != nil {
        print(error ?? "")
        return
      }
      
      DispatchQueue.main.async(execute: {
        
        if let downloadedImage = UIImage(data: data!) {
          imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
          
          self.image = downloadedImage
        }
      })
      
    }).resume()
  }
  
}



