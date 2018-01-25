//
//  MasterDetailsController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class MasterDetailsController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
  
  var phoneNumber: String?
  
  var latitude: Double?
  var longitude: Double?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    setupViews()
    setupInputFields()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    cityTextField.isEnabled = true
    addressTextField.isEnabled = true
  }
  
  let plusPhotoButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysTemplate), for: .normal)
    button.tintColor = UIColor.rgb(red: 255, green: 135, blue: 47)
    button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
    return button
  }()
  
  @objc func handlePlusPhoto() {
    showMediaOptions()
  }
  
  func showMediaOptions() {
    
    let mediaOptions = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    let cameraOption = UIAlertAction(title: "Сделать фото", style: .default) { (action) in
      self.openCamera()
    }
    
    let galleryOption = UIAlertAction(title: "Выбрать из галереи", style: .default) { (action) in
      self.openPhotos()
    }
    
    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: .none)
    
    mediaOptions.addAction(cameraOption)
    mediaOptions.addAction(galleryOption)
    mediaOptions.addAction(cancelAction)
    
    self.present(mediaOptions, animated: true, completion: .none)
  }
  
  func openCamera() {
    let imagePicker = UIImagePickerController()
    imagePicker.allowsEditing = true
    imagePicker.sourceType = .camera
    imagePicker.delegate = self
    
    self.present(imagePicker, animated: true, completion: .none)
  }
  
  func openPhotos() {
    let imagePicker = UIImagePickerController()
    imagePicker.allowsEditing = true
    imagePicker.sourceType = .photoLibrary
    imagePicker.delegate = self
    
    self.present(imagePicker, animated: true, completion: .none)
  }
  
  var isImageChoosen = false
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    var imagePicked: UIImage?
    
    if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
      imagePicked = editedImage
    } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
      imagePicked = originalImage
    }
    
    if let image = imagePicked {
      isImageChoosen = true
      plusPhotoButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
      plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
      plusPhotoButton.layer.masksToBounds = true
      plusPhotoButton.layer.borderColor = UIColor.black.cgColor
      plusPhotoButton.layer.borderWidth = 3
    }
    
    dismiss(animated: true, completion: nil)
  }
  
  let nameTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Имя"
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.font = UIFont.systemFont(ofSize: 14)
    
    tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
    
    return tf
  }()
  
  @objc func handleTextInputChange() {
    let isFormValid = nameTextField.text?.count ?? 0 > 0 && addressTextField.text?.count ?? 0 > 0 && cityTextField.text?.count ?? 0 > 0
    
    if isFormValid {
      signUpButton.isEnabled = true
      signUpButton.backgroundColor = Settings.Color.orange
    } else {
      signUpButton.isEnabled = false
      signUpButton.backgroundColor = Settings.Color.disabledOrange
    }
  }
  
  lazy var addressTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Адрес"
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.font = UIFont.systemFont(ofSize: 14)
    tf.delegate = self
    tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
    return tf
  }()
  
  lazy var cityTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Область"
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.font = UIFont.systemFont(ofSize: 14)
    tf.delegate = self
    tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
    return tf
  }()
  
  let activityIndicatorView: UIActivityIndicatorView = {
    let aiv = UIActivityIndicatorView()
    aiv.activityIndicatorViewStyle = .white
    aiv.hidesWhenStopped = true
    return aiv
  }()
  
  let signUpButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Зарегистрироваться", for: .normal)
    button.backgroundColor = UIColor.rgb(red: 255, green: 194, blue: 149)
    
    button.layer.cornerRadius = 5
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    button.setTitleColor(.white, for: .normal)
    
    button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
    
    return button
  }()
  
  fileprivate func showMessagePrompt(_ msg: String) {
    let alertController = UIAlertController(title: "", message: msg, preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(alertAction)
    present(alertController, animated: true, completion: nil)
  }
  
  @objc func handleSignUp() {
    
    if !isImageChoosen {
      self.showAlert(with: "Пожалуйста, выберите фото профиля")
      return
    }
    
    guard let username = nameTextField.text, username.count > 0 else { return }
    guard let city = cityTextField.text, city.count > 0 else { return }
    guard let address = addressTextField.text, address.count > 0 else { return }
    guard let phoneNumber = phoneNumber else { return }
    guard let latitude = latitude else { return }
    guard let longitude = longitude else { return }
    
    guard let image = self.plusPhotoButton.imageView?.image else { return }
    guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else { return }
    let filename = NSUUID().uuidString
    
    signUpButton.setTitle("", for: .normal)
    signUpButton.isEnabled = false
    activityIndicatorView.startAnimating()
    
    guard let uid = Auth.auth().currentUser?.uid else { return }
    guard let fcmToken = Messaging.messaging().fcmToken else { return }

    var dictionaryValues = ["phoneNumber": phoneNumber, "username": username, "city": city, "address": address, "isClient": 0, "latitude": latitude, "longitude": longitude, "profileImageUrl": "", "fcmToken": fcmToken] as [String : Any]
    
    if isImageChoosen {
      Storage.storage().reference().child("profile_images").child(filename).putData(uploadData, metadata: nil) { (metadata, err) in
        if let err = err {
          print("Failed to upload profile image:", err)
          self.signUpButton.isEnabled = true
          return
        }
        
        guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { return }
        
        print("Successfully uploaded profile image:", profileImageUrl)
        
        
        dictionaryValues["profileImageUrl"] = profileImageUrl
        let values = [uid: dictionaryValues]

        self.saveUserToDatabase(with: values)
        
      }
    } else {
      let values = [uid: dictionaryValues]
      self.saveUserToDatabase(with: values)
    }
    
  }
  
  fileprivate func saveUserToDatabase(with values: [String: [String: Any]]) {
    Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
      
      if let err = err {
        print("Failed to save user info into db:", err)
        self.signUpButton.isEnabled = true
        return
      }
      
      print("Successfully saved user info to db")
      self.dismissSignUpController()
    })
  }
  
  fileprivate func dismissSignUpController() {
    if let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController {
      guard let mainTab = mainTabBarController.childViewControllers.first as? MainTabBarController else { return }
      mainTab.setupViewControllers(completed: { (isCompleted) in
        DispatchQueue.main.async {
          if isCompleted {
            self.dismiss(animated: true, completion: nil)
            mainTab.selectedIndex = 2
          } else {
            UIAlertController().showMessagePrompt("Что-то пошло не так, попробуйте позже.")
          }
        }
      })
    }
  }
  
  let alreadyHaveAccountButton: UIButton = {
    let button = UIButton(type: .system)
    
    let attributedTitle = NSMutableAttributedString(string: "Уже есть аккаунт? ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
    
    attributedTitle.append(NSAttributedString(string: "Войти", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 255, green: 135, blue: 47)
      ]))
    
    button.setAttributedTitle(attributedTitle, for: .normal)
    
    button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
    return button
  }()
  
  @objc func handleAlreadyHaveAccount() {
    let loginController = LoginController()
    navigationController?.pushViewController(loginController, animated: true)
  }
  
  
  
  fileprivate func setupViews() {
    view.addSubview(alreadyHaveAccountButton)
    alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    
    
    view.addSubview(plusPhotoButton)
    
    plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
    
    plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
  }
  
  fileprivate func setupInputFields() {
    let stackView = UIStackView(arrangedSubviews: [nameTextField, cityTextField, addressTextField, signUpButton])
    stackView.distribution = .fillEqually
    stackView.axis = .vertical
    stackView.spacing = 10
    
    view.addSubview(stackView)
    
    stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
    
    signUpButton.addSubview(activityIndicatorView)
    activityIndicatorView.fillSuperview()
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
  
  
  
  //MARK: TextFieldDelegate
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField == cityTextField {
      let flowLayout = UICollectionViewFlowLayout()
      let cityPickerController = CityPickerController(collectionViewLayout: flowLayout)
      cityPickerController.masterDetailsController = self
      let navController = UINavigationController(rootViewController: cityPickerController)
      present(navController, animated: true, completion: nil)
      
      cityTextField.isEnabled = false
      
    } else if textField == addressTextField {
      let chooseAddressController = ChooseAddressController()
      chooseAddressController.masterDetailsController = self
      let navController = UINavigationController(rootViewController: chooseAddressController)
      present(navController, animated: true, completion: nil)
      
      addressTextField.isEnabled = false
    }
    
  }
  
}

