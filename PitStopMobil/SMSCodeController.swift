//
//  SMSCodeController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class SMSCodeController: UIViewController, UITextFieldDelegate  {
  
  var isClient: Bool?
  var phoneNumber: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white

    setupViews()
    setSMSCodeLabelText()
  }
  
  func setSMSCodeLabelText() {
    guard let phoneNumber = phoneNumber else { return }
    enterSMSCodeLabel.text = "Мы выслали Вам SMS с кодом подтверждения, на номер \(phoneNumber)"
  }
  
  override func viewWillAppear(_ animated: Bool) {
    firstDigitTextField.becomeFirstResponder()
  }
  
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
    } else {
      view.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175)
    }
    return view
  }()
  
  lazy var firstDigitTextField: UITextField = {
    let tf = UITextField()
    tf.setBottomBorder(withColor: .lightGray)
    tf.textAlignment = .center
    tf.font = UIFont.boldSystemFont(ofSize: 23)
    tf.textColor = .black
    tf.attributedPlaceholder = NSAttributedString(string: "•", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 23)])
    tf.keyboardType = .numberPad
    tf.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    tf.delegate = self
    return tf
  }()
  
  lazy var secondDigitTextField: UITextField = {
    let tf = UITextField()
    tf.setBottomBorder(withColor: .lightGray)
    tf.textAlignment = .center
    tf.font = UIFont.boldSystemFont(ofSize: 23)
    tf.keyboardType = .numberPad
    tf.attributedPlaceholder = NSAttributedString(string: "•", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 23)])
    tf.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    tf.delegate = self
    return tf
  }()
  
  lazy var thirdDigitTextField: UITextField = {
    let tf = UITextField()
    tf.setBottomBorder(withColor: .lightGray)
    tf.textAlignment = .center
    tf.font = UIFont.boldSystemFont(ofSize: 23)
    tf.keyboardType = .numberPad
    tf.attributedPlaceholder = NSAttributedString(string: "•", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 23)])
    tf.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    tf.delegate = self
    return tf
  }()
  
  lazy var fourthDigitTextField: UITextField = {
    let tf = UITextField()
    tf.setBottomBorder(withColor: .lightGray)
    tf.textAlignment = .center
    tf.font = UIFont.boldSystemFont(ofSize: 23)
    tf.keyboardType = .numberPad
    tf.attributedPlaceholder = NSAttributedString(string: "•", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 23)])
    tf.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    tf.delegate = self
    return tf
  }()
  
  lazy var fifthDigitTextField: UITextField = {
    let tf = UITextField()
    tf.setBottomBorder(withColor: .lightGray)
    tf.textAlignment = .center
    tf.font = UIFont.boldSystemFont(ofSize: 23)
    tf.keyboardType = .numberPad
    tf.attributedPlaceholder = NSAttributedString(string: "•", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 23)])
    tf.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    tf.delegate = self
    return tf
  }()
  
  lazy var sixthDigitTextField: UITextField = {
    let tf = UITextField()
    tf.setBottomBorder(withColor: .lightGray)
    tf.textAlignment = .center
    tf.font = UIFont.boldSystemFont(ofSize: 23)
    tf.keyboardType = .numberPad
    tf.attributedPlaceholder = NSAttributedString(string: "•", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 23)])
    tf.delegate = self
    tf.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    return tf
  }()
  
  lazy var checkCodeButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Отправить", for: .normal)
    
    if let isClient = self.isClient {
      button.backgroundColor = isClient ? UIColor.rgb(red: 149, green: 204, blue: 244) : UIColor.rgb(red: 255, green: 194, blue: 149)
    }
    
    button.layer.cornerRadius = 5
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    button.setTitleColor(.white, for: .normal)
    button.addTarget(self, action: #selector(checkSMSCode), for: .touchUpInside)
    button.isEnabled = false
    
    return button
  }()
  
  @objc func checkSMSCode() {
    guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else { return }
    guard let firstDigit = firstDigitTextField.text else { return }
    guard let secondDigit = secondDigitTextField.text else { return }
    guard let thirdDigit = thirdDigitTextField.text else { return }
    guard let fourthDigit = fourthDigitTextField.text else { return }
    guard let fifthDigit = fifthDigitTextField.text else { return }
    guard let sixthDigit = sixthDigitTextField.text else { return }
    
    let verificationCode = firstDigit + secondDigit + thirdDigit + fourthDigit + fifthDigit + sixthDigit
    
    let credential = PhoneAuthProvider.provider().credential(
      withVerificationID: verificationID,
      verificationCode: verificationCode)
    
    checkCodeButton.setTitle("", for: .normal)
    activityIndicatorView.startAnimating()
    
    Auth.auth().signIn(with: credential) { (user, error) in
      if error != nil {
        print(error?.localizedDescription ?? "")
        self.checkCodeButton.setTitle("Отправить", for: .normal)
        self.activityIndicatorView.stopAnimating()
        self.enterSMSCodeLabel.text = "Вы ввели неправильный код, попробуйте еще раз"
        self.enterSMSCodeLabel.textColor = .red
        return
      }
      
      guard let uid = user?.uid else { return }
      
      let ref = Database.database().reference().child("users").child(uid)
      ref.observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.exists() {
          print("THIS NUMBER IS ALREADY EXISTS")
          self.view.endEditing(true)
          self.handleSignInExistingUser()
        } else {
          if let phoneNumber = self.phoneNumber {
            self.presentClientOrMasterRegistrationProccess(phoneNumber: phoneNumber)
          }
        }
      })
    }
  }
  
  fileprivate func handleSignInExistingUser() {
    
    if let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController {
      guard let mainTab = mainTabBarController.childViewControllers.first as? MainTabBarController else { return }
      mainTab.selectedIndex = 0

      mainTab.setupViewControllers(completed: { (isCompleted) in
        DispatchQueue.main.async {
          if isCompleted {
            self.dismiss(animated: true, completion: nil)
          } else {
            UIAlertController().showMessagePrompt("Что-то пошло не так, попробуйте позже.")
          }
        }
      })
    }
  }
  
  fileprivate func presentClientOrMasterRegistrationProccess(phoneNumber: String) {
    guard let isClient = isClient else { return }

    if isClient {
      if let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController {
        mainTabBarController.selectedIndex = 0
      }
      let clientDetailsController = ClientDetailsController()
      clientDetailsController.phoneNumber = phoneNumber
      navigationController?.pushViewController(clientDetailsController, animated: true)
    } else {
      let masterDetailsController = MasterDetailsController()
      masterDetailsController.phoneNumber = phoneNumber
      navigationController?.pushViewController(masterDetailsController, animated: true)
    }
  }
  
  lazy var enterSMSCodeLabel: UILabel = {
    let label = UILabel()
    label.textColor = .lightGray
    label.font = UIFont.systemFont(ofSize: 16)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  let activityIndicatorView: UIActivityIndicatorView = {
    let aiv = UIActivityIndicatorView()
    aiv.activityIndicatorViewStyle = .white
    aiv.hidesWhenStopped = true
    return aiv
  }()
  
  lazy var incorectNumberButton: UIButton = {
    let button = UIButton(type: .system)
    
    let attributedTitle = NSMutableAttributedString(string: "Ввели неправильный номер? ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
    
    if let isClient = self.isClient {
      if isClient {
        attributedTitle.append(NSAttributedString(string: "Вернуться", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237)
          ]))
      } else {
        attributedTitle.append(NSAttributedString(string: "Вернуться", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 255, green: 135, blue: 47)
          ]))
      }
    }
    
    button.setAttributedTitle(attributedTitle, for: .normal)
    
    button.addTarget(self, action: #selector(enteredIncorectNumber), for: .touchUpInside)
    return button
  }()
  
  @objc func enteredIncorectNumber() {
    _ = navigationController?.popViewController(animated: true)
  }
  
  fileprivate func setupViews() {
    view.addSubview(logoContainerView)
    
    logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil
      , right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
    
    setupInputFields()
    
    view.addSubview(checkCodeButton)
    checkCodeButton.anchor(top: firstDigitTextField.bottomAnchor, left: firstDigitTextField.leftAnchor, bottom: nil, right: sixthDigitTextField.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    
    checkCodeButton.addSubview(activityIndicatorView)
    activityIndicatorView.anchorCenterSuperview()
    
    view.addSubview(enterSMSCodeLabel)
    enterSMSCodeLabel.anchor(top: nil, left: firstDigitTextField.leftAnchor, bottom: firstDigitTextField.topAnchor, right: sixthDigitTextField.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 0, height: 0)
    
    view.addSubview(incorectNumberButton)
    incorectNumberButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
  }
  
  fileprivate func setupInputFields() {
    let stackView = UIStackView(arrangedSubviews: [firstDigitTextField, secondDigitTextField, thirdDigitTextField, fourthDigitTextField, fifthDigitTextField, sixthDigitTextField])
    
    stackView.axis = .horizontal
    stackView.spacing = 10
    stackView.distribution = .fillEqually
    
    view.addSubview(stackView)
    stackView.anchorCenterSuperview()
    stackView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: view.frame.width - 80, height: 50)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
  
  
  //MARK: TextField Delegate and Observers
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let text = textField.text else { return true }
    let newLength = text.count + string.count - range.length
   
    return newLength <= 1 // Bool
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    
    guard let text = textField.text else { return }
    
    if text.count >= 1 {
      switch textField {
      case firstDigitTextField:
        secondDigitTextField.becomeFirstResponder()
      case secondDigitTextField:
        thirdDigitTextField.becomeFirstResponder()
      case thirdDigitTextField:
        fourthDigitTextField.becomeFirstResponder()
      case fourthDigitTextField:
        fifthDigitTextField.becomeFirstResponder()
      case fifthDigitTextField:
        sixthDigitTextField.becomeFirstResponder()
      default:
        break
      }
      guard let isClient = isClient else { return }

      if isClient {
        textField.setBottomBorder(withColor: Settings.Color.blue)
      } else {
        textField.setBottomBorder(withColor: Settings.Color.orange)
      }
      
    } else {
      textField.setBottomBorder(withColor: .lightGray)
    }
    
    handleTextInputChange()
  }
  
  func handleTextInputChange() {
    let isFormValid = firstDigitTextField.text?.count ?? 0 == 1 && secondDigitTextField.text?.count ?? 0 == 1 && thirdDigitTextField.text?.count ?? 0 == 1 && fourthDigitTextField.text?.count ?? 0 == 1 && fifthDigitTextField.text?.count ?? 0 == 1 && sixthDigitTextField.text?.count ?? 0 == 1
    
    guard let isClient = isClient else { return }
    
    if isFormValid {
      checkCodeButton.isEnabled = true
      checkCodeButton.backgroundColor = isClient ? Settings.Color.blue : Settings.Color.orange
    } else {
      checkCodeButton.isEnabled = false
      checkCodeButton.backgroundColor = isClient ? Settings.Color.disabledBlue : Settings.Color.disabledOrange
    }
  }

  
}
