//
//  ApliedMastersController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.12.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class ApliedMastersController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  var key: String?
  var users = [Master]()
  var usersDictionary = [String: Master]()
  
  var item: Int?
  var menuBarPendingCell: MenuBarPendingCell?
  
  var clientOrdersController: ClientOrdersController?

  let cellId = "cellId"
  let footerId = "footerId"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Мастера"
    navigationController?.navigationBar.isTranslucent = true
    navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    navigationController?.navigationBar.shadowImage = nil
    setupCollectionView()
    fetchApliedUsers()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = true
  }
  
  private func setupCollectionView() {
    collectionView?.backgroundColor = .white
    collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerId)
    collectionView?.register(ApliedMasterCell.self, forCellWithReuseIdentifier: cellId)
  }

  
  private func fetchApliedUsers() {
    guard let key = self.key else { return }
    let ref = Database.database().reference().child("user-applied-to-orders").child(key)
    ref.observeSingleEvent(of: .value) { (snapshot) in
      guard let dictionary = snapshot.value as? [String: Any] else { return }
      guard let userSnapshotKey = dictionary.first?.key else { return }
      
      let userRef = Database.database().reference().child("users").child(userSnapshotKey)
      userRef.observeSingleEvent(of: .value, with: { (snapshot) in
        guard let dictionary = snapshot.value as? [String: Any] else { return }
        let user = Master(uid: snapshot.key, dictionary: dictionary)
        self.usersDictionary[snapshot.key] = user
        self.attemptReloadOfTable()
      })
      
    }
  }
  
  var timer: Timer?
  
  fileprivate func attemptReloadOfTable() {
    self.timer?.invalidate()
    
    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
  }
  
  @objc func handleReloadTable() {
    self.users = Array(self.usersDictionary.values)
    
    //this will crash because of background thread, so lets call this on dispatch_async main thread
    DispatchQueue.main.async(execute: {
      self.collectionView?.reloadData()
    })
  }
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return users.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ApliedMasterCell
    cell.user = users[indexPath.item]
    cell.delegate = self
    cell.apliedMasterCellDelegate = self
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width, height: 84)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return users.isEmpty ? CGSize(width: collectionView.frame.width, height: collectionView.frame.height - 60 - 40) : .zero
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerId, for: indexPath)
    
    setupFooterCell(cell: footer)
    
    return footer
  }
  
  private func setupFooterCell(cell: UICollectionReusableView) {
    let noMessagesLabel = UILabel()
    noMessagesLabel.text = "Еще никто не откликнулся"
    noMessagesLabel.textColor = .lightGray
    noMessagesLabel.textAlignment = .center
    noMessagesLabel.font = UIFont.systemFont(ofSize: 17)
    cell.addSubview(noMessagesLabel)
    noMessagesLabel.fillSuperview()
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let uid = users[indexPath.item].uid else { return }
    presentProfile(uid: uid)
  }
  
  fileprivate func presentProfile(uid: String) {
    let userProfileController = MasterProfileController(collectionViewLayout: UICollectionViewFlowLayout())
    userProfileController.userId = uid
    tabBarController?.tabBar.isHidden = true
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    navigationController?.navigationBar.tintColor = .black
    navigationController?.pushViewController(userProfileController, animated: true)
  }
}


extension ApliedMastersController: MasterProfileHeaderDelegate, ApliedMasterCellDelegate {
  
  func confirm(uid: String, cell: ApliedMasterCell) {
    guard let myUID = Auth.auth().currentUser?.uid else { return }
    guard let key = self.key else { return }
    
    self.presentConfirmAlert(masterName: cell.user?.username) { (isConfirmed) in
      if isConfirmed {
        
        let refOrder = Database.database().reference().child("orders").child(key)
        refOrder.updateChildValues(["status": "confirmed"])
        
        let confirmedRef = Database.database().reference().child("orders-confirmed").child(myUID).childByAutoId()
        let values = ["master": uid, "order": key]
        confirmedRef.updateChildValues(values) { (err, reference) in
          if err != nil {
            print(err ?? "")
            self.showAlert(with: "Произошла ошибка, попробуйте позже")
            return
          }
          //Successfully confirmed order and chosed master for it
          
          let openOrderRef = Database.database().reference().child("order-open-for-master").child(uid).child(key)
          let values = ["client": myUID, "order": key]
          openOrderRef.updateChildValues(values, withCompletionBlock: { (error, reference) in
            if error != nil {
              print(error ?? "")
              self.showAlert(with: "Произошла ошибка, попробуйте позже")
              return
            }
            
            let userOrdersRef = Database.database().reference().child("user-orders").child(myUID).child(key)
            userOrdersRef.removeValue(completionBlock: { (_, ref) in
              
              self.showAlert(with: "Вы успешно выбрали мастера, не забудьте оставить ему отзыв по окончании сделки", completion: {
                DispatchQueue.main.async {
                  let _ = self.navigationController?.popViewController(animated: true)
                  
                    self.clientOrdersController?.scrollToMenuIndex(1)
                    let indexP = IndexPath(item: 1, section: 0)
                    self.clientOrdersController?.menuBar.collectionView.selectItem(at: indexP, animated: true, scrollPosition: UICollectionViewScrollPosition())
                    guard let index = self.item else { return }
                    self.menuBarPendingCell?.orders.remove(at: index)
                    self.menuBarPendingCell?.ordersDictionary.removeValue(forKey: key)
                    let indexPath = IndexPath(item: index, section: 0)
                    self.menuBarPendingCell?.collectionView.deleteItems(at: [indexPath])
                    
                }
              })
            })
          })
        }
      }
    }
  }
  
  private func presentConfirmAlert(masterName: String?, completion: @escaping (Bool) -> ()) {
    
    let alertController = UIAlertController(title: "Вы уверенны, что хотите выбрать мастера - \(masterName ?? "")?", message: nil, preferredStyle: .alert)
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

  func showChatControllerForUser(uid: String, profileImageUrl: String) {
    let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
    chatLogController.receiverUID = uid
    chatLogController.receiverProfileImageUrl = profileImageUrl
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    navigationItem.backBarButtonItem?.tintColor = .black
    navigationController?.pushViewController(chatLogController, animated: true)
  }
  
  func didTapShowPhoneNumber(phone: String) {
    guard let number = URL(string: "tel://" + phone) else { return }
    UIApplication.shared.open(number)
  }
  
  func didTapOrders() { }
}
