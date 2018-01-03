//
//  ConfirmedOrder.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.12.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import Foundation

class ConfirmedOrder: NSObject {
  
  var masterUID: String?
  var orderUID: String?
  
  init(dictionary: [String: Any]) {
    self.masterUID = dictionary["master"] as? String ?? ""
    self.orderUID = dictionary["order"] as? String ?? ""
  }
  
}
