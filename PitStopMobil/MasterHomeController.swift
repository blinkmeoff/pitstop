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
  var appliedOrders = [String]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView?.backgroundColor = .white
    setupNavigationBarTitleView()
    setupCollectionView()
    fetchMasterAppliedOrders()
  }
  
  lazy var refreshControl: UIRefreshControl = {
    let rc = UIRefreshControl()
    rc.tintColor = .black
    rc.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    return rc
  }()
  
  @objc func handleRefresh() {
    appliedOrders.removeAll()
    orders.removeAll()
    ordersDictionary.removeAll()
    fetchMasterAppliedOrders()
  }
  
  
  
  private func fetchMasterAppliedOrders() {
    guard let masterUID = Auth.auth().currentUser?.uid else { return }
    let ref = Database.database().reference().child("master-applied-to-orders").child(masterUID)
    
    ref.observe(.value) { (snapshot) in
      
      if let dictionaries = snapshot.value as? [String: Any] {
        for dictionary in dictionaries.keys {
          self.appliedOrders.append(dictionary)
        }
      }
      self.fetchOrders()
      
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = false
    collectionView?.reloadData()
  }
  
  private func setupCollectionView() {
    collectionView?.alwaysBounceVertical = true
    collectionView?.refreshControl = refreshControl
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
      
      let order = Order(dictionary: dictionary, masterApplied: false)
      if order.status == "pending" {
        if self.appliedOrders.contains(where: {$0 == snapshot.key}) {
          order.masterApplied = true
        }
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
    self.refreshControl.endRefreshing()
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
    let frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: 50)
    
    let dummyCell = OrderCell(frame: frame)
    dummyCell.order = orders[indexPath.item]
    dummyCell.layoutIfNeeded()
    
    let targetSize = CGSize(width: collectionView.frame.width, height: 1000)
    let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
    
    let height = max(102, estimatedSize.height)
    return CGSize(width: collectionView.frame.width, height: height)
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
    orderDetailsController.masterHomeController = self
    orderDetailsController.item = indexPath.item
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
