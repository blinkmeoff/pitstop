//
//  MenuBarPendingCell.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.12.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

class MenuBarPendingCell: BaseCell, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
  
  let cellId = "cellId"
  let footerId = "footerId"
  var clientOrdersController: ClientOrdersController?
  
  var ordersDictionary = [String: Order]()
  var orders = [Order]()
  
  override func setupUI() {
    super.setupUI()
    
    setupCollectionView()
    fetchPendingOrders()
  }
  
  private func fetchPendingOrders() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    let ref = Database.database().reference().child("user-orders").child(uid)
    ref.observe(.childAdded, with: { (snapshot) in
      
      let orderId = snapshot.key
      Database.database().reference().child("orders").child(orderId).observeSingleEvent(of: .value, with: { (snapshot) in
        guard let dictionary = snapshot.value as? [String: Any] else { return }
        let order = Order(dictionary: dictionary)
        self.ordersDictionary[snapshot.key] = order
        self.fetchMastersApliedToOrder(snapshot.key)
        self.fetchViewsCountFor(snapshot.key)
      })

    }, withCancel: nil)
  }
  
  
  
  private func fetchViewsCountFor(_ key: String) {
    //implement
    let ref = Database.database().reference().child("order-views").child(key)
    ref.observe(.value) { (snapshot) in
      guard let dictionary = snapshot.value as? [String: Any] else { return }
      let value = dictionary["views"] as? Int ?? 0
      self.ordersDictionary[key]?.views = String(value)
      self.attemptReloadOfTable()
    }
  }
  
  private func fetchMastersApliedToOrder(_ key: String) {
    //implement
    let ref = Database.database().reference().child("users-applied-to-orders").child(key)
    ref.observe(.value) { (snapshot) in
      let mastersCount = String(snapshot.childrenCount)
      self.ordersDictionary[key]?.mastersAppliedCount = mastersCount
      self.attemptReloadOfTable()
    }
  }
  
  var timer: Timer?
  
  fileprivate func attemptReloadOfTable() {
    self.timer?.invalidate()
    
    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
  }
  
  @objc func handleReloadTable() {
    self.orders = Array(self.ordersDictionary.values)
    self.orders.sort(by: { (order1, order2) -> Bool in
      return order1.creationDate > order2.creationDate
    })
    
    //this will crash because of background thread, so lets call this on dispatch_async main thread
    DispatchQueue.main.async(execute: {
      self.collectionView.reloadData()
    })
  }
  
  
  private func setupCollectionView() {
    collectionView.register(PendingOrderCell.self, forCellWithReuseIdentifier: cellId)
    collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerId)
    collectionView.backgroundColor = .white
    addSubview(collectionView)
    collectionView.fillSuperview()
  }
  
  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = UIColor.white
    cv.dataSource = self
    cv.delegate = self
    return cv
  }()
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return orders.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PendingOrderCell
    let order = orders[indexPath.item]
    
    cell.order = order
    cell.delegate = self
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

    let frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: 50)
    let dummyCell = PendingOrderCell(frame: frame)
    dummyCell.order = orders[indexPath.item]
    dummyCell.layoutIfNeeded()
    
    let targetSize = CGSize(width: collectionView.frame.width, height: 1000)
    let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)

    let height = max(100, estimatedSize.height)
    return CGSize(width: collectionView.frame.width, height: height)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return orders.isEmpty ? CGSize(width: frame.width, height: collectionView.frame.height - 60 - 40) : .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerId, for: indexPath)
    
    setupFooterCell(cell: footer)
    
    return footer
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    guard let cell = collectionView.cellForItem(at: indexPath) as? PendingOrderCell else { return }
    
    var foundKey = ""
    for (_, value) in self.ordersDictionary.enumerated() {
      if value.value == cell.order {
        foundKey = value.key
      }
    }
    
    let apliedMastersController = ApliedMastersController(collectionViewLayout: UICollectionViewFlowLayout())
    apliedMastersController.key = foundKey
    apliedMastersController.item = indexPath.item
    apliedMastersController.menuBarPendingCell = self
    apliedMastersController.clientOrdersController = clientOrdersController
    clientOrdersController?.navigationController?.pushViewController(apliedMastersController, animated: true)
    clientOrdersController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    clientOrdersController?.navigationItem.backBarButtonItem?.tintColor = .black
  }
  
  private func setupFooterCell(cell: UICollectionReusableView) {
    let noMessagesLabel = UILabel()
    noMessagesLabel.text = "Нет ожидающих заявок"
    noMessagesLabel.textColor = .lightGray
    noMessagesLabel.textAlignment = .center
    noMessagesLabel.font = UIFont.systemFont(ofSize: 17)
    cell.addSubview(noMessagesLabel)
    noMessagesLabel.fillSuperview()
  }
  
  
  private func getKeyForOrder(order: Order) -> String {
    var foundKey = ""
    for (_, value) in self.ordersDictionary.enumerated() {
      if value.value == order {
        foundKey = value.key
      }
    }
    return foundKey
  }
}


extension MenuBarPendingCell: PendingOrderCellDelegate {
  
  func didTapDeletePendingOrder(cell: PendingOrderCell) {
    
    self.clientOrdersController?.presentConfirmAlert(message: "Вы уверенны, что хотите удалить заявку?", title: nil, completion: { (completed) in
      if completed {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
        
        guard let order = cell.order else { return }
        let foundKey = self.getKeyForOrder(order: order)
        
        let ref = Database.database().reference().child("orders").child(foundKey)
        ref.removeValue(completionBlock: { (error, reference) in
          if error != nil {
            print(error ?? "")
            return
          }
          self.ordersDictionary.removeValue(forKey: foundKey)
          self.orders.remove(at: indexPath.item)
          self.collectionView.deleteItems(at: [indexPath])
          
          let userOrdersRef = Database.database().reference().child("user-orders").child(uid).child(foundKey)
          userOrdersRef.removeValue(completionBlock: { (err, reference) in
            if err != nil {
              print(err ?? "")
              return
            }
            
          })
        })
      }
    })
  }
  
 
}
