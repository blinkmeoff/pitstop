//
//  ActiveOrdersController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.12.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class ActiveOrdersController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  var orders = [Order]()
  var ordersDictionary = [String: Order]()
  
  let cellId = "cellId"
  let footerId = "footerId"
  
  var userId: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "Заказы"
    view.backgroundColor = .white
    addCloseButton()
    setupCollectionView()
    fetchOrders()
  }
  
  private func addCloseButton() {
    let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "close"), style: .plain, target: self, action: #selector(handleDismiss))
    backButton.tintColor = .black
    navigationItem.leftBarButtonItem = backButton
  }
  
  @objc private func handleDismiss() {
    dismiss(animated: true, completion: nil)
  }
  
  private func setupCollectionView() {
    collectionView?.backgroundColor = .white
    collectionView?.alwaysBounceVertical = true
    collectionView?.register(OrderCell.self, forCellWithReuseIdentifier: cellId)
    collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerId)
    collectionView?.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
  }
  
  private func fetchOrders() {
    guard let uid = userId else { return }

    let ref = Database.database().reference().child("order-open-for-master").child(uid)
    ref.observe(.childAdded, with: { (snapshot) in
      guard let dictionary = snapshot.value as? [String: Any] else { return }
      let order = dictionary["order"] as? String ?? ""
      
      let ref = Database.database().reference().child("orders").child(order)
      ref.observeSingleEvent(of: .value, with: { (snapshot) in
        guard let dictionary = snapshot.value as? [String: Any] else { return }
        
        let order = Order(dictionary: dictionary, masterApplied: true)
        if order.status == "confirmed" {
          self.ordersDictionary[snapshot.key] = order
        }
        self.attemptReloadOfTable()
      })
    }) { (err) in
        print(err)
    }
  }
  
  var timer: Timer?
  
  fileprivate func attemptReloadOfTable() {
    self.timer?.invalidate()
    
    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
  }
  
  @objc func handleReloadTable() {
    self.orders = Array(self.ordersDictionary.values)

    //this will crash because of background thread, so lets call this on dispatch_async main thread
    DispatchQueue.main.async(execute: {
      self.collectionView?.reloadData()
    })
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return orders.count
  }

  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return orders.isEmpty ? CGSize(width: collectionView.frame.width, height: collectionView.frame.height - 60) : .zero
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
    cell.shouldBlink = false
    cell.order = orders[indexPath.item]
    
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
    orderDetailsController.activeOrdersController = self
    orderDetailsController.key = foundKey
    let navController = UINavigationController(rootViewController: orderDetailsController)
    present(navController, animated: true, completion: nil)
  }
  
  private func setupFooterCell(cell: UICollectionReusableView) {
    let noOrdersLabel = UILabel()
    noOrdersLabel.text = "Нет заказов"
    noOrdersLabel.textColor = .lightGray
    noOrdersLabel.textAlignment = .center
    noOrdersLabel.font = UIFont.systemFont(ofSize: 17)
    cell.addSubview(noOrdersLabel)
    noOrdersLabel.fillSuperview()
  }
  
}
