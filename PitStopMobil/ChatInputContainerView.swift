//
//  ChatInputContainerView.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView, UITextFieldDelegate {
  
  weak var chatLogController: ChatLogController? {
    didSet {
      sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleSend), for: .touchUpInside)
      uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUploadTap)))
      inputTextField.addTarget(chatLogController, action: #selector(ChatLogController.handleTextInputChange), for: .editingChanged)
    }
  }
  
  lazy var inputTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    let attrPlaceholder = NSAttributedString(string: "Напишите сообщение", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
    textField.attributedPlaceholder = attrPlaceholder
    textField.returnKeyType = .done
    textField.delegate = self
    return textField
  }()
  
  
  let uploadImageView: UIImageView = {
    let uploadImageView = UIImageView()
    uploadImageView.isUserInteractionEnabled = true
    uploadImageView.image = UIImage(named: "upload_image_icon")
    uploadImageView.translatesAutoresizingMaskIntoConstraints = false
    return uploadImageView
  }()
  
  let sendButton = UIButton(type: .system)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .white
    
    addSubview(uploadImageView)
    //x,y,w,h
    uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
    uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
    
    sendButton.setTitle("Отправить", for: .normal)
    sendButton.setTitleColor(.lightGray, for: .normal)
    sendButton.translatesAutoresizingMaskIntoConstraints = false
    sendButton.isEnabled = false

    //what is handleSend?
    
    addSubview(sendButton)
    //x,y,w,h
    sendButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
    sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
    sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    
    addSubview(self.inputTextField)
    //x,y,w,h
    self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
    self.inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
    self.inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    
    let separatorLineView = UIView()
    separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
    separatorLineView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(separatorLineView)
    //x,y,w,h
    separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    inputTextField.resignFirstResponder()
    return true
  }
  
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
