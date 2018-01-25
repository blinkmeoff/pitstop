//
//  Car.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import Foundation


struct Car {
  
  var id: String?
  var mark: String
  var model: String
  var models: [String]?
  var year: String?
  var vin: String?
  var about: String?
  var firstImage: String?
  var secondImage: String?
  
  init(mark: String, model: String, models: [String]? = nil, id: String? = nil) {
    self.id = id
    self.mark = mark
    self.model = model
    self.models = models
  }
  
  init(dictionary: [String: Any], id: String) {
    self.id = id
    self.mark = dictionary["mark"] as? String ?? ""
    self.model = dictionary["model"] as? String ?? ""
    self.year = dictionary["year"] as? String ?? ""
    self.vin = dictionary["vin"] as? String ?? ""
    self.about = dictionary["about"] as? String ?? ""
    self.firstImage = dictionary["firstImage"] as? String ?? ""
    self.secondImage = dictionary["secondImage"] as? String ?? ""
  }
  
}


