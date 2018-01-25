//
//  FirebaseUtils.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import Foundation
import Firebase

extension Database {
  
  static func fetchUserWithUID(uid: String, isMaster: Bool, completion: @escaping (Any) -> ()) {
    Database.database().reference().child("users").child(uid).observe(.value, with: { (snapshot) in
      
      guard let userDictionary = snapshot.value as? [String: Any] else { return }
      let user: Any = isMaster ? Master(uid: uid, dictionary: userDictionary) : Client(uid: uid, dictionary: userDictionary)
      
      completion(user)
      
    }) { (err) in
      print("Failed to fetch user for posts:", err)
    }
  }
  
}
