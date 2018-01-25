//
//  Client.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import Foundation

struct Client {
  
  let uid: String?
  let username: String
  let profileImageUrl: String
  let carMark: String
  let carModel: String
  let phoneNumber: String
  let email: String?
  
  
  init(uid: String, dictionary: [String: Any]) {
    self.uid = uid
    self.username = dictionary["username"] as? String ?? ""
    self.profileImageUrl = dictionary["profileImageUrl"]  as? String ?? ""
    self.carMark = dictionary["carMark"] as? String ?? ""
    self.carModel = dictionary["carModel"] as? String ?? ""
    self.phoneNumber = dictionary["phoneNumber"] as? String ?? ""
    self.email = dictionary["email"] as? String ?? ""
  }
  
  init(dictionary: [String: Any]) {
    self.uid = nil
    self.username = dictionary["username"] as? String ?? ""
    self.profileImageUrl = dictionary["profileImageUrl"]  as? String ?? ""
    self.carMark = dictionary["carMark"] as? String ?? ""
    self.carModel = dictionary["carModel"] as? String ?? ""
    self.phoneNumber = dictionary["phoneNumber"] as? String ?? ""
    self.email = dictionary["email"] as? String ?? ""
  }
}
