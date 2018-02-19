//
//  ConfirmedOrderDetailsController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.01.18.
//  Copyright © 2018 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class ConfirmedOrderDetailsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  var masterUID: String? {
    didSet {
      guard masterUID != nil else { return }
      let masterButton = UIBarButtonItem(title: "Мастер", style: .plain, target: self, action: #selector(viewMasterProfile))
      masterButton.tintColor = .black
      navigationItem.rightBarButtonItem = masterButton
    }
  }
  
  @objc private func viewMasterProfile() {
    guard let masterUID = masterUID else { return }
    let masterProfileController = MasterProfileController(collectionViewLayout: UICollectionViewFlowLayout())
    masterProfileController.userId = masterUID
    tabBarController?.tabBar.isHidden = true
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    navigationController?.navigationBar.tintColor = .black
    navigationController?.pushViewController(masterProfileController, animated: true)
  }
  
  var order: Order? {
    didSet {
      setupImagesArray()
    }
  }
  var orderUID: String? {
    didSet {
      fetchOrder()
    }
  }
  
  private func fetchOrder() {
    guard let orderId = orderUID else { return }
    let ref = Database.database().reference().child("orders").child(orderId)
    ref.observeSingleEvent(of: .value) { (snapshot) in
      guard let dictionary = snapshot.value as? [String: Any] else { return }
      self.order = Order(dictionary: dictionary)
    }
  }
  
  var orderImages = [String]()
  
  let cellId = "cellId"
  let headerId = "headerId"
 
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    setupImagesArray()
    setupUI()
  }
  
  private func setupNavBar() {
    title = "Заказ"
    let closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleDismiss))
    closeButton.tintColor = .black
    navigationItem.leftBarButtonItem = closeButton
  }
  
  
  @objc private func handleDismiss() {
    dismiss(animated: true, completion: nil)
  }
  
  private func setupUI() {
    
    if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.scrollDirection = .vertical
      layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    collectionView?.alwaysBounceVertical = true
    collectionView?.backgroundColor = .white
    collectionView?.isScrollEnabled = true
    collectionView?.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 60, right: 8)
    collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
    collectionView?.register(OrderDetailsCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
    collectionView?.register(OrderImageCell.self, forCellWithReuseIdentifier: cellId)
    
  }
  
  
  private func setupImagesArray() {
    guard var orderImages = order?.imageURLS?.components(separatedBy: ",") else { return }
    if orderImages.last == "" {
      orderImages.removeLast()
    }
    self.orderImages = orderImages
    self.collectionView?.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = true
  }
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return orderImages.count
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    let frame = CGRect(x: 0, y: 0, width: view.frame.width - 8 - 8, height: 50)
    let orderDetailsCell = OrderDetailsCell(frame: frame)
    
    orderDetailsCell.order = self.order
    orderDetailsCell.layoutIfNeeded()
    
    let targetSize = CGSize(width: view.frame.width - 8 - 8, height: 1000)
    let estimatedSize = orderDetailsCell.systemLayoutSizeFitting(targetSize)
    
    let height = max(50, estimatedSize.height)
    return CGSize(width: view.frame.width - 8 - 8, height: height)
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! OrderDetailsCell
    header.order = order
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let height = (view.frame.width - 16) * 9 / 16
    return CGSize(width: view.frame.width, height: height + 16)
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! OrderImageCell
    cell.imageURL = orderImages[indexPath.item]
    return cell
  }
  
  
  
}
