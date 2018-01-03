//
//  MasterHomeController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class MasterHomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  let cellId = "cellId"
  let footerId = "footerId"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView?.backgroundColor = .white
    setupNavigationBarTitleView()
    setupCollectionView()
    fetchOrders()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = false
  }
  
  private func setupCollectionView() {
    collectionView?.alwaysBounceVertical = true
    collectionView?.register(OrderCell.self, forCellWithReuseIdentifier: cellId)
    collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerId)
    collectionView?.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
  }
  
  var orders = [Order]()
  var ordersDictionary = [String: Order]()
  
  private func fetchOrders() {
    let ref = Database.database().reference().child("orders")
    ref.observe(.childAdded, with: { (snapshot) in
      
      guard let dictionary = snapshot.value as? [String: Any] else { return }
      
      let order = Order(dictionary: dictionary)
      if order.status == "pending" {
        self.ordersDictionary[snapshot.key] = order
      }
      
      self.attemptReloadOfTable()

    }) { (err) in
      print("Failed to fetch posts:", err)
    }
  }
  
  var timer: Timer?
  
  fileprivate func attemptReloadOfTable() {
    self.timer?.invalidate()
    
    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
  }
  
  @objc func handleReloadTable() {
    self.orders = Array(self.ordersDictionary.values)
    self.orders.sort(by: { (o1, o2) -> Bool in
      return o1.creationDate.compare(o2.creationDate) == .orderedDescending
    })
    
    //this will crash because of background thread, so lets call this on dispatch_async main thread
    DispatchQueue.main.async(execute: {
      self.collectionView?.reloadData()
    })
  }
  
  fileprivate func setupNavigationBarTitleView() {
    navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2").withRenderingMode(.alwaysOriginal))
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return orders.count
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return orders.isEmpty ? CGSize(width: view.frame.width, height: collectionView.frame.height - 60 - 40 - 4) : .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 100)
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! OrderCell
    cell.order = orders[indexPath.item]
    cell.masterHomeController = self
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerId, for: indexPath)
    
    setupFooterCell(cell: footer)
    
    return footer
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let order = orders[indexPath.item]
    
    var foundKey = ""
    for (_, value) in self.ordersDictionary.enumerated() {
      if value.value == order {
        foundKey = value.key
      }
    }
    
    let orderDetailsController = OrderDetailsController(collectionViewLayout: UICollectionViewFlowLayout())
    orderDetailsController.order = order
    orderDetailsController.key = foundKey
    let navController = UINavigationController(rootViewController: orderDetailsController)
    present(navController, animated: true, completion: nil)
  }
  
  private func setupFooterCell(cell: UICollectionReusableView) {
    let noOrdersLabel = UILabel()
    noOrdersLabel.text = "Нет обьявлений"
    noOrdersLabel.textColor = .lightGray
    noOrdersLabel.textAlignment = .center
    noOrdersLabel.font = UIFont.systemFont(ofSize: 17)
    cell.addSubview(noOrdersLabel)
    noOrdersLabel.fillSuperview()
  }
  
  lazy var zoomImageView: ZoomImageView = {
    let zoom = ZoomImageView()
    zoom.masterHomeController = self
    return zoom
  }()
  
  //zoom image
  func performZoomForStartingImageView(startingImageView: UIImageView) {
    zoomImageView.performZoomImageView(startingImageView: startingImageView)
  }
}
