//
//  ClientProfileController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class ClientProfileController: UIViewController, ClientProfileHeaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  let tableId = "tableId"
  let cellId = "cellId"
  let headerId = "headerId"
  
  
  lazy var collectionView: UICollectionView = {
    let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    cv.delegate = self
    cv.dataSource = self
    return cv
  }()
  
  lazy var tableView : UITableView = {
    let tb = UITableView(frame: .zero, style: UITableViewStyle.plain)
    tb.delegate = self
    tb.dataSource = self
    return tb
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    navigationItem.title = "Профиль"
    setupCollection()
    setupLogOutButton()
    fetchClientInfo()
    setupTableView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    tabBarController?.tabBar.isHidden = false
  }
  
  private func setupTableView() {
    tableView.separatorStyle = .singleLineEtched
    
    tableView.register(ClientCarCell.self, forCellReuseIdentifier: tableId)
    tableView.tableFooterView = UIView() // blank UIView
    view.addSubview(tableView)
    
    tableView.anchor(collectionView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
  }
  
  fileprivate func setupCollection() {
    collectionView.backgroundColor = .white
    view.addSubview(collectionView)
    collectionView.anchor(topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 182)
    
    collectionView.register(ClientProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
  }
  
  fileprivate func setupLogOutButton() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(showSettings))
    
  }
  
  @objc func showSettings() {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    alertController.addAction(UIAlertAction(title: "Добавить Автомобиль", style: .default, handler: { (_) in
      //add car
      let carPickerController = CarPickerController(collectionViewLayout: UICollectionViewFlowLayout())
      carPickerController.clientProfileController = self
      let navController = UINavigationController(rootViewController: carPickerController)
      self.present(navController, animated: true, completion: nil)
    }))
    
    alertController.addAction(UIAlertAction(title: "Редактировать профиль", style: .default, handler: { (_) in
      let editProfile = ClientEditProfile()
      editProfile.client = self.client
      self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
      self.navigationController?.navigationBar.tintColor = .black
      self.navigationController?.pushViewController(editProfile, animated: true)
    }))
    
    alertController.addAction(UIAlertAction(title: "Выйти", style: .destructive, handler: { (_) in
      
      do {
        if let uid = Auth.auth().currentUser?.uid {
          let ref = Database.database().reference().child("users").child(uid)
          ref.updateChildValues(["fcmToken": ""])
        }
        
        try Auth.auth().signOut()
        
        //what happens? we need to present some kind of login controller
        let choiseController = ChoiseController()
        let navController = UINavigationController(rootViewController: choiseController)
        self.present(navController, animated: true, completion: nil)
        
      } catch let signOutErr {
        print("Failed to sign out:", signOutErr)
      }
    }))
      
    alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
    
    let versionNumber = Bundle.applicationVersionNumber
    alertController.title = "Версия \(versionNumber)"
    
    present(alertController, animated: true, completion: nil)
  }
  
  var client: Client?
  var cars = [Car]()
  
  fileprivate func fetchClientInfo() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    Database.fetchUserWithUID(uid: uid, isMaster: false) { (client) in
      self.client = client as? Client
      
      self.fetchCarsFor(uid: uid)
      DispatchQueue.main.async {
        self.collectionView.reloadData()
      }
    }
  }
  
  func fetchCarsFor(uid: String) {
    cars.removeAll()
    Database.database().reference().child("cars").child(uid).observe(.childAdded , with: { (snapshot) in
      
      guard let carsDictionary = snapshot.value as? [String: Any] else { return }
      let carId = snapshot.key
      
      let car = Car(dictionary: carsDictionary, id: carId)
      print(carId)
      self.cars.append(car)
      
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
      
    }) { (err) in
      print("Failed to fetch user for posts:", err)
    }
  }
  
  //MARK: Delegate Header
  func didTapImageProfile() {
    let imagePickerController = UIImagePickerController()
    
    imagePickerController.allowsEditing = true
    imagePickerController.delegate = self
    
    present(imagePickerController, animated: true, completion: nil)
  }
  
  func didTapFavorites() {
    let clientFavoritesController = FavoritesController(collectionViewLayout: UICollectionViewFlowLayout())
    let navController = UINavigationController(rootViewController: clientFavoritesController)
    self.present(navController, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    var imagePicked: UIImage?
    
    if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
      imagePicked = editedImage
    } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
      imagePicked = originalImage
    }

    if let imageToUpload = imagePicked {
      updateUserProfileImage(image: imageToUpload)
    }
    
    dismiss(animated: true, completion: nil)
  }

  fileprivate func updateUserProfileImage(image: UIImage) {
    
    guard let uid = Auth.auth().currentUser?.uid else { return }
    guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else { return }
    let filename = NSUUID().uuidString
    
    guard let header = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? ClientProfileHeader else { return }
    header.activityIndicatorView.startAnimating()
    header.profileImageView.alpha = 0
    
    Storage.storage().reference().child("profile_images").child(filename).putData(uploadData, metadata: nil) { (metadata, err) in
      if let err = err {
        header.profileImageView.alpha = 0
        header.activityIndicatorView.stopAnimating()
        print("Failed to upload profile image:", err)
        return
      }
      
      guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { return }
      
      print("Successfully uploaded new profile image:", profileImageUrl)
      
      let ref = Database.database().reference().child("users").child(uid)
      ref.updateChildValues(["profileImageUrl": profileImageUrl], withCompletionBlock: { (err, ref) in
        self.fetchClientInfo()
      })

    }
  }
  
}


extension ClientProfileController: UICollectionViewDataSource,  UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! ClientProfileHeader
    
    header.client = self.client
    header.delegate = self
    
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: view.frame.width, height: 180)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
    
    return cell
  }
}

extension ClientProfileController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: tableId, for: indexPath) as! ClientCarCell
    cell.car = cars[indexPath.row]
    cell.selectionStyle = .none
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cars.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let car = cars[indexPath.row]
    let updateCarController = UpdateCarController()
    updateCarController.car = car
    updateCarController.row = indexPath.row
    updateCarController.clientProfileController = self
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    navigationController?.navigationBar.tintColor = .black
    navigationController?.pushViewController(updateCarController, animated: true)
  }
  
  @available(iOS 11.0, *)
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let action = UIContextualAction(style: .normal, title: nil) { (action, view, completionHandler) in
      
      self.removeCarFromDB(indexPath: indexPath)
      completionHandler(true)
    }
    
    action.image = #imageLiteral(resourceName: "remove")
    action.backgroundColor = .clear
    let configuration = UISwipeActionsConfiguration(actions: [action])
    return configuration
  }
  
  private func removeCarFromDB(indexPath: IndexPath) {
    
    if self.cars.count == 1 {
      showAlert(with: "У Вас должен остаться один автомобиль в запасе")
      return
    }
    
    guard let uid = Auth.auth().currentUser?.uid else { return }
    guard let carId = cars[indexPath.row].id else { return }
    
    Database.database().reference().child("cars").child(uid).child(carId).removeValue { (err, reference) in
      if err != nil {
        print("error", err ?? "")
        return
      }
      
      self.cars.remove(at: indexPath.row)
      self.tableView.deleteRows(at: [indexPath], with: .bottom)
      
      print("Successfully removed")
    }
  }
  
}


extension ClientProfileController: CarModelPickerDelegate {
  
  func didPickModel(carMark: String, carModel: String) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    let reference = Database.database().reference().child("cars").child(uid).childByAutoId()
    let values = ["isMain": 0, "mark": carMark, "model": carModel] as [String: Any]
    
    reference.updateChildValues(values) { (error, reference) in
      if error != nil {
        print("Error", error ?? "")
        return
      }
      
      print("Successfully added new car to db")
    }
  }
  
}







