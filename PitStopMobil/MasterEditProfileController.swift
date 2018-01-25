//
//  MasterEditProfileController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.01.18.
//  Copyright © 2018 com.pitStopMobil. All rights reserved.
//

import UIKit
import LBTAComponents
import Firebase

class MasterEditProfileController: UIViewController {
  
  var master: Master? {
    didSet {
      nameTextField.placeholder = master?.username
      addressTextField.placeholder = master?.address
      cityTextField.placeholder = master?.city
      aboutTextView.text = master?.about?.count ?? 0 > 0 ? master?.about : ""
      
      if let imageURL = master?.profileImageUrl {
        profileImageView.loadImage(urlString: imageURL)
      }
    }
  }
  var isNewImageChoosen = false
  let limitLenghtForName = 16

  var latitude: Double?
  var longitude: Double?

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "Редактировать профиль"
    tabBarController?.tabBar.isHidden = true
    view.backgroundColor = .white
    setupUI()
  }
  
  lazy var profileImageView: CachedImageView = {
    let iv = CachedImageView()
    iv.translatesAutoresizingMaskIntoConstraints = false
    iv.contentMode = .scaleAspectFill
    iv.backgroundColor = UIColor(white: 0, alpha: 0.1)
    iv.layer.cornerRadius = 50
    iv.isUserInteractionEnabled = true
    iv.layer.borderColor = UIColor(white: 0.3, alpha: 0.5).cgColor
    iv.layer.borderWidth = 0.3
    iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleChoosePhoto)))
    return iv
  }()
  
  lazy var addNewImageView: UIImageView = {
    let iv = UIImageView()
    iv.image = #imageLiteral(resourceName: "new_photo")
    iv.clipsToBounds = true
    iv.contentMode = .scaleAspectFill
    iv.isUserInteractionEnabled = true
    iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleChoosePhoto)))
    return iv
  }()
  
  @objc func handleChoosePhoto() {
    showMediaOptions()
  }
  
  @objc func handleTextInputChange() {
    let isValid = nameTextField.text?.count ?? 0 > 0 || addressTextField.text?.count ?? 0 > 0 || cityTextField.text?.count ?? 0 > 0
    isForm(valid: isValid)
  }
  
  func isForm(valid: Bool) {
    if valid {
      enableSaveButton()
    } else {
      disableSaveButton()
    }
  }
  
  lazy var nameTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Имя"
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.delegate = self
    tf.returnKeyType = .done
    tf.font = UIFont.systemFont(ofSize: 14)
    tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
    return tf
  }()
  
  
  lazy var addressTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Адрес"
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.returnKeyType = .done
    tf.font = UIFont.systemFont(ofSize: 14)
    tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
    tf.delegate = self
    return tf
  }()
  
  lazy var cityTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Область"
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.returnKeyType = .done
    tf.font = UIFont.systemFont(ofSize: 14)
    tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
    tf.delegate = self
    return tf
  }()
  
  func clearCommentTextField() {
    aboutTextView.text = nil
    aboutTextView.showPlaceholderLabel()
  }
  
  lazy var aboutTextView: AboutInputTextView = {
    let tv = AboutInputTextView()
    tv.layer.cornerRadius = 5
    tv.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tv.font = UIFont.systemFont(ofSize: 15)
    tv.layer.borderColor = UIColor(white: 0, alpha: 0.22).cgColor
    tv.layer.borderWidth = 0.5
    tv.delegate = self
    return tv
  }()
  
  let totalAboutLabel: UILabel = {
    let label = UILabel()
    label.text = "0 / 200"
    label.textColor = .lightGray
    label.font = UIFont.systemFont(ofSize: 10)
    return label
  }()
  
  lazy var saveButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = Settings.Color.disabledPink
    
    let attributedTitle = NSAttributedString(string: "СОХРАНИТЬ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: UIColor.white])
    button.setAttributedTitle(attributedTitle, for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.isEnabled = false
    button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
    return button
  }()
  
  private func setupChangedValues() -> [String: Any] {
    var values = [String: Any]()
    
    
    if nameTextField.text?.count ?? 0 > 0 , let username = nameTextField.text {
      values["username"] = username
    }
    
    if addressTextField.text?.count ?? 0 > 0, let address = addressTextField.text {
      values["address"] = address
    }
    
    if cityTextField.text?.count ?? 0 > 0, let city = cityTextField.text {
      values["city"] = city
      values["longitude"] = longitude
      values["latitude"] = latitude
    }
    
    if aboutTextView.text.count > 0, let about = aboutTextView.text {
      values["about"] = about
    }
    
    return values
  }
  
  func enableSaveButton() {
    saveButton.backgroundColor = Settings.Color.pink
    saveButton.isEnabled = true
  }
  
  func disableSaveButton() {
    saveButton.backgroundColor = Settings.Color.disabledPink
    saveButton.isEnabled = false
  }
  
  @objc private func handleSave() {
    print("Save changes...")

    guard let image = profileImageView.image else { return }
    guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else { return }
    let filename = NSUUID().uuidString
    
    var values = setupChangedValues()
    LoadingIndicator.shared.show()
    
    if isNewImageChoosen {
      Storage.storage().reference().child("profile_images").child(filename).putData(uploadData, metadata: nil) { (metadata, err) in
        if let err = err {
          print("Failed to upload profile image:", err)
          self.showAlert(with: "Не удалось загрузить фотографию на сервер")
          LoadingIndicator.shared.hide()
          return
        }
        
        guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { return }
        
        print("Successfully uploaded profile image:", profileImageUrl)
        
        
        values["profileImageUrl"] = profileImageUrl
        
        self.updateUserInformation(with: values)
      }
    } else {
      self.updateUserInformation(with: values)
    }
  }
  
  fileprivate func updateUserInformation(with values: [String: Any]) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let reference = Database.database().reference().child("users").child(uid)
    reference.updateChildValues(values) { (err, ref) in
      if let err = err {
        print("Failed to update user info :", err)
        self.showAlert(with: "Не удалось обновить профиль, попробуйте позже")
        LoadingIndicator.shared.hide()
        return
      }
      
      print("Successfully updated user info")
      LoadingIndicator.shared.hide()
      self.showAlert(with: "Вы успешно обновили профиль", completion: {
        _ = self.navigationController?.popViewController(animated: true)
      })
    }
  }
  
  private func setupUI() {
    view.addSubview(profileImageView)
    view.addSubview(addNewImageView)

    profileImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 100, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
    profileImageView.anchorCenterXToSuperview()
    
    addNewImageView.anchor(top: nil, left: nil, bottom: profileImageView.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 24, height: 24)
    
    let stackView = UIStackView(arrangedSubviews: [nameTextField, cityTextField, addressTextField])
    stackView.distribution = .fillEqually
    stackView.axis = .vertical
    stackView.spacing = 10
    view.addSubview(stackView)
    stackView.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 160)
    
    view.addSubview(aboutTextView)
    aboutTextView.anchor(top: stackView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 100)
    
    view.addSubview(totalAboutLabel)
    totalAboutLabel.anchor(top: aboutTextView.bottomAnchor, left: nil, bottom: nil, right: aboutTextView.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
    view.addSubview(saveButton)
    saveButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 60)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
  
  let aboutTextViewLenght = 200
  
  func changeTotalLabel(textView: UITextView) {
    let totalCharactersWritten = textView.text.count
    totalAboutLabel.text = "\(totalCharactersWritten) / 200"
  }
  
}




extension MasterEditProfileController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  
  
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
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    var imagePicked: UIImage?
    
    if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
      imagePicked = editedImage
    } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
      imagePicked = originalImage
    }
    
    if let image = imagePicked {
      isNewImageChoosen = true
      enableSaveButton()
      profileImageView.image = image
      profileImageView.layer.cornerRadius = profileImageView.frame.width/2
      profileImageView.layer.masksToBounds = true
    }
    
    dismiss(animated: true, completion: nil)
  }
}


extension MasterEditProfileController: UITextFieldDelegate {
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField == cityTextField {
      let flowLayout = UICollectionViewFlowLayout()
      let cityPickerController = CityPickerController(collectionViewLayout: flowLayout)
      cityPickerController.masterEditController = self
      let navController = UINavigationController(rootViewController: cityPickerController)
      present(navController, animated: true, completion: nil)
      
      cityTextField.isEnabled = false
      
    } else if textField == addressTextField {
      let chooseAddressController = ChooseAddressController()
      chooseAddressController.masterEditController = self
      let navController = UINavigationController(rootViewController: chooseAddressController)
      present(navController, animated: true, completion: nil)
      
      addressTextField.isEnabled = false
    }
  }
  
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let newLength = textField.text!.count + string.count - range.length
    
    if textField == nameTextField {
      return  newLength <= limitLenghtForName
    }
    
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}



extension MasterEditProfileController: UITextViewDelegate {
  
  func textViewDidChange(_ textView: UITextView) {
    let isValid = textView.text.count > 0
    isForm(valid: isValid)
    changeTotalLabel(textView: textView)
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.view.frame = CGRect(x: 0, y: -100, width: self.view.frame.width, height: self.view.frame.height)
    }, completion: nil)
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
    }, completion: nil)
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
    let numberOfChars = newText.count
    return numberOfChars <= aboutTextViewLenght
  }
}
