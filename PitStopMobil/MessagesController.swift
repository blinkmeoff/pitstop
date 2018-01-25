//
//  MessagesController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
  
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
  
  
  fileprivate func setupCollectionView() {
    tableView.backgroundColor = .white
    tableView.register(MessagesCell.self, forCellReuseIdentifier: cellId)
    tableView.tableFooterView = UIView()
    tableView.refreshControl = refreshControl
  }
  
  @objc func handleRefreshMessages() {
    messages.removeAll()
    messagesDictionary.removeAll()
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
    
    ref.observe(.childRemoved, with: { (snapshot) in
      print(snapshot.key)
      print(self.messagesDictionary)
      
      self.messagesDictionary.removeValue(forKey: snapshot.key)
      self.attemptReloadOfTable()
      
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
      self.refreshControl?.endRefreshing()
      self.tableView.reloadData()
    })
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessagesCell
    cell.message = messages[indexPath.item]
    cell.selectionStyle = .none
    return cell
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 78
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let message = messages[indexPath.row]
    
    guard let chatPartnerId = message.chatPartnerId() else {
      return
    }
    self.presentChatLogFor(uid: chatPartnerId, profileImageUrl: message.imageUrl ?? "")
  }
  
  
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
    removeMessageDialog(for: indexPath.row)
  }
  
  func removeMessageDialog(for row: Int) {
    guard let uid = Auth.auth().currentUser?.uid else {
      return
    }
    
    let message = self.messages[row]
    
    if let chatPartnerId = message.chatPartnerId() {
      Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
        
        if error != nil {
          print("Failed to delete message:", error ?? "")
          return
        }
        
        self.messagesDictionary.removeValue(forKey: chatPartnerId)
      })
    }
  }
  
  @available(iOS 11.0, *)
  override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let action = UIContextualAction(style: .normal, title: "Удалить") { (action, view, completionHandler) in
      self.removeMessageDialog(for: indexPath.row)
      completionHandler(true)
    }
    
    action.image = #imageLiteral(resourceName: "remove")
    action.backgroundColor = Settings.Color.pink
    action.title = "Удалить"
    let configuration = UISwipeActionsConfiguration(actions: [action])
    return configuration
  }
  
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return messages.isEmpty ? view.frame.height - 120 : 0
  }
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return setupFooterView()
  }
  
  private func setupFooterView() -> UIView {
    let view = UIView()
    view.backgroundColor = .white
    
    let noMessagesLabel = UILabel()
    noMessagesLabel.text = "Нет сообщений"
    noMessagesLabel.textColor = .lightGray
    noMessagesLabel.textAlignment = .center
    noMessagesLabel.font = UIFont.systemFont(ofSize: 17)
    
    view.addSubview(noMessagesLabel)
    noMessagesLabel.fillSuperview()
    return view
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
