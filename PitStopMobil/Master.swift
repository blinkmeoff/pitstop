//
//  Master.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import Foundation

struct Master {
  
  let uid: String?
  let username: String
  let phoneNumber: String?
  let profileImageUrl: String
  let city: String
  let address: String
  let latitude: Double
  let longitude: Double
  let isClient: Int
  
  init(uid: String, dictionary: [String: Any]) {
    self.uid = uid
    self.phoneNumber = dictionary["phoneNumber"] as? String ?? ""
    self.username = dictionary["username"] as? String ?? ""
    self.profileImageUrl = dictionary["profileImageUrl"]  as? String ?? ""
    self.city = dictionary["city"] as? String ?? ""
    self.address = dictionary["address"] as? String ?? ""
    self.latitude = dictionary["latitude"] as? Double ?? 0
    self.longitude = dictionary["longitude"] as? Double ?? 0
    self.isClient = dictionary["isClient"] as? Int ?? 0
  }
  
  init(dictionary: [String: Any]) {
    self.uid = nil
    self.phoneNumber = dictionary["phoneNumber"] as? String ?? ""
    self.username = dictionary["username"] as? String ?? ""
    self.profileImageUrl = dictionary["profileImageUrl"]  as? String ?? ""
    self.city = dictionary["city"] as? String ?? ""
    self.address = dictionary["address"] as? String ?? ""
    self.latitude = dictionary["latitude"] as? Double ?? 0
    self.longitude = dictionary["longitude"] as? Double ?? 0
    self.isClient = dictionary["isClient"] as? Int ?? 0
  }
}
