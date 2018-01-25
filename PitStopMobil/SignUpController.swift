//
//  SignUpController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.08.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController, UITextFieldDelegate {
  
  var isClient: Bool?
  
  lazy var logoContainerView: UIView = {
    let view = UIView()
    
    let logoImageView = UIImageView(image: #imageLiteral(resourceName: "logo"))
    logoImageView.contentMode = .scaleAspectFill
    
    view.addSubview(logoImageView)
    logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
    logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    
    if let isClient = self.isClient {
      view.backgroundColor = isClient ? Settings.Color.blue : Settings.Color.orange
    }
    return view
  }()
  
  lazy var phoneNumberTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Пример: 734983966"
    tf.keyboardType = .numberPad
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.font = UIFont.systemFont(ofSize: 14)
    tf.delegate = self
    tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
    return tf
  }()
  
  @objc func handleTextInputChange() {
    let isFormValid = phoneNumberTextField.text?.count ?? 0 == 9
    
    guard let isClient = isClient else { return }
    
    if isFormValid {
      receiveSMSCodeButton.isEnabled = true
      receiveSMSCodeButton.backgroundColor = isClient ? Settings.Color.blue : Settings.Color.orange
    } else {
      receiveSMSCodeButton.isEnabled = false
      receiveSMSCodeButton.backgroundColor = isClient ? Settings.Color.disabledBlue : Settings.Color.disabledOrange
    }
  }

  let enterPhoneNumberLabel: UILabel = {
    let label = UILabel()
    label.text = "Введите номер телефона"
    label.textColor = .lightGray
    label.font = UIFont.systemFont(ofSize: 16)
    label.textAlignment = .center
    return label
  }()
  
  lazy var containerForFlagView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.backgroundColor = UIColor(white: 0, alpha: 0.03)
    view.layer.cornerRadius = 5
    view.layer.borderColor = UIColor.rgb(red: 202, green: 202, blue: 202).cgColor
    view.layer.borderWidth = 0.5
    
    view.addSubview(self.flagImageView)
    self.flagImageView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 24, height: 24)
    self.flagImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    
    view.addSubview(self.ukraineCodeLabel)
    self.ukraineCodeLabel.anchor(top: nil, left: self.flagImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    self.ukraineCodeLabel.centerYAnchor.constraint(equalTo: self.flagImageView.centerYAnchor).isActive = true
    
    return view
  }()
  
  let flagImageView: UIImageView = {
    let iv = UIImageView()
    iv.image = #imageLiteral(resourceName: "flag")
    iv.contentMode = .scaleAspectFill
    return iv
  }()
  
  let ukraineCodeLabel: UILabel = {
    let label = UILabel()
    label.text = "+380"
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  
  lazy var receiveSMSCodeButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Получить код", for: .normal)
    
    if let isClient = self.isClient {
      button.backgroundColor = isClient ? Settings.Color.disabledBlue : Settings.Color.disabledOrange
    }
    
    button.layer.cornerRadius = 5
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    button.setTitleColor(.white, for: .normal)
    button.addTarget(self, action: #selector(handleReceiveSMS), for: .touchUpInside)
    button.isEnabled = false
    
    return button
  }()
  
  let activityIndicatorView: UIActivityIndicatorView = {
    let aiv = UIActivityIndicatorView()
    aiv.activityIndicatorViewStyle = .white
    aiv.hidesWhenStopped = true
    return aiv
  }()
  
  @objc func handleReceiveSMS() {
    guard let phoneNumber = phoneNumberTextField.text else { return }
    let ukraineNumber = "+380" + phoneNumber
    
    receiveSMSCodeButton.setTitle("", for: .normal)
    receiveSMSCodeButton.isEnabled = false
    activityIndicatorView.startAnimating()
    
    
    PhoneAuthProvider.provider().verifyPhoneNumber(ukraineNumber, uiDelegate: nil) { (verificationID, error) in
      if let error = error {
        print(error)
        self.showMessagePrompt(error.localizedDescription)
        self.phoneNumberTextField.text = ""
        self.receiveSMSCodeButton.setTitle("Получить код", for: .normal)
        self.receiveSMSCodeButton.isEnabled = true
        self.activityIndicatorView.stopAnimating()
        return
      }
      
      print(verificationID ?? "")
      // Sign in using the verificationID and the code sent to the user
      guard let verificationId = verificationID else { return }
      
      //save auth id
      self.saveAuthVerificationId(verificationId)
      self.presentSMSVerificationController(phoneNumber: ukraineNumber)
      
      self.receiveSMSCodeButton.isEnabled = true
      self.receiveSMSCodeButton.setTitle("Получить код", for: .normal)
      self.activityIndicatorView.stopAnimating()
    }
  }
  
  fileprivate func saveAuthVerificationId(_ id: String) {
    UserDefaults.standard.set(id, forKey: "authVerificationID")
  }
  
  fileprivate func presentSMSVerificationController(phoneNumber: String) {
    let smsCodeController = SMSCodeController()
    if let isClient = isClient {
      smsCodeController.isClient = isClient
      smsCodeController.phoneNumber = phoneNumber
    }
    navigationController?.pushViewController(smsCodeController, animated: true)
  }
  
  fileprivate func showMessagePrompt(_ msg: String) {
    let alertController = UIAlertController(title: "", message: msg, preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(alertAction)
    present(alertController, animated: true, completion: nil)
  }
  
  let alreadyHaveAccountButton: UIButton = {
    let button = UIButton(type: .system)
    
    let attributedTitle = NSMutableAttributedString(string: "Вернуться к выбору ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
    
    attributedTitle.append(NSAttributedString(string: "Клиент / ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: Settings.Color.blue
      ]))
    
    attributedTitle.append(NSAttributedString(string: "Мастер", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: Settings.Color.orange
      ]))
    
    button.setAttributedTitle(attributedTitle, for: .normal)
    
    button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
    return button
  }()
  
  @objc func handleAlreadyHaveAccount() {
    _ = navigationController?.popViewController(animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    setupViews()
  }
  
  fileprivate func setupViews() {
    view.addSubview(logoContainerView)
    
    logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
    
    view.addSubview(containerForFlagView)
    containerForFlagView.anchorCenterYToSuperview()
    containerForFlagView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 40, paddingBottom: 0, paddingRight: 0, width: 80, height: 50)
    
    view.addSubview(phoneNumberTextField)
    
    phoneNumberTextField.anchorCenterYToSuperview()
    phoneNumberTextField.anchor(top: nil, left: containerForFlagView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 40, width: 0, height: 50)
    
    view.addSubview(enterPhoneNumberLabel)
    enterPhoneNumberLabel.anchor(top: nil, left: view.leftAnchor, bottom: phoneNumberTextField.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 40, paddingBottom: 12, paddingRight: 40, width: 0, height: 0)
    
    view.addSubview(receiveSMSCodeButton)
    receiveSMSCodeButton.anchor(top: phoneNumberTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 50)
    
    receiveSMSCodeButton.addSubview(activityIndicatorView)
    activityIndicatorView.anchorCenterSuperview()
    
    view.addSubview(alreadyHaveAccountButton)
    alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
  
  //MARK: STATUSBAR
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  //MARK: TextFieldDelegate
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let text = textField.text else { return true }
    let newLength = text.count + string.count - range.length
    return newLength <= 9 // Bool
  }
  
}








