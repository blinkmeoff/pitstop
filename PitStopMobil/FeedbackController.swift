//
//  FeedbackController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.12.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class FeedbackController: UIViewController {
  
  var menuBarConfirmedCell: MenuBarConfirmedCell?
  var confirmedOrder: ConfirmedOrder?
  var key: String?
  let placeholderText = "Оставьте свой комментарий о работе мастера.."
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    navigationItem.title = "Отзыв мастеру"
    setupBackButton()
    setupUI()
  }
  
  var item: Int?
  
  private func setupBackButton() {
    let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "close"), style: .plain, target: self, action: #selector(handleDismiss))
    backButton.tintColor = .black
    navigationItem.leftBarButtonItem = backButton
  }
  
  @objc private func handleDismiss() {
    dismiss(animated: true) {
      guard let index = self.item else { return }
      let indexPath = IndexPath(item: index, section: 0)
      guard let key = self.key else { return }
      self.menuBarConfirmedCell?.confirmedOrders.remove(at: index)
      self.menuBarConfirmedCell?.confirmedOrdersDictionary.removeValue(forKey: key)
      self.menuBarConfirmedCell?.collectionView.deleteItems(at: [indexPath])
    }
  }
  
  let feedbackLabel: UILabel = {
    let label = UILabel()
    label.text = "Отзыв"
    label.textColor = .black
    label.font = UIFont.boldSystemFont(ofSize: 17)
    label.textAlignment = .center
    return label
  }()
  
  let ratingLabel: UILabel = {
    let label = UILabel()
    label.text = "Оценка"
    label.textColor = .black
    label.font = UIFont.boldSystemFont(ofSize: 17)
    label.textAlignment = .center
    return label
  }()

  
  lazy var ratingControl: RatingControl = {
    let control = RatingControl()
    control.spacing = 8
    control.distribution = .fillEqually
    return control
  }()
  
  lazy var commentTextView: UITextView = {
    let tv = UITextView()
    tv.layer.cornerRadius = 3
    tv.layer.borderWidth = 0.7
    tv.layer.borderColor = UIColor(white: 0, alpha: 0.4).cgColor
    tv.delegate = self
    tv.font = UIFont.systemFont(ofSize: 14)
    tv.text = placeholderText
    tv.textColor = UIColor.lightGray
    return tv
  }()
  
  lazy var sendButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = Settings.Color.pink
    let attributedTitle = NSAttributedString(string: "ОТПРАВИТЬ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: UIColor.white])
    button.setAttributedTitle(attributedTitle, for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.addTarget(self, action: #selector(handleSendFeedback), for: .touchUpInside)
    return button
  }()
  
  @objc private func handleSendFeedback() {
    guard var comment = commentTextView.text else { return }
    if comment == placeholderText {
      comment = "Нет отзыва"
    }
    
    let rating = ratingControl.rating
    guard let masterUID = confirmedOrder?.masterUID else { return }
    guard let orderUID = confirmedOrder?.orderUID else { return }
    guard let currentLoggedInUser = Auth.auth().currentUser?.uid else { return }
    guard let key = self.key else { return }
    LoadingIndicator.shared.show()

    let ref = Database.database().reference().child("feedbacks").child(masterUID).childByAutoId()
    let values = ["client": currentLoggedInUser, "finishedDate": Date().timeIntervalSince1970, "creationDate": Date().timeIntervalSince1970,"rating": rating, "orderUID": orderUID, "comment": comment] as [String: Any]
    ref.updateChildValues(values) { (err, reference) in
      if err != nil {
        print(err ?? "")
        LoadingIndicator.shared.hide()
        self.showAlert(with: "Не удалось оставить комментарий, попробуйте позже")
        return
      }
      //Successfully send feedback
      //Now lets move order to completed node
      let orderRef = Database.database().reference().child("orders").child(orderUID)
      orderRef.updateChildValues(["status": "completed"], withCompletionBlock: { (err, ref) in
        if err != nil {
          print(err ?? "")
          LoadingIndicator.shared.hide()
          self.showAlert(with: "Не удалось отметить заявку, как завершенную")
          return
        }
        
        //successfully removed from all orders
        let confirmedOrdersRef = Database.database().reference().child("orders-confirmed").child(currentLoggedInUser).child(key)
        confirmedOrdersRef.removeValue(completionBlock: { (error, ref) in
          if error != nil {
            print(error ?? "")
            LoadingIndicator.shared.hide()
            self.showAlert(with: "Не удалось удалить заявку из подтвержденных")
            return
          }
          
          let openMasterOrder = Database.database().reference().child("order-open-for-master").child(masterUID).child(orderUID)
          openMasterOrder.removeValue(completionBlock: { (err, ref) in
            if err != nil {
              print(err ?? "")
              LoadingIndicator.shared.hide()
              self.showAlert(with: "Не удалось удалить заявку из открытых для мастера")
              return
            }
            
              LoadingIndicator.shared.hide()
              self.showAlert(with: "Спасибо за Ваш отзыв", completion: {
              self.handleDismiss()
            })
          })
        })
      }) 
    }
  }
  
  private func setupUI() {
    view.addSubview(sendButton)
    view.addSubview(ratingLabel)
    view.addSubview(ratingControl)
    view.addSubview(feedbackLabel)
    view.addSubview(commentTextView)
    
    sendButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 60)
    
    ratingLabel.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
    ratingControl.anchor(top: ratingLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 252, height: 44)
    ratingControl.anchorCenterXToSuperview()
    
    feedbackLabel.anchor(top: ratingControl.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
    commentTextView.anchor(top: feedbackLabel.bottomAnchor, left: view.leftAnchor, bottom: sendButton.topAnchor, right: view.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 12, paddingRight: 12, width: 0, height: 0)
    }
  
  lazy var containerView: UIView = {
    let containerView = UIView()
    containerView.backgroundColor = .white
    containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
    
    let submitButton = UIButton(type: .system)
    submitButton.setTitle("Готово", for: .normal)
    submitButton.setTitleColor(.black, for: .normal)
    submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    submitButton.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
    containerView.addSubview(submitButton)
    submitButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 0)
    
    let lineSeparatorView = UIView()
    lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
    containerView.addSubview(lineSeparatorView)
    lineSeparatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    
    return containerView
  }()
  
  @objc private func handleDone() {
    view.endEditing(true)
  }
  
  override var inputAccessoryView: UIView? {
    get {
      return containerView
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }

  
}


extension FeedbackController: UITextViewDelegate {
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == UIColor.lightGray {
      textView.text = nil
      textView.textColor = UIColor.black
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = placeholderText
      textView.textColor = UIColor.lightGray
    }
  }
}
