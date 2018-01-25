//
//  OrderDetailsControlelr.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.12.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class OrderDetailsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  var activeOrdersController: ActiveOrdersController? {
    didSet {
      self.applyButton.isHidden = true
      navigationItem.rightBarButtonItem = nil
    }
  }
  var masterHomeController: MasterHomeController?
  var item: Int?
  var key: String?
  var order: Order? {
    didSet {
      guard let order = order else { return }
      setupNavBar()

      let titleString = order.masterApplied ? "УДАЛИТЬ ЗАЯВКУ" : "ПОДАТЬ ЗАЯВКУ"
      
      let attributedTitle = NSAttributedString(string: titleString, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: UIColor.white])
      self.applyButton.setAttributedTitle(attributedTitle, for: .normal)
    }
  }
  var orderImages = [String]()
  
  let cellId = "cellId"
  let headerId = "headerId"
  
  lazy var applyButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = Settings.Color.pink
    button.setTitleColor(.white, for: .normal)
    button.addTarget(self, action: #selector(handleApply), for: .touchUpInside)
    return button
  }()
  
  private func handleDelete() {
    guard let masterUID = Auth.auth().currentUser?.uid else { return }
    guard let orderUID = self.key else { return }
    LoadingIndicator.shared.show()
    let ref = Database.database().reference().child("master-applied-to-orders").child(masterUID).child(orderUID)
    
    ref.removeValue { (err, reference) in
      if err != nil {
        print(err ?? "")
        LoadingIndicator.shared.hide()
        self.showAlert(with: "Не удалось удалить заявку, попробуйте позже")
        return
      }
      
      self.removeFromApliedOrders(orderID: orderUID, masterID: masterUID)
    }
  }
  
  private func removeFromApliedOrders(orderID: String, masterID: String) {
    let ref = Database.database().reference().child("users-applied-to-orders").child(orderID).child(masterID)
    
    ref.removeValue { (err, reference) in
      if err != nil {
        print(err ?? "")
        LoadingIndicator.shared.hide()
        self.showAlert(with: "Не удалось удалить заявку, попробуйте позже")
        return
      }
      
      if let item = self.item {
        if let index = self.masterHomeController?.appliedOrders.index(of: orderID) {
          self.masterHomeController?.appliedOrders.remove(at: index)
        }
        
        self.masterHomeController?.orders[item].masterApplied = false
        self.masterHomeController?.collectionView?.reloadData()
      }
      
      LoadingIndicator.shared.hide()
      self.showAlert(with: "Вы успешно удалили заявку", completion: {
        self.dismiss(animated: true, completion: nil)
      })
    }
  }
  
  @objc private func handleApply() {
    if let alreadyApplied = order?.masterApplied {
      if alreadyApplied {
        handleDelete()
        return
      }
    }
    
    presentConfirmAlert(message: "Не желаете ли Вы оставить клиенту комментарий?", title: nil) { (shouldLeaveComment) in
      if shouldLeaveComment {
        let quoteCommentController = QuoteCommentController()
        quoteCommentController.orderDetailsController = self
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.pushViewController(quoteCommentController, animated: true)
      } else {
        self.sendQuote(with: nil)
      }
    }
  }
  
  func sendQuote(with message: String?) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    guard let orderUID = self.key else { return }
    let ref = Database.database().reference().child("users-applied-to-orders").child(orderUID).child(uid)
    LoadingIndicator.shared.show()
    
    let timestamp = Int(Date().timeIntervalSince1970)
    var values = ["creationDate": timestamp] as [String: Any]
    
    if let msg = message, msg.count > 0 {
      values["comment"] = msg
    }
    
    ref.updateChildValues(values) { (err, reference) in
      if err != nil {
        print(err ?? "")
        LoadingIndicator.shared.hide()
        self.showAlert(with: "Не удалось подать заявку, попробуйте позже")
        return
      }
      
      self.saveMasterApply(to: orderUID)
    }
  }
  
  private func saveMasterApply(to order: String) {
    guard let masterUID = Auth.auth().currentUser?.uid else { return }
    guard let orderUID = self.key else { return }
    let ref = Database.database().reference().child("master-applied-to-orders").child(masterUID)
    
    ref.updateChildValues([orderUID:1]) { (err, reference) in
      if err != nil {
        print(err ?? "")
        LoadingIndicator.shared.hide()
        self.showAlert(with: "Не удалось подать заявку, попробуйте позже")
        return
      }
      
      LoadingIndicator.shared.hide()
      self.showAlert(with: "Вы успешно подали заявку на эту работу, Вы получите оповещение если клиент согласится на Ваши услуги", completion: {
        self.dismiss(animated: true, completion: nil)
      })
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    setupImagesArray()
    setupUI()
    masterViewdOrder()
  }
  
  private func masterViewdOrder() {
    
    guard let key = self.key else { return }
    let refTran = Database.database().reference().child("order-views").child(key)
    refTran.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
      if var viewsCountDictionary = currentData.value as? [String : Any] {
        if let count = viewsCountDictionary["views"] as? Int {
          viewsCountDictionary["views"] = count + 1
          currentData.value = viewsCountDictionary
          return TransactionResult.success(withValue: currentData)
        }
      } else {
        let data = ["views": 1] as [String: Any]
        currentData.value = data
        return TransactionResult.success(withValue: currentData)
      }
      return TransactionResult.success(withValue: currentData)

    }) { (err, commited, snapshot) in
      if let error = err {
        print(error.localizedDescription)
      }
    }
  }

  var carButton: UIBarButtonItem?
  
  private func setupNavBar() {
    title = "Заказ"
    let closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleDismiss))
    closeButton.tintColor = .black
    navigationItem.leftBarButtonItem = closeButton
    
    carButton = UIBarButtonItem(image: #imageLiteral(resourceName: "car"), style: .plain, target: self, action: #selector(handleShowCar))
    carButton?.tintColor = .black
    navigationItem.rightBarButtonItem = carButton
  }
  
  
  @objc private func handleShowCar() {
    guard let order = self.order else { return }
    guard let orderOwnerId = order.ownerId else { return }
    let carId = order.carId
    
    if carId.isEmpty {
      showAlert(with: "Информация об атомобиле недоступна")
      return
    }
    
    LoadingIndicator.shared.show()
    
    let ref = Database.database().reference().child("cars").child(orderOwnerId).child(carId)
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
      LoadingIndicator.shared.hide()
      
      guard let dictionary = snapshot.value as? [String: Any] else { return }
      let car = Car(dictionary: dictionary, id: "")
      
      let updateCarController = UpdateCarController()
      updateCarController.car = car
      updateCarController.isMasterViewing = true
      self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
      self.navigationController?.navigationBar.tintColor = .black
      self.navigationController?.pushViewController(updateCarController, animated: true)
    }) { (err) in
      print(err)
      LoadingIndicator.shared.hide()
      self.showAlert(with: "Не удалось загрузить данные об автомобиле")
    }
   
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
    
    view.addSubview(applyButton)
    applyButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 60)
  }
  
  
  private func setupImagesArray() {
    guard var orderImages = order?.imageURLS?.components(separatedBy: ",") else { return }
    if orderImages.last == "" {
      orderImages.removeLast()
    }
    self.orderImages = orderImages
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
