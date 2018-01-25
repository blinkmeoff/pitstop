//
//  QuoteCommentController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.01.18.
//  Copyright © 2018 com.pitStopMobil. All rights reserved.
//

import UIKit

class QuoteCommentController: UIViewController {
  
  let commentMaxLenght = 200
  var orderDetailsController: OrderDetailsController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    navigationItem.title = "Заказ"
    setupUI()
  }
  
  func clearCommentTextField() {
    commentTextView.text = nil
    commentTextView.showPlaceholderLabel()
  }
  
  let commentLabel: UILabel = {
    let label = UILabel()
    label.text = "Оставьте комментарий"
    label.font = UIFont.boldSystemFont(ofSize: 17)
    label.numberOfLines = 0
    label.textAlignment = .center
    return label
  }()
  
  lazy var commentTextView: AboutInputTextView = {
    let tv = AboutInputTextView()
    tv.layer.cornerRadius = 5
    tv.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tv.font = UIFont.systemFont(ofSize: 15)
    tv.layer.borderColor = UIColor(white: 0, alpha: 0.22).cgColor
    tv.layer.borderWidth = 0.5
    tv.delegate = self
    return tv
  }()
  
  let totalCommentLabel: UILabel = {
    let label = UILabel()
    label.text = "0 / 200"
    label.textColor = .lightGray
    label.font = UIFont.systemFont(ofSize: 13)
    return label
  }()
  
  func changeTotalLabel(textView: UITextView) {
    let totalCharactersWritten = textView.text.count
    totalCommentLabel.text = "\(totalCharactersWritten) / 200"
  }
  
  lazy var saveButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = Settings.Color.disabledPink
    
    let attributedTitle = NSAttributedString(string: "ОТПРАВИТЬ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: UIColor.white])
    button.setAttributedTitle(attributedTitle, for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.isEnabled = false
    button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
    return button
  }()
  
  @objc private func handleSave() {
    _ = navigationController?.popViewController(animated: true, completion: {
      self.orderDetailsController?.sendQuote(with: self.commentTextView.text)
    })
    
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
  
  private func setupUI() {
    view.addSubview(commentLabel)
    commentLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 100, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 0)
    
    commentTextView.placeholder = "Оставьте комментарий..."
    view.addSubview(commentTextView)
    commentTextView.anchor(top: commentLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 200)
    
    view.addSubview(totalCommentLabel)
    totalCommentLabel.anchor(top: commentTextView.bottomAnchor, left: nil, bottom: nil, right: commentTextView.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
    view.addSubview(saveButton)
    saveButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 60)
  }
  
  func isForm(valid: Bool) {
    if valid {
      enableSaveButton()
    } else {
      disableSaveButton()
    }
  }
  
  func enableSaveButton() {
    saveButton.backgroundColor = Settings.Color.pink
    saveButton.isEnabled = true
  }
  
  func disableSaveButton() {
    saveButton.backgroundColor = Settings.Color.disabledPink
    saveButton.isEnabled = false
  }
}




extension QuoteCommentController: UITextViewDelegate {
  
  func textViewDidChange(_ textView: UITextView) {
    let isValid = textView.text.count > 0
    isForm(valid: isValid)
    changeTotalLabel(textView: textView)
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
    let numberOfChars = newText.count
    return numberOfChars <= commentMaxLenght
  }
}
