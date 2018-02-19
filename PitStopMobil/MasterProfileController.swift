//
//  UserProfileController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class MasterProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if userId != nil {
      tabBarController?.tabBar.isHidden = true
    } else {
      tabBarController?.tabBar.isHidden = false
    }
  }
  
  fileprivate func setupLogOutButton() {
    if userId != nil {
      return
    } else {
      navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
  }
  
  func removeFCMToken(completion: () -> Swift.Void) {
    if let uid = Auth.auth().currentUser?.uid {
      let ref = Database.database().reference().child("users").child(uid)
      ref.updateChildValues(["fcmToken": ""])
      completion()
    }
  }
  
  @objc func handleLogOut() {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    alertController.addAction(UIAlertAction(title: "Выйти", style: .destructive, handler: { (_) in
      
      self.removeFCMToken {
        do {
          //remove notifications
          try Auth.auth().signOut()
          
          //what happens? we need to present some kind of login controller
          let choiseController = ChoiseController()
          let navController = UINavigationController(rootViewController: choiseController)
          self.present(navController, animated: true, completion: nil)
          
        } catch let signOutErr {
          print("Failed to sign out:", signOutErr)
        }
      }
      
    }))
    
    alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
    let versionNumber = Bundle.applicationVersionNumber
    alertController.title = "Версия \(versionNumber)"
    
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
    let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
    let dummyCell = MasterProfileCell(frame: frame)
    dummyCell.feedback = feedbacks[indexPath.item]
    dummyCell.layoutIfNeeded()
    
    let targetSize = CGSize(width: view.frame.width, height: 1000)
    let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
    
    let height = max(64, estimatedSize.height)
    return CGSize(width: view.frame.width, height: height)
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
    noMessagesLabel.text = "Нет отзывов"
    noMessagesLabel.textColor = .lightGray
    noMessagesLabel.textAlignment = .center
    noMessagesLabel.font = UIFont.systemFont(ofSize: 17)
    cell.addSubview(noMessagesLabel)
    noMessagesLabel.fillSuperview()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//    return CGSize(width: view.frame.width, height: 228)
    let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
    let dummyCell = MasterProfileHeader(frame: frame)
    dummyCell.master = master
    dummyCell.layoutIfNeeded()
    
    let targetSize = CGSize(width: view.frame.width, height: 1000)
    let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
    
    let height = max(180, estimatedSize.height)
    return CGSize(width: view.frame.width, height: height)
  }
  
  var master: Master?
  var userId: String?
  
  fileprivate func fetchMasterInfo() {
    let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
    if uid.isEmpty { return }
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
    ordersCount = 0
    let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
    if uid.isEmpty { return }
    let ref = Database.database().reference().child("order-open-for-master").child(uid)
    ref.observe(.value) { (snapshot) in
      guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
      self.ordersCount = allObjects.count
      self.collectionView?.reloadData()
    }
  }
  
  
  var feedbacks = [Feedback]()
  
  private func fetchFeedback() {
    feedbacks.removeAll()
    let uid = userId ?? (Auth.auth().currentUser?.uid ?? "")
    if uid.isEmpty { return }
    let ref = Database.database().reference().child("feedbacks").child(uid)
    ref.observe(.value) { (snapshot) in
      
      guard let dictionaries = snapshot.value as? [String: Any] else { return }
      dictionaries.forEach({ (key, value) in
        guard let dictionary = value as? [String: Any] else { return }
        self.feedbacks.append(Feedback(dictionary: dictionary))
      })
      self.feedbacks.sort(by: { (f1, f2) -> Bool in
        return f1.creationDate.compare(f2.creationDate) == .orderedDescending
      })
      self.collectionView?.reloadData()
    }
  }
  
  
}

extension MasterProfileController: MasterProfileHeaderDelegate {
  
  func showChatControllerForUser(uid: String, profileImageUrl: String) {
    
    let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
    chatLogController.receiverUID = uid
    chatLogController.receiverProfileImageUrl = profileImageUrl
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    navigationController?.navigationBar.tintColor = .black
    navigationController?.pushViewController(chatLogController, animated: true)
  }
  
  func didTapShowPhoneNumber(phone: String) {
    guard let number = URL(string: "tel://" + phone) else { return }
    UIApplication.shared.open(number)
  }
  
  func didTapOrders() {
    let activeOrdersController = ActiveOrdersController(collectionViewLayout: UICollectionViewFlowLayout())
    activeOrdersController.userId = userId
    let navController = UINavigationController(rootViewController: activeOrdersController)
    self.present(navController, animated: true, completion: nil)
  }
  
  func didTapEditProfile(master: Master) {
    let editController = MasterEditProfileController()
    editController.master = master
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    navigationController?.navigationBar.tintColor = .black
    navigationController?.pushViewController(editController, animated: true)
  }
}
