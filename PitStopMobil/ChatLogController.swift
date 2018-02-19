//
//  ChatLogController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation
import LBTAComponents

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  var receiverUID: String? {
    didSet {
      navigationItem.title = "Сообщения"
      fetchUserAndSetupNavBarTitle()
      observeTestMessages()
    }
  }
  
  var receiverProfileImageUrl: String?
  
  func fetchUserAndSetupNavBarTitle() {
    guard let uid = receiverUID else {
      //for some reason uid = nil
      return
    }
    
    let ref = Database.database().reference().child("users").child(uid)
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
      guard let dictionary = snapshot.value as? [String: AnyObject] else {
        return
      }
      
      if dictionary["isClient"] as? Int == 1 {
        //client
        let user = Client(dictionary: dictionary)
        self.receiverProfileImageUrl = user.profileImageUrl
        self.setupNavBarWith(username: user.username, profileImageUrl: user.profileImageUrl)
      } else {
        //master
        let user = Master(dictionary: dictionary)
        self.receiverProfileImageUrl = user.profileImageUrl
        self.setupNavBarWith(username: user.username, profileImageUrl: user.profileImageUrl)
      }
      
    }, withCancel: nil)

  }
  
  func setupNavBarWith(username: String, profileImageUrl: String?) {
    
    let titleView = UIView()
    titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
    
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    titleView.addSubview(containerView)
    
    let profileImageView = CachedImageView()
    profileImageView.translatesAutoresizingMaskIntoConstraints = false
    profileImageView.contentMode = .scaleAspectFill
    profileImageView.layer.cornerRadius = 18
    profileImageView.clipsToBounds = true
    if let profileImageUrl = profileImageUrl {
      profileImageView.loadImage(urlString: profileImageUrl)
    }
    
    containerView.addSubview(profileImageView)
    
    profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
    profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 36).isActive = true
    
    let nameLabel = UILabel()
    nameLabel.text = username
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    nameLabel.font = UIFont.systemFont(ofSize: 15)
    
    containerView.addSubview(nameLabel)
    nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
    nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
    nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
    nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
    
    containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
    containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
    
    self.navigationItem.titleView = titleView

  }

  var messages = [Message]()
  var shouldListenToNewMessagesNow = false
  
  func observeTestMessages() {
    guard let uid = Auth.auth().currentUser?.uid, let toId = receiverUID else {
      return
    }

    let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)

    var query = userMessagesRef.queryOrderedByKey()

    if self.messages.count > 0 {
      let value = self.messages.first?.id
      query = query.queryEnding(atValue: value)
    }

    query.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { (snapshot) in
      self.listenForNewMessages()
        guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
      
        if allObjects.isEmpty {
          self.shouldListenToNewMessagesNow = true
        }
      
        allObjects.reverse()

        if self.messages.count > 0 && allObjects.count > 0 {
          allObjects.removeFirst()
        }

        var indexPaths = [IndexPath]()
        for (index, snapshot) in allObjects.enumerated() {

          let messageId = snapshot.key
          let messagesRef = Database.database().reference().child("messages").child(messageId)
          messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in

            guard let dictionary = snapshot.value as? [String: AnyObject] else {
              return
            }
            
            let indexPath = IndexPath(item: index, section: 0)
            indexPaths.append(indexPath)
            
            var message = Message(dictionary: dictionary)
            message.id = snapshot.key
            self.messages.insert(message, at: 0)
            if allObjects.count == index + 1 {
              print("WE ARE DONE")
              self.updateWith(indexPaths: indexPaths)
            }
          })
        }
      }, withCancel: nil)
  }
  
  func listenForNewMessages() {
    
    guard let uid = Auth.auth().currentUser?.uid, let toId = receiverUID else {
      return
    }
    
    let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
    userMessagesRef.observe(.childAdded, with: { (snapshot) in
      if !self.shouldListenToNewMessagesNow {
        return
      }

      let messageId = snapshot.key
      let messagesRef = Database.database().reference().child("messages").child(messageId)
      messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
        
        guard let dictionary = snapshot.value as? [String: AnyObject] else {
          return
        }
        
      
        self.messages.append(Message(dictionary: dictionary))
        DispatchQueue.main.async(execute: {
          self.collectionView?.reloadData()
          //scroll to the last index
          let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
          self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        })
        
      }, withCancel: nil)
      
    }, withCancel: nil)
  }
  
  

  func observeLastMessages() {
    loadMoreStatus = false
    guard let uid = Auth.auth().currentUser?.uid, let toId = receiverUID else {
      return
    }
    
    let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
    
    var query = userMessagesRef.queryOrderedByKey()
    
    if self.messages.count > 0 {
      let value = self.messages.first?.id
      query = query.queryEnding(atValue: value)
    }
    
    query.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { (snapshot) in
      
      guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
      allObjects.reverse()
      
      if self.messages.count > 0 && allObjects.count > 0 {
        allObjects.removeFirst()
      }
      
      var indexPaths = [IndexPath]()
      for (index, snapshot) in allObjects.enumerated() {
        
        let messageId = snapshot.key
        print(messageId)
        let messagesRef = Database.database().reference().child("messages").child(messageId)
        messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
          
          guard let dictionary = snapshot.value as? [String: AnyObject] else {
            return
          }
          let indexPath = IndexPath(item: index, section: 0)
          indexPaths.append(indexPath)
          
          var message = Message(dictionary: dictionary)
          message.id = snapshot.key
          self.messages.insert(message, at: 0)
          if allObjects.count == index + 1 {
            print("WE ARE DONE")
            self.updateWith(indexPaths: indexPaths)
            return
          }
        })
      }
    }, withCancel: nil)
  }
  
  func updateWith(indexPaths: [IndexPath], isScrollNeeded: Bool = false) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    CATransaction.setCompletionBlock {
      self.loadMoreStatus = true
      self.shouldListenToNewMessagesNow = true
    }
    
    let contentOffsetY = self.collectionView?.contentOffset.y ?? 0
    let contentSizeHeight = self.collectionView?.contentSize.height ?? 0
    let oldBottomOffset = contentSizeHeight - contentOffsetY
    
    self.collectionView?.performBatchUpdates({
      self.collectionView?.insertItems(at: indexPaths)
      
      self.collectionView?.collectionViewLayout.invalidateLayout()
    }, completion: { (completed) in
      self.collectionView?.layoutIfNeeded()
      let newHeight = self.collectionView?.contentSize.height ?? 0
      self.collectionView?.contentOffset = CGPoint(x: 0, y: newHeight - oldBottomOffset)
      CATransaction.commit()
    })
  }

  
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let y = scrollView.contentOffset.y
    print(y)
    if self.messages.count > 19 {
      if y <= 0 {
        print("Paginating for messages")
        loadMoreMessages()
      }
    }
  }
  
  var loadMoreStatus = false
  
  private func loadMoreMessages() {
    if loadMoreStatus {
      observeLastMessages()
    }
  }
  
  let cellId = "cellId"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tabBarController?.tabBar.isHidden = true
    edgesForExtendedLayout = []
    setupCollectionView()
    setupKeyboardObservers()
  }

  
  fileprivate func setupCollectionView() {
    collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    collectionView?.alwaysBounceVertical = true
    collectionView?.backgroundColor = .clear
    
    let backgroundImageView = UIImageView(image: #imageLiteral(resourceName: "chat_background"))
    collectionView?.backgroundView = backgroundImageView
    collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
    collectionView?.keyboardDismissMode = .interactive
  }
  
  lazy var inputContainerView: ChatInputContainerView = {
    let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
    chatInputContainerView.chatLogController = self
    return chatInputContainerView
  }()
  
  @objc func handleUploadTap() {
    let imagePickerController = UIImagePickerController()
    
    imagePickerController.allowsEditing = true
    imagePickerController.delegate = self
    imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
    
    present(imagePickerController, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
      //we selected a video
      handleVideoSelectedForUrl(videoUrl)
    } else {
      //we selected an image
      handleImageSelectedForInfo(info as [String : AnyObject])
    }
    
    dismiss(animated: true, completion: nil)
  }
  
  fileprivate func handleVideoSelectedForUrl(_ url: URL) {
    let filename = UUID().uuidString + ".mov"
    let uploadTask = Storage.storage().reference().child("message_movies").child(filename).putFile(from: url, metadata: nil, completion: { (metadata, error) in
      
      if error != nil {
        print("Failed upload of video:", error!)
        return
      }
      
      if let videoUrl = metadata?.downloadURL()?.absoluteString {
        if let thumbnailImage = self.thumbnailImageForFileUrl(url) {
          
          self.uploadToFirebaseStorageUsingImage(thumbnailImage, completion: { (imageUrl) in
            let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": thumbnailImage.size.width as AnyObject, "imageHeight": thumbnailImage.size.height as AnyObject, "videoUrl": videoUrl as AnyObject]
            self.sendMessageWithProperties(properties)
            
          })
        }
      }
    })
    
    uploadTask.observe(.progress) { (snapshot) in
      
        guard let fractionCompleted = snapshot.progress?.fractionCompleted else { return }
        let percent = Int(fractionCompleted * 100)
        self.navigationItem.title = "Загруженно \(percent)%"
      
    }
    
    uploadTask.observe(.success) { (snapshot) in
      self.navigationItem.title = "Сообщения"
    }
  }
  
  fileprivate func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
    let asset = AVAsset(url: fileUrl)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    
    do {
      
      let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
      return UIImage(cgImage: thumbnailCGImage)
      
    } catch let err {
      print(err)
    }
    
    return nil
  }
  
  fileprivate func handleImageSelectedForInfo(_ info: [String: AnyObject]) {
    var selectedImageFromPicker: UIImage?
    
    if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
      selectedImageFromPicker = editedImage
    } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
      
      selectedImageFromPicker = originalImage
    }
    
    if let selectedImage = selectedImageFromPicker {
      uploadToFirebaseStorageUsingImage(selectedImage, completion: { (imageUrl) in
        self.sendMessageWithImageUrl(imageUrl, image: selectedImage)
      })
    }
  }
  
  fileprivate func uploadToFirebaseStorageUsingImage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
    let imageName = UUID().uuidString
    let ref = Storage.storage().reference().child("message_images").child(imageName)
    
    if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
      ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
        
        if error != nil {
          print("Failed to upload image:", error!)
          return
        }
        
        if let imageUrl = metadata?.downloadURL()?.absoluteString {
          completion(imageUrl)
        }
        
      })
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
  override var inputAccessoryView: UIView? {
    get {
      return inputContainerView
    }
  }
  
  override var canBecomeFirstResponder : Bool {
    return true
  }
  
  func setupKeyboardObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
  }
  
  @objc func handleKeyboardDidShow() {
    if messages.count > 0 {
      let indexPath = IndexPath(item: messages.count - 1, section: 0)
      if indexPathIsValid(indexPath: indexPath) {
          collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
      }
    }
  }
  
  func indexPathIsValid(indexPath: IndexPath) -> Bool {
    
    guard let items = collectionView?.numberOfItems(inSection: 0) else { return false }
    if indexPath.item >= items {
      return false
    }
    return true
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    NotificationCenter.default.removeObserver(self)
  }
  
  func handleKeyboardWillShow(_ notification: Notification) {
    let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
    let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
    
    containerViewBottomAnchor?.constant = -keyboardFrame!.height
    UIView.animate(withDuration: keyboardDuration!, animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  func handleKeyboardWillHide(_ notification: Notification) {
    let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
    
    containerViewBottomAnchor?.constant = 0
    UIView.animate(withDuration: keyboardDuration!, animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return messages.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
    
    
    
    cell.chatLogController = self
    
    let message = messages[indexPath.item]
    
    cell.message = message
    
    cell.textView.text = message.text
    
    setupCell(cell, message: message)
    
    if let text = message.text {
      //a text message
      cell.bubbleWidthAnchor?.constant = estimateFrameForText(text).width + 32
      cell.textView.isHidden = false
    } else if message.imageUrl != nil {
      //fall in here if its an image message
      cell.bubbleWidthAnchor?.constant = 200
      cell.textView.isHidden = true
    }
    
    cell.playButton.isHidden = message.videoUrl == nil
    
    return cell
  }
  
  fileprivate func setupCell(_ cell: ChatMessageCell, message: Message) {
    if let profileImageUrl = self.receiverProfileImageUrl {
      cell.profileImageView.loadImage(urlString: profileImageUrl, completion: nil)
    }
    
    if message.fromId == Auth.auth().currentUser?.uid {
      //outgoing blue
      cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
      cell.textView.textColor = UIColor.white
      cell.profileImageView.isHidden = true
      
      cell.bubbleViewRightAnchor?.isActive = true
      cell.bubbleViewLeftAnchor?.isActive = false
      cell.dateLabelRightAnchor?.isActive = true
//      cell.dateLabelLeftAnchor?.isActive = false
      
    } else {
      //incoming gray
      cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
      cell.textView.textColor = UIColor.black
      cell.profileImageView.isHidden = false
      
      cell.bubbleViewRightAnchor?.isActive = false
      cell.bubbleViewLeftAnchor?.isActive = true
      cell.dateLabelRightAnchor?.isActive = true
//      cell.dateLabelLeftAnchor?.isActive = true
    }
    
    if let messageImageUrl = message.imageUrl {
      cell.activityIndicatorView.startAnimating()
      cell.messageImageView.loadImage(urlString: messageImageUrl, completion: { 
        cell.activityIndicatorView.stopAnimating()
      })
      
      cell.messageImageView.isHidden = false
      cell.bubbleView.backgroundColor = UIColor.clear
    } else {
      cell.messageImageView.isHidden = true
    }
    
    guard let timestamp = message.timestamp else { return }
    let messageDate = Date(timeIntervalSince1970: Double(timestamp))
    cell.dateLabel.text = messageDate.dateForMessage("dd MMM HH:mm")
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    collectionView?.collectionViewLayout.invalidateLayout()
  }
  
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    var height: CGFloat = 80
    
    let message = messages[indexPath.item]
    if let text = message.text {
      height = estimateFrameForText(text).height + 20
    } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
      
      // h1 / w1 = h2 / w2
      // solve for h1
      // h1 = h2 / w2 * w1
      
      height = CGFloat(imageHeight / imageWidth * 200)
    
    }
    
    let width = UIScreen.main.bounds.width
    return CGSize(width: width, height: height + 12)
  }
  
  fileprivate func estimateFrameForText(_ text: String) -> CGRect {
//    let size = CGSize(width: 200, height: 1000)
    let size = CGSize(width: 200, height: CGFloat.infinity)
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
  }
  
  var containerViewBottomAnchor: NSLayoutConstraint?
  
  @objc func handleSend() {
    guard let message = inputContainerView.inputTextField.text else { return }
    let properties = ["text": message]
    sendMessageWithProperties(properties as [String : AnyObject])
  }
  
  fileprivate func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {
    let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
    sendMessageWithProperties(properties)
  }
  
  fileprivate func sendMessageWithProperties(_ properties: [String: AnyObject]) {
    let ref = Database.database().reference().child("messages")
    let childRef = ref.childByAutoId()
    guard let toId = receiverUID else { return }
    guard let fromId = Auth.auth().currentUser?.uid else { return }
    let timestamp = Int(Date().timeIntervalSince1970)
    
    var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject]
    
    //append properties dictionary onto values somehow??
    //key $0, value $1
    properties.forEach({values[$0] = $1})
    
    childRef.updateChildValues(values) { (error, ref) in
      if error != nil {
        print(error!)
        return
      }
      
      self.inputContainerView.inputTextField.text = nil
      self.inputContainerView.sendButton.isEnabled = false
      
      let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
      
      let messageId = childRef.key
      userMessagesRef.updateChildValues([messageId: 1])
      
      let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
      recipientUserMessagesRef.updateChildValues([messageId: 1])
    }
  }
  
  var startingFrame: CGRect?
  var blackBackgroundView: UIView?
  var startingImageView: UIImageView?
  
  //my custom zooming logic
  func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
    inputContainerView.inputTextField.resignFirstResponder()

    self.startingImageView = startingImageView
    self.startingImageView?.isHidden = true
    
    startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
    
    let zoomingImageView = UIImageView(frame: startingFrame!)
    zoomingImageView.image = startingImageView.image
    zoomingImageView.isUserInteractionEnabled = true
    zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
    
    if let keyWindow = UIApplication.shared.keyWindow {
      blackBackgroundView = UIView(frame: keyWindow.frame)
      blackBackgroundView?.backgroundColor = UIColor.black
      blackBackgroundView?.alpha = 0
      keyWindow.addSubview(blackBackgroundView!)
      
      keyWindow.addSubview(zoomingImageView)
      
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        
        self.blackBackgroundView?.alpha = 1
        self.inputContainerView.alpha = 0
        
        // math?
        // h2 / w1 = h1 / w1
        // h2 = h1 / w1 * w1
        let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
        
        zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
        
        zoomingImageView.center = keyWindow.center
        
      }, completion: { (completed) in
        //                    do nothing
      })
      
    }
  }
  
  @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
    if let zoomOutImageView = tapGesture.view {
      //need to animate back out to controller
      zoomOutImageView.layer.cornerRadius = 16
      zoomOutImageView.clipsToBounds = true
      
      UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        
        zoomOutImageView.frame = self.startingFrame!
        self.blackBackgroundView?.alpha = 0
        self.inputContainerView.alpha = 1
        
      }, completion: { (completed) in
        zoomOutImageView.removeFromSuperview()
        self.startingImageView?.isHidden = false
      })
    }
  }
  
  
  @objc func handleTextInputChange(textField: UITextField) {
    
      let isFormValid = textField.text?.count ?? 0 > 0
      
      if isFormValid {
        inputContainerView.sendButton.isEnabled = true
        inputContainerView.sendButton.setTitleColor(.black, for: .normal)
      } else {
        inputContainerView.sendButton.isEnabled = false
        inputContainerView.sendButton.setTitleColor(.lightGray, for: .normal)
      }
  }
  
}


