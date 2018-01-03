//
//  FavoritesController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.12.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class FavoritesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  var masters = [Master]()
  
  let footerId = "footerId"
  let cellId = "cellId"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "Избранные"
    view.backgroundColor = .white
    setupBackButton()
    setupCollection()
    fetchFavoriteMasters()
  }
  
  private func setupBackButton() {
    let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "close"), style: .plain, target: self, action: #selector(handleDismiss))
    backButton.tintColor = .black
    navigationItem.leftBarButtonItem = backButton
  }
  
  @objc private func handleDismiss() {
    dismiss(animated: true, completion: nil)
  }
  
  private func fetchFavoriteMasters() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let ref = Database.database().reference().child("favorites").child(uid)
    ref.observeSingleEvent(of: .value) { (snapshot) in
      
      guard let dictionaries = snapshot.value as? [String: Any] else { return }
      dictionaries.forEach({ (key, value) in
        self.fetchMaster(uid: key)
      })
      
    }
  }
  
  private func fetchMaster(uid: String) {
    let reference = Database.database().reference().child("users").child(uid)
    reference.observeSingleEvent(of: .value) { (snapshot) in
      guard let dictionary = snapshot.value as? [String: Any] else { return }
      let master = Master(uid: uid, dictionary: dictionary)
      self.masters.append(master)
      
      DispatchQueue.main.async {
        self.collectionView?.reloadData()
      }
    }
  }
  
  private func setupCollection() {
    collectionView?.backgroundColor = .white
    collectionView?.register(FavoritesCell.self, forCellWithReuseIdentifier: cellId)
    collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerId)
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return masters.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FavoritesCell
    cell.delegate = self
    cell.user = masters[indexPath.item]
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 66)
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    guard let masterUID = masters[indexPath.item].uid else { return }
    presentProfile(uid: masterUID)
  }
  
  fileprivate func presentProfile(uid: String) {
        
    let userProfileController = MasterProfileController(collectionViewLayout: UICollectionViewFlowLayout())
    userProfileController.userId = uid
    tabBarController?.tabBar.isHidden = true
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    navigationController?.navigationBar.tintColor = .black
    navigationController?.pushViewController(userProfileController, animated: true)
  }
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return masters.isEmpty ? CGSize(width: collectionView.frame.width, height: collectionView.frame.height - 60) : .zero
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerId, for: indexPath)
    
    setupFooterCell(cell: footer)
    
    return footer
  }
  
  private func setupFooterCell(cell: UICollectionReusableView) {
    let noMessagesLabel = UILabel()
    noMessagesLabel.text = "Нет избранных"
    noMessagesLabel.textColor = .lightGray
    noMessagesLabel.textAlignment = .center
    noMessagesLabel.font = UIFont.systemFont(ofSize: 17)
    cell.addSubview(noMessagesLabel)
    noMessagesLabel.fillSuperview()
  }
  
 
  
}

extension FavoritesController: FavoritesCellDelegate {
  
  func didTapRemoveFromFavorites(uid: String, cell: FavoritesCell) {
    guard let currentLoggedUserUID = Auth.auth().currentUser?.uid else { return }
    guard let indexPath = collectionView?.indexPath(for: cell) else { return }
    let reference = Database.database().reference().child("favorites").child(currentLoggedUserUID).child(uid)
    reference.removeValue { (err, ref) in
      if err != nil {
        print(err ?? "")
        return
      }
      
      self.masters.remove(at: indexPath.item)
      self.collectionView?.deleteItems(at: [indexPath])
    }
    
  }
  
}
