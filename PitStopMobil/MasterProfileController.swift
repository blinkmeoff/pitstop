//
//  UserProfileController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class MasterProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, MasterProfileHeaderDelegate {
  
  let cellId = "cellId"
  let headerId = "headerId"
  let footerId = "footerId"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView?.backgroundColor = .white
    navigationItem.title = "Профиль"
    registerCells()
    setupLogOutButton()
    fetchMasterInfo()
  }
  
  fileprivate func registerCells() {
    if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.sectionHeadersPinToVisibleBounds = true
      layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    collectionView?.alwaysBounceVertical = true
    collectionView?.register(MasterProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
    collectionView?.register(MasterProfileCell.self, forCellWithReuseIdentifier: cellId)
    collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerId)

  }
  
  fileprivate func setupLogOutButton() {
    if userId != nil {
      return
    } else {
      navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
  }
  
  @objc func handleLogOut() {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    alertController.addAction(UIAlertAction(title: "Выйти", style: .destructive, handler: { (_) in
      
      do {
        try Auth.auth().signOut()
        
        //what happens? we need to present some kind of login controller
        let choiseController = ChoiseController()
        let navController = UINavigationController(rootViewController: choiseController)
        self.present(navController, animated: true, completion: nil)
        
      } catch let signOutErr {
        print("Failed to sign out:", signOutErr)
      }
    }))
    
    alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
    
    present(alertController, animated: true, completion: nil)
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return feedbacks.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MasterProfileCell
    cell.feedback = self.feedbacks[indexPath.item]

    if !feedbacks.isEmpty {
      cell.noFeedbackLabel.isHidden = true
    } else {
      cell.noFeedbackLabel.isHidden = false
    }
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 4
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 4
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = view.frame.width
    return CGSize(width: width, height: 64)
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionElementKindSectionHeader:
      
      let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! MasterProfileHeader
      
      header.master = self.master
      header.feedbacks = self.feedbacks
      header.ordersCount = ordersCount
      header.delegate = self
      return header
    case UICollectionElementKindSectionFooter:
      let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerId, for: indexPath)
      
      setupFooterCell(cell: footer)
      
      return footer
    default:
      fatalError("ERROR")
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return feedbacks.isEmpty ? CGSize(width: collectionView.frame.width, height: 200) : .zero
  }
  
  
  
  private func setupFooterCell(cell: UICollectionReusableView) {
    let noMessagesLabel = UILabel()
    noMessagesLabel.text = "Нет ожидающих заявок"
    noMessagesLabel.textColor = .lightGray
    noMessagesLabel.textAlignment = .center
    noMessagesLabel.font = UIFont.systemFont(ofSize: 17)
    cell.addSubview(noMessagesLabel)
    noMessagesLabel.fillSuperview()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: view.frame.width, height: 228)
  }
  
  var master: Master?
  var userId: String?
  
  fileprivate func fetchMasterInfo() {
    let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
    
    Database.fetchUserWithUID(uid: uid, isMaster: true) { (master) in
      if let master = master as? Master {
        self.master = master
      }
      
      self.fetchFeedback()
      self.fetchOrders()
      
      self.collectionView?.reloadData()
    }
  }
  
  var ordersCount = 0
  
  private func fetchOrders() {
    let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
    let ref = Database.database().reference().child("order-open-for-master").child(uid)
    ref.observe(.value) { (snapshot) in
      self.ordersCount += 1
      self.collectionView?.reloadData()
    }
  }
  
  
  var feedbacks = [Feedback]()
  
  private func fetchFeedback() {
    let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
    let ref = Database.database().reference().child("feedbacks").child(uid)
    ref.observe(.value) { (snapshot) in
      
      guard let dictionaries = snapshot.value as? [String: Any] else { return }
      dictionaries.forEach({ (key, value) in
        guard let dictionary = value as? [String: Any] else { return }
        self.feedbacks.append(Feedback(dictionary: dictionary))
      })
      self.collectionView?.reloadData()
    }
  }
  
  //MARK: Delegate Master Profile Header
  func showChatControllerForUser(uid: String, profileImageUrl: String) {
    
    let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
    chatLogController.receiverUID = uid
    chatLogController.receiverProfileImageUrl = profileImageUrl
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    navigationController?.pushViewController(chatLogController, animated: true)
    
  }
  
  func didTapShowPhoneNumber(phone: String) {
    guard let number = URL(string: "tel://" + phone) else { return }
    UIApplication.shared.open(number)
  }
  
  func didTapOrders() {
    let activeOrdersController = ActiveOrdersController(collectionViewLayout: UICollectionViewFlowLayout())
    let navController = UINavigationController(rootViewController: activeOrdersController)
    self.present(navController, animated: true, completion: nil)
  }
}
