//
//  CarModelPickerController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit

protocol CarModelPickerDelegate {
  func didPickModel(carMark: String, carModel: String)
}

class CarModelPickerController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
  
  var carMark: String?
  let cellId = "cellId"
  var filteredModels = [String]()
  var models = [String]()
  
  var clientDetailsController: ClientDetailsController?
  var delegate: CarModelPickerDelegate?
  
  lazy var searchBar: UISearchBar = {
    let sb = UISearchBar()
    sb.placeholder = "Введите модель машины"
    sb.barTintColor = .gray
    UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
    sb.delegate = self
    return sb
  }()
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
    if searchText.isEmpty {
      filteredModels = models
    } else {
      filteredModels = self.models.filter { (model) -> Bool in
        return model.lowercased().contains(searchText.lowercased())
      }
    }
    
    self.collectionView?.reloadData()
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView?.backgroundColor = .white
    
    navigationController?.navigationBar.addSubview(searchBar)
    
    let navBar = navigationController?.navigationBar
    
    searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
    
    collectionView?.register(CarModelPickerCell.self, forCellWithReuseIdentifier: cellId)
    
    collectionView?.alwaysBounceVertical = true
    collectionView?.keyboardDismissMode = .onDrag
    sortCarModels()
  }
  
  fileprivate func sortCarModels() {
    self.models = self.models.sorted{$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
    self.filteredModels = self.models
    collectionView?.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    searchBar.isHidden = false
    searchBar.becomeFirstResponder()
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    searchBar.isHidden = true
    searchBar.resignFirstResponder()
    
    if carMark != nil {
      guard let mark = self.carMark else { return }
      let model = filteredModels[indexPath.item]
      dismiss(animated: true, completion: {
        self.delegate?.didPickModel(carMark: mark, carModel: model)
      })
      return
    }
    
    let model = filteredModels[indexPath.item]
    clientDetailsController?.carModelTextField.text = model
    clientDetailsController?.handleTextInputChange()
    dismiss(animated: true, completion: nil)
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filteredModels.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CarModelPickerCell
    
    cell.model = filteredModels[indexPath.item]
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width, height: 44)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
}
