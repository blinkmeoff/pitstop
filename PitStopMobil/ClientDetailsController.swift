//
//  ClientDetailsController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class ClientDetailsController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
  
  var phoneNumber: String?
  var models: [String]?
  

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    setupViews()
    setupInputFields()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    carMarkTextField.isEnabled = true
    carModelTextField.isEnabled = true
  }
  
  let plusPhotoButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
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
      isImageChoosen = true
    } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
      imagePicked = originalImage
      isImageChoosen = true
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
    let isFormValid = nameTextField.text?.count ?? 0 > 0 && carMarkTextField.text?.count ?? 0 > 0 && carModelTextField.text?.count ?? 0 > 0
    
    if isFormValid {
      signUpButton.isEnabled = true
      signUpButton.backgroundColor = Settings.Color.blue
    } else {
      signUpButton.isEnabled = false
      signUpButton.backgroundColor = Settings.Color.disabledBlue
    }
  }
  
  lazy var carMarkTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Марка машины"
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.font = UIFont.systemFont(ofSize: 14)
    tf.delegate = self
    tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
    return tf
  }()
  
  lazy var carModelTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Модель"
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
    button.backgroundColor = Settings.Color.disabledBlue
    
    button.layer.cornerRadius = 5
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    button.setTitleColor(.white, for: .normal)
    
    button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
    
    button.isEnabled = false
    
    return button
  }()
  
  @objc func handleSignUp() {
    if !isImageChoosen {
      self.showAlert(with: "Пожалуйста, выберите фото профиля")
      return
    }
    guard let username = nameTextField.text, username.count > 0 else { return }
    guard let carMark = carMarkTextField.text, carMark.count > 0 else { return }
    guard let carModel = carModelTextField.text, carModel.count > 0 else { return }
    guard let phoneNumber = phoneNumber else { return }
    
    guard let image = self.plusPhotoButton.imageView?.image else { return }
    guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else { return }
    let filename = NSUUID().uuidString
    
    signUpButton.setTitle("", for: .normal)
    signUpButton.isEnabled = false
    activityIndicatorView.startAnimating()
    
    guard let uid = Auth.auth().currentUser?.uid else { return }
    guard let fcmToken = Messaging.messaging().fcmToken else { return }
    var dictionaryValues = ["phoneNumber": phoneNumber, "username": username, "isClient": 1, "profileImageUrl": "", "fcmToken": fcmToken] as [String: Any]

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

        self.saveUserToDatabase(with: values, carMark: carMark, carModel: carModel, uid: uid)

      }
    } else {
      let values = [uid: dictionaryValues]
      self.saveUserToDatabase(with: values, carMark: carMark, carModel: carModel, uid: uid)
    }
  }
  
  fileprivate func saveUserCarToDatabase(carMark: String, carModel: String, uid: String) {
    let reference = Database.database().reference().child("cars").child(uid)
    let childAutoId = reference.childByAutoId()
    let car = ["mark": carMark, "model": carModel, "isMain": 1] as [String: Any]
    
    childAutoId.updateChildValues(car) { (error, reference) in
      
      if let err = error {
        self.signUpButton.isEnabled = true
        print("Failed to save user car info into db:", err)
        return
      }
      print("Successfully saved user car info to db")
      self.dismissSignUpController()
    }
  }
  
  fileprivate func saveUserToDatabase(with values: [String: [String: Any]], carMark: String, carModel: String, uid: String) {
    Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
      
      if let err = err {
        self.signUpButton.isEnabled = true
        print("Failed to save user info into db:", err)
        return
      }
      self.saveUserCarToDatabase(carMark: carMark, carModel: carModel, uid: uid)
      print("Successfully saved user info to db")
    })
  }
  
  fileprivate func dismissSignUpController() {
    if let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController {
      guard let mainTab = mainTabBarController.childViewControllers.first as? MainTabBarController else { return }
      mainTab.setupViewControllers(completed: { (isCompleted) in
        DispatchQueue.main.async {
          if isCompleted {
            mainTab.selectedIndex = 4
            self.dismiss(animated: true, completion: nil)
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
    
    attributedTitle.append(NSAttributedString(string: "Войти", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237)
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
    let stackView = UIStackView(arrangedSubviews: [nameTextField, carMarkTextField, carModelTextField, signUpButton])
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
    if textField == carMarkTextField {
      let flowLayout = UICollectionViewFlowLayout()
      let carPickerController = CarPickerController(collectionViewLayout: flowLayout)
      carPickerController.clientDetailsController = self
      let navController = UINavigationController(rootViewController: carPickerController)
      present(navController, animated: true, completion: nil)
      
      carMarkTextField.isEnabled = false

    } else if textField == carModelTextField {
      
      let flowLayout = UICollectionViewFlowLayout()
      let carModelPickerController = CarModelPickerController(collectionViewLayout: flowLayout)
      carModelPickerController.clientDetailsController = self
      guard let models = self.models else { return }
      carModelPickerController.models = models
      let navController = UINavigationController(rootViewController: carModelPickerController)
      present(navController, animated: true, completion: nil)
      
      carModelTextField.isEnabled = false
    }
  }

}
