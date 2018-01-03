//
//  NewOrderInfoController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.11.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class NewOrderInfoController: UIViewController {
  
  var selectedSkills = [String]()
  var selectedImages = [UIImage]()
  
  var client: Client?
  
  lazy var firstImageToChoose: UIImageView = {
    let iv = UIImageView()
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
  
  lazy var secondImageToChoose: UIImageView = {
    let iv = UIImageView()
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
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
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
  
  override var inputAccessoryView: UIView? {
    get {
      return containerView
    }
  }
  
  @objc private func handleDone() {
    self.view.endEditing(true)
  }
  
  lazy var thirdImageToChoose: UIImageView = {
    let iv = UIImageView()
    iv.image = #imageLiteral(resourceName: "placeholder")
    iv.contentMode = .scaleAspectFill
    iv.layer.cornerRadius = 5
    iv.layer.borderWidth = 1
    iv.clipsToBounds = true
    iv.tag = 3
    iv.layer.borderColor = UIColor.lightGray.cgColor
    iv.isUserInteractionEnabled = true
    iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePickImage)))
    return iv
  }()
  
  lazy var fourthImageToChoose: UIImageView = {
    let iv = UIImageView()
    iv.image = #imageLiteral(resourceName: "placeholder")
    iv.contentMode = .scaleAspectFill
    iv.layer.cornerRadius = 5
    iv.clipsToBounds = true
    iv.tag = 4
    iv.layer.borderWidth = 1
    iv.layer.borderColor = UIColor.lightGray.cgColor
    iv.isUserInteractionEnabled = true
    iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePickImage)))
    return iv
  }()
  
  var imageIndex = 1
  
  @objc func handlePickImage(touch: UITapGestureRecognizer) {
    let imagePicker = UIImagePickerController()
    imagePicker.allowsEditing = true
    imagePicker.delegate = self
    
    if let tag = touch.view?.tag {
      imageIndex = tag
      present(imagePicker, animated: true, completion: nil)
    }
    
  }
  
  let problemLabel: UILabel = {
    let label = UILabel()
    label.text = "Опишите проблему"
    label.textColor = .black
    label.font = UIFont.boldSystemFont(ofSize: 17)
    label.numberOfLines = 0
    label.textAlignment = .center
    return label
  }()
  
  lazy var textView: UITextView = {
    let tv = UITextView()
    tv.layer.borderColor = UIColor.lightGray.cgColor
    tv.layer.borderWidth = 1
    tv.layer.cornerRadius = 5
    tv.delegate = self
    return tv
  }()
  
  lazy var createButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = Settings.Color.disabledPink
    
    let attributedTitle = NSAttributedString(string: "СОЗДАТЬ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: UIColor.white])
    button.setAttributedTitle(attributedTitle, for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.isEnabled = false
    button.addTarget(self, action: #selector(handleCreate), for: .touchUpInside)
    return button
  }()
  
  @objc private func handleCreate() {
    
    guard let text = textView.text, textView.text.count > 0 else {
      showAlert(with: "Пожалуйста опишите проблему")
      return
    }
    
    guard let client = self.client else {
      showAlert(with: "Произошла ошибка")
      return
    }
    
    guard let uid = Auth.auth().currentUser?.uid else { return }
    LoadingIndicator.shared.showLoadingIndicator()
    
    //upload images to firebase storage first
    uploadImages(userId: uid, imagesArray: selectedImages) { (imagesURL) in
      
      //create order node
      let userPostRef = Database.database().reference().child("orders").childByAutoId()
      let imageUrl = self.createString(array: imagesURL)
      let skills = self.createString(array: self.selectedSkills)
      let clientName = client.username
      let profileImageUrl = client.profileImageUrl
      
      let values = ["imageUrls": imageUrl, "skills": skills, "description": text, "ownerId": uid, "creationDate": Date().timeIntervalSince1970, "clientName": clientName, "clientProfileImageUrl": profileImageUrl, "status": "pending"] as [String : Any]

      
      userPostRef.updateChildValues(values) { (err, ref) in
        if let err = err {
          print("Failed to save post to DB", err)
          self.showAlert(with: "Произошла ошибка")
          LoadingIndicator.shared.hideLoadingIndicator()
          return
        }
        
        let orderId = userPostRef.key
        let userOrderRef = Database.database().reference().child("user-orders").child(uid)
        userOrderRef.updateChildValues([orderId: 1])
        
        print("Successfully saved post to DB")
        LoadingIndicator.shared.hideLoadingIndicator()
        self.presentSuccessAlert()
        
      }
    }
  }
  
  private func presentSuccessAlert() {
    let alertController = UIAlertController(title: "", message: "Ваша заявка успешно добавлена.\nВ скором времени с Вами свяжется один из мастеров", preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .cancel) { (action) in
      self.dismiss(animated: true, completion: nil)
    }
    alertController.addAction(action)
    present(alertController, animated: true, completion: nil)
  }
  
  func uploadImages(userId: String, imagesArray : [UIImage], completionHandler: @escaping ([String]) -> ()){
    let storage = Storage.storage()
    
    var uploadedImageUrlsArray = [String]()
    var uploadCount = 0
    let imagesCount = imagesArray.count
    
    for image in imagesArray {
      
      let fileName = NSUUID().uuidString // Unique string to reference image
      
      //Create storage reference for image
      let storageRef = storage.reference().child("orders_images").child(fileName)
      
      guard let uplodaData = UIImagePNGRepresentation(image) else {
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
          uploadedImageUrlsArray.append(imageUrl)
          
          uploadCount += 1
          print("Number of images successfully uploaded: \(uploadCount)")
          if uploadCount == imagesCount {
            NSLog("All Images are uploaded successfully, uploadedImageUrlsArray: \(uploadedImageUrlsArray)")
            completionHandler(uploadedImageUrlsArray)
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
  
  private func createString(array: [String]) -> String {
    var string = ""
    array.forEach { (text) in
      string.append("\(text),")
    }
    return string
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupNavBar()
    setupUI()
  }
  
  private func setupNavBar() {
    navigationItem.title = "Новая Заявка"
    let leftCancelButton = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(handlePop))
    leftCancelButton.tintColor = .black
    navigationItem.leftBarButtonItem = leftCancelButton
  }
  
  @objc private func handlePop() {
    _ = navigationController?.popToRootViewController(animated: true)
  }
  
  private func setupUI() {
    view.addSubview(createButton)
    createButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    
    
    let stackView = UIStackView(arrangedSubviews: [firstImageToChoose, secondImageToChoose])
    stackView.distribution = .fillEqually
    stackView.axis = .horizontal
    stackView.spacing = 8
    
    view.addSubview(stackView)
    stackView.anchor(top: nil, left: view.leftAnchor, bottom: createButton.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 0, height: 100)
    
    let secondStackView = UIStackView(arrangedSubviews: [thirdImageToChoose, fourthImageToChoose])
    secondStackView.distribution = .fillEqually
    secondStackView.axis = .horizontal
    secondStackView.spacing = 8
    
    view.addSubview(secondStackView)
    secondStackView.anchor(top: nil, left: view.leftAnchor, bottom: stackView.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 10, paddingRight: 20, width: 0, height: 100)
    
    view.addSubview(problemLabel)
    problemLabel.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
    view.addSubview(textView)
    textView.anchor(top: problemLabel.bottomAnchor, left: view.leftAnchor, bottom: secondStackView.topAnchor, right: view.rightAnchor, paddingTop: 12, paddingLeft: 20, paddingBottom: 12, paddingRight: 20, width: 0, height: 0)
  }
  
}

extension NewOrderInfoController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
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
      firstImageToChoose.isUserInteractionEnabled = false
    case 2:
      secondImageToChoose.image = imagePicked
      secondImageToChoose.isUserInteractionEnabled = false
    case 3:
      thirdImageToChoose.image = imagePicked
      thirdImageToChoose.isUserInteractionEnabled = false
    case 4:
      fourthImageToChoose.image = imagePicked
      fourthImageToChoose.isUserInteractionEnabled = false
    default:
      fatalError()
    }
    
    if let image = imagePicked {
      selectedImages.append(image)
    }
    
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    self.dismiss(animated: true, completion: nil)
  }
  
}


extension NewOrderInfoController: UITextViewDelegate {
  
  func textViewDidChange(_ textView: UITextView) {
    if textView.text.count > 0 {
      self.createButton.isEnabled = true
      self.createButton.backgroundColor = Settings.Color.pink
    }
  }
  
}
