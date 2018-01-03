//
//  ClientOrdersController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

class ClientOrdersController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
  
  let pengdingCellId = "pendingCellId"
  let confirmedCellId = "confirmedCellId"
  
  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = .white
    cv.dataSource = self
    cv.delegate = self
    cv.showsHorizontalScrollIndicator = false
    return cv
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    navigationItem.title = "Заявки"
    
    setupMenuBar()
    setupCollection()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = false
    navigationController?.navigationBar.barTintColor = UIColor(r: 247, g: 247, b: 247, a: 1)
    navigationController?.navigationBar.isTranslucent = false
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
  }
  
  lazy var menuBar: MenuBar = {
    let mb = MenuBar()
    mb.clientOrdersController = self
    return mb
  }()
  
  private func setupMenuBar() {
    view.addSubview(menuBar)
    menuBar.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
  }
  
  private func setupCollection() {
    collectionView.isPagingEnabled = true
    collectionView.backgroundColor = .white
    collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 8, right: 0)
    collectionView.register(MenuBarPendingCell.self, forCellWithReuseIdentifier: pengdingCellId)
    collectionView.register(MenuBarConfirmedCell.self, forCellWithReuseIdentifier: confirmedCellId)
    view.addSubview(collectionView)
    collectionView.anchor(top: menuBar.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
  }

  
  func scrollToMenuIndex(_ menuIndex: Int) {
    let indexPath = IndexPath(item: menuIndex, section: 0)
    collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
  }
  
  fileprivate func setupNavigationBarTitleView() {
    navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2").withRenderingMode(.alwaysOriginal))
  }
  
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 2
  }
  
   func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if indexPath.item == 0 {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pengdingCellId, for: indexPath) as! MenuBarPendingCell
      cell.clientOrdersController = self
      return cell
    } else {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: confirmedCellId, for: indexPath) as! MenuBarConfirmedCell
      cell.clientOrdersController = self
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width, height: view.frame.height - 50)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
   func scrollViewDidScroll(_ scrollView: UIScrollView) {
    menuBar.horizontalBarLeftAnchorConstraint?.constant = scrollView.contentOffset.x / 2
  }
  
   func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    
    let index = targetContentOffset.pointee.x / view.frame.width
    
    let indexPath = IndexPath(item: Int(index), section: 0)
    menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
  }
  
}

