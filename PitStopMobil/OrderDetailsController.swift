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
  
  var key: String?
  var order: Order?
  var orderImages = [String]()
  
  let cellId = "cellId"
  let headerId = "headerId"
  
  lazy var applyButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = Settings.Color.pink
    
    let attributedTitle = NSAttributedString(string: "ПОДАТЬ ЗАЯВКУ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: UIColor.white])
    button.setAttributedTitle(attributedTitle, for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.addTarget(self, action: #selector(handleApply), for: .touchUpInside)
    return button
  }()
  
  @objc private func handleApply() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    guard let key = self.key else { return }
    let ref = Database.database().reference().child("user-applied-to-orders").child(key)
    ref.updateChildValues([uid: 1]) { (err, reference) in
      if err != nil {
        print(err ?? "")
        self.showAlert(with: "Не удалось подать заявку, попробуйте позже")
        return
      }
     
      self.showAlert(with: "Вы успешно подали заявку на эту работу, Вы получите оповещение если клиент согласится на Ваши услуги", completion: {
        self.dismiss(animated: true, completion: nil)
      })
      
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    setupNavBar()
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
