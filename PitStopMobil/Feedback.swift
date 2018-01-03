//
//  Feedback.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.12.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//
import Foundation

class Feedback: NSObject {
  
  var client: String?
  var comment: String?
  var finishedDate: Double?
  var orderUID: String?
  var rating = 0
  
  init(dictionary: [String: Any]) {
    self.client = dictionary["client"] as? String ?? ""
    self.comment = dictionary["comment"] as? String ?? ""
    self.finishedDate = dictionary["finishedDate"] as? Double ?? 0
    self.orderUID = dictionary["orderUID"] as? String ?? ""
    self.rating = dictionary["rating"] as? Int ?? 0
  }
  
}

