//
//  MessagesController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  let cellId = "cellId"
  let footerId = "footerId"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Сообщения"
    
    setupCollectionView()
    observeUserMessages()
    observeTyping()
  }
  
  fileprivate func observeTyping() {
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = false
  }
  
  lazy var refreshControl: UIRefreshControl = {
    let rf = UIRefreshControl()
    rf.tintColor = UIColor(r: 243, g: 72, b: 96)
    rf.addTarget(self, action: #selector(handleRefreshMessages), for: .valueChanged)
    return rf
  }()
  
  fileprivate func setupCollectionView() {
    collectionView?.backgroundColor = .white
    collectionView?.register(MessagesCell.self, forCellWithReuseIdentifier: cellId)
    collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerId)
    collectionView?.refreshControl = refreshControl
  }
  
  @objc func handleRefreshMessages() {
    messages.removeAll()
    messagesDictionary.removeAll()
//    collectionView?.reloadData()
    observeUserMessages()
  }
  
  var messages = [Message]()
  var messagesDictionary = [String: Message]()
  
  func observeUserMessages() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    let ref = Database.database().reference().child("user-messages").child(uid)
    ref.observe(.childAdded, with: { (snapshot) in
      
      let userId = snapshot.key
      Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
        
        let messageId = snapshot.key
        self.fetchMessageWithMessageId(messageId)
        
      }, withCancel: nil)
      
    }, withCancel: nil)
  }
  
  fileprivate func fetchMessageWithMessageId(_ messageId: String) {
    let messagesReference = Database.database().reference().child("messages").child(messageId)
    
    messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
      
      if let dictionary = snapshot.value as? [String: AnyObject] {
        let message = Message(dictionary: dictionary)
        
        if let chatPartnerId = message.chatPartnerId() {
          self.messagesDictionary[chatPartnerId] = message
        }
        
        self.attemptReloadOfTable()
      }
      
    }, withCancel: nil)
  }
  
  fileprivate func attemptReloadOfTable() {
    self.timer?.invalidate()
    
    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
  }
  
  var timer: Timer?
  
  @objc func handleReloadTable() {
    self.messages = Array(self.messagesDictionary.values)
    self.messages.sort(by: { (message1, message2) -> Bool in
      
      guard let timestamp1 = message1.timestamp else { return false }
      guard let timestamp2 = message2.timestamp else { return false }
      return timestamp1 > timestamp2
    })
    
    //this will crash because of background thread, so lets call this on dispatch_async main thread
    DispatchQueue.main.async(execute: {
      self.refreshControl.endRefreshing()
      self.collectionView?.reloadData()
    })
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessagesCell
    
    cell.message = messages[indexPath.item]
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return messages.count
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 77)
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let message = messages[indexPath.row]
    
    guard let chatPartnerId = message.chatPartnerId() else {
      return
    }
    
    let ref = Database.database().reference().child("users").child(chatPartnerId)
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
      guard let dictionary = snapshot.value as? [String: AnyObject] else {
        return
      }
      
      if dictionary["isClient"] as? Int == 1 {
        //client
        let user = Client(dictionary: dictionary)
        self.presentChatLogFor(uid: chatPartnerId, profileImageUrl: user.profileImageUrl)
      } else {
        //master
        let user = Master(dictionary: dictionary)
        self.presentChatLogFor(uid: chatPartnerId, profileImageUrl: user.profileImageUrl)
      }
      
    }, withCancel: nil)
    
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return messages.isEmpty ? CGSize(width: view.frame.width, height: collectionView.frame.height - 60 - 40) : .zero
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerId, for: indexPath)
    
    setupFooterCell(cell: footer)

    return footer
  }
  
  private func setupFooterCell(cell: UICollectionReusableView) {
    let noMessagesLabel = UILabel()
    noMessagesLabel.text = "Нет сообщений"
    noMessagesLabel.textColor = .lightGray
    noMessagesLabel.textAlignment = .center
    noMessagesLabel.font = UIFont.systemFont(ofSize: 17)
    cell.addSubview(noMessagesLabel)
    noMessagesLabel.fillSuperview()
  }
  
  fileprivate func presentChatLogFor(uid: String, profileImageUrl: String) {
    let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
    chatLogController.receiverUID = uid
    chatLogController.receiverProfileImageUrl = profileImageUrl
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    navigationController?.navigationBar.tintColor = .black
    navigationController?.pushViewController(chatLogController, animated: true)
  }
  
  
  
}
