//
//  Order.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.12.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import Foundation


class Order: NSObject {
 
  let creationDate: Date
  let ownerId: String?
  let imageURLS: String?
  let skills: String?
  let descriptionText: String?
  let clientProfileImageUrl: String?
  let clientName: String?
  let status: String?
  var mastersAppliedCount = "0"
  var views = "0"
  
  init(dictionary: [String: Any]) {
    self.clientName = dictionary["clientName"] as? String ?? ""
    self.clientProfileImageUrl = dictionary["clientProfileImageUrl"] as? String ?? ""
    self.ownerId = dictionary["ownerId"] as? String ?? ""
    self.imageURLS = dictionary["imageUrls"]  as? String ?? ""
    self.skills = dictionary["skills"] as? String ?? ""
    self.descriptionText = dictionary["description"] as? String ?? ""
    
    let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
    self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    
    self.status = dictionary["status"] as? String ?? ""
  }
  
}
