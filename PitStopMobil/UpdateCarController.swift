//
//  UpdateCarController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.01.18.
//  Copyright © 2018 com.pitStopMobil. All rights reserved.
//


import UIKit
import LBTAComponents
import Firebase


struct SelectedImages {
  let image: UIImage?
  let number: String?
}

class UpdateCarController: UIViewController {
  
  var clientProfileController: ClientProfileController?
  var row: Int?
  
  var isMasterViewing: Bool? {
    didSet {
      if let isMasterViewing = isMasterViewing {
        if isMasterViewing {
          
          navigationItem.rightBarButtonItem = nil
          navigationItem.title = "Просмотр"
          saveButton.isHidden = true
          yearTextField.isUserInteractionEnabled = false
          vinTextField.isUserInteractionEnabled = false
          aboutTextView.isUserInteractionEnabled = false
          totalAboutLabel.isHidden = true
          firstImageToChoose.isUserInteractionEnabled = false
          secondImageToChoose.isUserInteractionEnabled = false
        }
      }
    }
  }
  
  var car: Car? {
    didSet{
      navigationItem.title = "Редактировать авто"
      setupNavBarButtons()
      
      firstActivityIndicatorView.startAnimating()
      secondActivityIndicatorView.startAnimating()
      
      carNameLabel.text = "\(car?.mark ?? "") \(car?.model ?? "")"
      setupYear()
      
      vinTextField.text = car?.vin
      aboutTextView.text = car?.about
      
      aboutTextView.handleTextChange()
      
      if let firstImageURL = car?.firstImage, firstImageURL.count > 0 {
        firstImageToChoose.loadImage(urlString: firstImageURL, completion: {
          self.firstActivityIndicatorView.stopAnimating()
        })
      } else {
        self.firstActivityIndicatorView.stopAnimating()
      }
      
      if let secondImageURL = car?.secondImage, secondImageURL.count > 0 {
        secondImageToChoose.loadImage(urlString: secondImageURL, completion: {
          self.secondActivityIndicatorView.stopAnimating()
        })
      } else {
        self.secondActivityIndicatorView.stopAnimating()
      }
      
      changeTotalLabel(textView: aboutTextView)
    }
  }
  
  fileprivate func setupYear() {
    if let carYear = car?.year {
      if carYear.count > 0 {
        let attrTitle = NSAttributedString(string: car?.year ?? "Год выпуска", attributes: [NSAttributedStringKey.foregroundColor: UIColor(white: 0, alpha: 0.2), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)])
        yearTextField.setAttributedTitle(attrTitle, for: .normal)
      } else {
        let attrTitle = NSAttributedString(string: "Год выпуска", attributes: [NSAttributedStringKey.foregroundColor: UIColor(white: 0, alpha: 0.2), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)])
        yearTextField.setAttributedTitle(attrTitle, for: .normal)
      }
    } else {
      let attrTitle = NSAttributedString(string: "Год выпуска", attributes: [NSAttributedStringKey.foregroundColor: UIColor(white: 0, alpha: 0.2), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)])
      yearTextField.setAttributedTitle(attrTitle, for: .normal)
    }
  }
  
  var selectedImages = [SelectedImages]()
  var newFirstImageIsChoosen = false
  var newSecondImageIsChoosen = false
  
  let limitLenghtForVIN = 25
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tabBarController?.tabBar.isHidden = true
    view.backgroundColor = .white
    setupUI()
  }
  
  @objc func handleDelete() {
    if clientProfileController?.cars.count == 1 {
      showAlert(with: "У Вас должен остаться один автомобиль в запасе")
    }
    
    guard let carUID = self.car?.id else { return }
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    Database.database().reference().child("cars").child(uid).child(carUID).removeValue { (err, reference) in
      if err != nil {
        print("error", err ?? "")
        self.showAlert(with: "Произошла ошибка, попробуйте позже")
        return
      }
      print("Successfully removed")
      if let row = self.row {
        let indexPath = IndexPath(row: row, section: 0)
        self.clientProfileController?.cars.remove(at: row)
        self.clientProfileController?.tableView.deleteRows(at: [indexPath], with: .bottom)
      }
      self.showAlert(with: "Вы успешно удалили автомобиль", completion: {
        _ = self.navigationController?.popViewController(animated: true)
      })
    }
  }
  
  var deleteButton: UIBarButtonItem?
  
  private func setupNavBarButtons() {
    deleteButton = UIBarButtonItem(image: #imageLiteral(resourceName: "remove"), style: .plain, target: self, action: #selector(handleDelete))
    deleteButton?.tintColor = .black
    navigationItem.rightBarButtonItem = deleteButton
  }
  
  let carNameLabel: UILabel = {
    let label = UILabel()
    label.text = "Car, model"
    label.font = UIFont.boldSystemFont(ofSize: 17)
    label.numberOfLines = 0
    label.textAlignment = .center
    return label
  }()
  
  var isYearValid = false
  
  @objc func handleTextInputChange() {
    
    let isValid = isYearValid || vinTextField.text?.count ?? 0 > 0
    isForm(valid: isValid)
  }
  
  func isForm(valid: Bool) {
    if valid {
      enableSaveButton()
    } else {
      disableSaveButton()
    }
  }
  
  lazy var yearPickerView: YearPickerView = {
    let view = YearPickerView()
    view.updateCarController = self
    return view
  }()
  
  @objc func handleDatePicker() {
    yearPickerView.presentPicker()
  }
  
  lazy var yearTextField: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = UIColor(white: 0, alpha: 0.03)
    button.layer.cornerRadius = 5
    button.layer.borderColor = UIColor(white: 0, alpha: 0.22).cgColor
    button.layer.borderWidth = 0.5
    button.contentHorizontalAlignment = .left
    button.titleEdgeInsets.left = 8
    button.addTarget(self, action: #selector(handleDatePicker), for: .touchUpInside)
    return button
  }()
  
  
  lazy var vinTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "VIN код"
    tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
    tf.borderStyle = .roundedRect
    tf.returnKeyType = .done
    tf.font = UIFont.systemFont(ofSize: 14)
    tf.autocapitalizationType = .allCharacters
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
    
    
    if isYearValid, let year = yearTextField.titleLabel?.text {
      values["year"] = year
    }
    
    if vinTextField.text?.count ?? 0 > 0, let vin = vinTextField.text {
      values["vin"] = vin
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
  
  lazy var firstImageToChoose: CachedImageView = {
    let iv = CachedImageView()
    iv.image = #imageLiteral(resourceName: "placeholder")
    iv.contentMode = .scaleAspectFill
    iv.layer.cornerRadius = 5
    iv.clipsToBounds = true
    iv.tag = 1
    iv.layer.borderWidth = 1
    iv.layer.borderColor = UIColor.lightGray.cgColor
    iv.isUserInteractionEnabled = true
    iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePickImage)))
    return iv
  }()
  
  lazy var secondImageToChoose: CachedImageView = {
    let iv = CachedImageView()
    iv.image = #imageLiteral(resourceName: "placeholder")
    iv.contentMode = .scaleAspectFill
    iv.layer.cornerRadius = 5
    iv.layer.borderWidth = 1
    iv.clipsToBounds = true
    iv.tag = 2
    iv.isUserInteractionEnabled = true
    iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePickImage)))
    iv.layer.borderColor = UIColor.lightGray.cgColor
    return iv
  }()
  
  let firstActivityIndicatorView: UIActivityIndicatorView = {
    let aiv = UIActivityIndicatorView()
    aiv.activityIndicatorViewStyle = .gray
    aiv.hidesWhenStopped = true
    return aiv
  }()
  
  let secondActivityIndicatorView: UIActivityIndicatorView = {
    let aiv = UIActivityIndicatorView()
    aiv.activityIndicatorViewStyle = .gray
    aiv.hidesWhenStopped = true
    return aiv
  }()
  
  
  var imageIndex = 1
  
  @objc func handlePickImage(touch: UITapGestureRecognizer) {
    if let tag = touch.view?.tag {
      imageIndex = tag
      showMediaOptions()
    }
  }
  
  func uploadImages(userId: String, imagesArray : [SelectedImages], completionHandler: @escaping ([String: String]?) -> ()){
    let storage = Storage.storage()
    
    var imageUrls = [String: String]()
    let imagesCount = imagesArray.count
    var uploadCount = 0
    
    if imagesArray.isEmpty {
      completionHandler(nil)
    }
    
    for image in imagesArray {
      
      let fileName = NSUUID().uuidString // Unique string to reference image
      
      //Create storage reference for image
      let storageRef = storage.reference().child("car_images").child(fileName)
      
      guard let uplodaData = UIImagePNGRepresentation(image.image!) else {
        return
      }
      
      // Upload image to firebase
      let uploadTask = storageRef.putData(uplodaData, metadata: nil, completion: { (metadata, error) in
        if error != nil{
          print(error ?? "")
          return
        }
        if let imageUrl = metadata?.downloadURL()?.absoluteString{
          print(imageUrl)
          if uploadCount == 0 {
            imageUrls[image.number ?? "firstImage"] = imageUrl
          } else if uploadCount == 1 {
            imageUrls[image.number ?? "secondImage"] = imageUrl
          }
          
          uploadCount += 1
          print("Number of images successfully uploaded: \(uploadCount)")
          if uploadCount == imagesCount {
            NSLog("All Images are uploaded successfully, uploadedImageUrlsArray: \(imageUrls)")
            completionHandler(imageUrls)
          }
        }
        
      })
      
      observeUploadTaskFailureCases(uploadTask : uploadTask)
      
    }
  }
  
  private func observeUploadTaskFailureCases(uploadTask : StorageUploadTask){
    uploadTask.observe(.failure) { snapshot in
      if let error = snapshot.error as NSError? {
        switch (StorageErrorCode(rawValue: error.code)!) {
        case .objectNotFound:
          NSLog("File doesn't exist")
          break
        case .unauthorized:
          NSLog("User doesn't have permission to access file")
          break
        case .cancelled:
          NSLog("User canceled the upload")
          break
        case .unknown:
          NSLog("Unknown error occurred, inspect the server response")
          break
        default:
          NSLog("A separate error occurred, This is a good place to retry the upload.")
          break
        }
      }
    }
  }
  
  @objc private func handleSave() {
   
    var values = setupChangedValues()
    
    guard let uid = Auth.auth().currentUser?.uid else { return }
    guard let carUID = self.car?.id else { return }
    
    LoadingIndicator.shared.show()
    
    //upload images to firebase storage first
    uploadImages(userId: uid, imagesArray: selectedImages) { (imageURLS) in
      if let imageURLSDict = imageURLS {
        for (key, value) in imageURLSDict {
          values[key] = value
        }
      }
      
      let userPostRef = Database.database().reference().child("cars").child(uid).child(carUID)
      
      userPostRef.updateChildValues(values) { (err, ref) in
        if let err = err {
          print("Failed to save post to DB", err)
          self.showAlert(with: "Произошла ошибка, попробуйте позже")
          LoadingIndicator.shared.hide()
          return
        }
        
        self.clientProfileController?.cars.removeAll()
        self.clientProfileController?.fetchCarsFor(uid: uid)
        print("Successfully updated car info...")
        LoadingIndicator.shared.hide()
        self.showAlert(with: "Вы успешно обновили информацию об автомобиле", completion: {
          _ = self.navigationController?.popViewController(animated: true)
        })
      }
    }
  }
  
  
  private func setupUI() {
    view.addSubview(carNameLabel)
    carNameLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 100, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 0)
    
    let stackView = UIStackView(arrangedSubviews: [yearTextField, vinTextField])
    stackView.distribution = .fillEqually
    stackView.axis = .vertical
    stackView.spacing = 10
    view.addSubview(stackView)
    stackView.anchor(top: carNameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 110)
    
    aboutTextView.placeholder = "Расскажите об авто"
    view.addSubview(aboutTextView)
    aboutTextView.anchor(top: stackView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 100)
    
    view.addSubview(totalAboutLabel)
    totalAboutLabel.anchor(top: aboutTextView.bottomAnchor, left: nil, bottom: nil, right: aboutTextView.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
    view.addSubview(saveButton)
    saveButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 60)
    
    let imagesStackView = UIStackView(arrangedSubviews: [firstImageToChoose, secondImageToChoose])
    imagesStackView.distribution = .fillEqually
    imagesStackView.axis = .horizontal
    imagesStackView.spacing = 8
    
    firstImageToChoose.addSubview(firstActivityIndicatorView)
    secondImageToChoose.addSubview(secondActivityIndicatorView)
    
    firstActivityIndicatorView.fillSuperview()
    secondActivityIndicatorView.fillSuperview()
    
    view.addSubview(imagesStackView)
    imagesStackView.anchor(top: nil, left: view.leftAnchor, bottom: saveButton.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 0, height: 100)
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




extension UpdateCarController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  
  
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
    
    switch imageIndex {
    case 1:
      firstImageToChoose.image = imagePicked
      newFirstImageIsChoosen = true
    case 2:
      secondImageToChoose.image = imagePicked
      newSecondImageIsChoosen = true
    default:
      fatalError()
    }
    
    saveButton.isEnabled = true
    saveButton.backgroundColor = Settings.Color.pink
    
    selectedImages.removeAll()
    if newFirstImageIsChoosen {
      let selectedImage = SelectedImages(image: firstImageToChoose.image, number: "firstImage")
      selectedImages.append(selectedImage)
    }
    if newSecondImageIsChoosen {
      let selectedImage = SelectedImages(image: secondImageToChoose.image, number: "secondImage")
      selectedImages.append(selectedImage)
    }
    
    
    dismiss(animated: true, completion: nil)
  }
}


extension UpdateCarController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let newLength = textField.text!.count + string.count - range.length
    
    if textField == vinTextField {
      return  newLength <= limitLenghtForVIN
    }
    
    return true
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
 
}



extension UpdateCarController: UITextViewDelegate {
  
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

