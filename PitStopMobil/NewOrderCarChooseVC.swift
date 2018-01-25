//
//  NewOrderCarChooseVC.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.01.18.
//  Copyright © 2018 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class NewOrderCarChooseVC: UICollectionViewController {
  
  let cellId = "cellId"
  let headerId = "headerId"
  var cars = [Car]()
  var selectedSkills = [String]()
  var client: Client?
  
  var selectedCar: Car?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupNavBar()
    setupCollection()
    setupUI()
    fetchCars()
  }
  
  private func setupNavBar() {
    navigationItem.title = "Новая Заявка"
    let leftCancelButton = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(handlePop))
    leftCancelButton.tintColor = .black
    navigationItem.leftBarButtonItem = leftCancelButton
  }
  
  @objc private func handlePop() {
    _ = navigationController?.popToRootViewController(animated: true)
  }
  
  func fetchCars() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    cars.removeAll()
    Database.database().reference().child("cars").child(uid).observe(.childAdded , with: { (snapshot) in
      
      guard let carsDictionary = snapshot.value as? [String: Any] else { return }
      let carId = snapshot.key
      
      let car = Car(dictionary: carsDictionary, id: carId)
      print(carId)
      self.cars.append(car)
      
      DispatchQueue.main.async {
        self.collectionView?.reloadData()
      }
      
    }) { (err) in
      print("Failed to fetch user for posts:", err)
    }
  }
  
  private func setupCollection() {
    collectionView?.backgroundColor = .white
    collectionView?.register(NewOrderCarChooseCell.self, forCellWithReuseIdentifier: cellId)
    collectionView?.register(NewOrderCarChooseHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
  }
  
  lazy var nextButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = Settings.Color.disabledPink
    
    let attributedTitle = NSAttributedString(string: "ДАЛЕЕ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: UIColor.white])
    button.setAttributedTitle(attributedTitle, for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.isEnabled = false
    button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
    return button
  }()
  
  @objc private func handleNext() {
    let newOrderInfoConroller = NewOrderInfoController()
    newOrderInfoConroller.client = client
    newOrderInfoConroller.selectedSkills = self.selectedSkills
    newOrderInfoConroller.car = self.selectedCar
    navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain
      , target: self, action: nil)
    navigationController?.pushViewController(newOrderInfoConroller, animated: true)
  }
  
  private func setupUI() {
    view.addSubview(nextButton)
    nextButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 00, paddingRight: 0, width: 0, height: 50)
  }
  
}

extension NewOrderCarChooseVC: UICollectionViewDelegateFlowLayout {
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NewOrderCarChooseCell
    cell.car = cars[indexPath.item]
    return cell
  }
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! NewOrderCarChooseHeader
    
    return header
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: view.frame.width, height: 150)
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return cars.count
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width, height: 100)
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let car = cars[indexPath.row]
    selectedCar = car
    nextButton.isEnabled = true
    nextButton.backgroundColor = Settings.Color.pink
  }
  
}





class NewOrderCarChooseHeader: BaseCell {
  
  let chooseLabel: UILabel = {
    let label = UILabel()
    label.text = "Выберите автомобиль"
    label.textColor = .black
    label.font = UIFont.boldSystemFont(ofSize: 17)
    label.numberOfLines = 0
    label.textAlignment = .center
    return label
  }()
  
  override func setupUI() {
    super.setupUI()
    addSubview(chooseLabel)
    chooseLabel.fillSuperview()
  }
  
}
