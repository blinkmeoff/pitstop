//
//  MenuBarConfirmedCell.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.12.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents



class MenuBarConfirmedCell: BaseCell, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
  
  let cellId = "cellId"
  let footerId = "footerId"
  var clientOrdersController: ClientOrdersController?
  
  var confirmedOrders = [ConfirmedOrder]()
  var confirmedOrdersDictionary = [String: ConfirmedOrder]()
  
  override func setupUI() {
    super.setupUI()
    
    setupCollectionView()
    fetchPendingOrders()
  }
  
  private func fetchPendingOrders() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    let ref = Database.database().reference().child("orders-confirmed").child(uid)
    ref.observe(.childAdded, with: { (snapshot) in
      
      guard let dictionary = snapshot.value as? [String: Any] else { return }
      self.confirmedOrdersDictionary[snapshot.key] = ConfirmedOrder(dictionary: dictionary)
      
      self.attemptReloadOfTable()

    }, withCancel: nil)
  }
  
  var timer: Timer?
  
  fileprivate func attemptReloadOfTable() {
    self.timer?.invalidate()
    
    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
  }
  
  @objc func handleReloadTable() {
    self.confirmedOrders = Array(self.confirmedOrdersDictionary.values)
    //this will crash because of background thread, so lets call this on dispatch_async main thread
    DispatchQueue.main.async(execute: {
      self.collectionView.reloadData()
    })
  }
  
  
  private func setupCollectionView() {
    collectionView.register(ConfirmedOrderCell.self, forCellWithReuseIdentifier: cellId)
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
    return confirmedOrders.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ConfirmedOrderCell
    cell.confirmedOrder = confirmedOrders[indexPath.item]
    cell.menuBarConfirmedCell = self
    cell.delegate = self
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: 50)
    
    let dummyCell = ConfirmedOrderCell(frame: frame)
    if let cell = collectionView.cellForItem(at: indexPath) as? ConfirmedOrderCell {
      dummyCell.order = cell.order
    }
    dummyCell.layoutIfNeeded()
    
    let targetSize = CGSize(width: collectionView.frame.width, height: 1000)
    let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
    
    let height = max(100, estimatedSize.height)
    return CGSize(width: collectionView.frame.width, height: height)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return confirmedOrders.isEmpty ? CGSize(width: frame.width, height: collectionView.frame.height - 60 - 40) : .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerId, for: indexPath)
    
    setupFooterCell(cell: footer)
    
    return footer
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let confirmedOrderDetailsController = ConfirmedOrderDetailsController(collectionViewLayout: UICollectionViewFlowLayout())
    confirmedOrderDetailsController.orderUID = confirmedOrders[indexPath.item].orderUID
    confirmedOrderDetailsController.masterUID = confirmedOrders[indexPath.item].masterUID
    clientOrdersController?.navigationController?.pushViewController(confirmedOrderDetailsController, animated: true)
    clientOrdersController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    clientOrdersController?.navigationItem.backBarButtonItem?.tintColor = .black
  }
  
  private func setupFooterCell(cell: UICollectionReusableView) {
    let noMessagesLabel = UILabel()
    noMessagesLabel.text = "Нет подтвержденных заказов"
    noMessagesLabel.textColor = .lightGray
    noMessagesLabel.textAlignment = .center
    noMessagesLabel.font = UIFont.systemFont(ofSize: 17)
    cell.addSubview(noMessagesLabel)
    noMessagesLabel.fillSuperview()
  }
  
  private func getKeyForCell(_ cell: ConfirmedOrderCell) -> String {
    var foundKey = ""
    for (_, value) in self.confirmedOrdersDictionary.enumerated() {
      if value.value == cell.confirmedOrder {
        foundKey = value.key
      }
    }
    
    return foundKey
  }
}


extension MenuBarConfirmedCell: ConfirmedOrderCellDelegate {
  
  func sendFeedback(cell: ConfirmedOrderCell) {
    clientOrdersController?.presentConfirmAlert(message: nil, title: "Вы уверенны, что хотите отметить работу мастера, как - выполненную?", completion: { (isCompleted) in
      if isCompleted {
        let feedbackController = FeedbackController()
        guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
        feedbackController.item = indexPath.item
        feedbackController.menuBarConfirmedCell = self
        feedbackController.confirmedOrder = cell.confirmedOrder
        feedbackController.key = self.getKeyForCell(cell)
        let navController = UINavigationController(rootViewController: feedbackController)
        self.clientOrdersController?.present(navController, animated: true, completion: nil)
      }
    })
  }
}
