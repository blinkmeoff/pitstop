//
//  CarPickerController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit

class CarPickerController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
  
  let cellId = "cellId"
  var filteredCars = [Car]()
  var cars = [Car]()
  
  var clientProfileController: ClientProfileController?
  var clientDetailsController: ClientDetailsController?
  
  lazy var searchBar: UISearchBar = {
    let sb = UISearchBar()
    sb.placeholder = "Введите марку машины"
    sb.barTintColor = .gray
    UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
    sb.delegate = self
    return sb
  }()
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
    if searchText.isEmpty {
      filteredCars = cars
    } else {
      filteredCars = self.cars.filter { (car) -> Bool in
        return car.mark.lowercased().contains(searchText.lowercased())
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
    
    collectionView?.register(CarPickerCell.self, forCellWithReuseIdentifier: cellId)
    
    collectionView?.alwaysBounceVertical = true
    collectionView?.keyboardDismissMode = .onDrag
    fetchCars()
  }
  
  func fetchCars() {
    var carsPlist: NSDictionary?
    
    if let path = Bundle.main.path(forResource: "Cars", ofType: "plist") {
      carsPlist = NSDictionary(contentsOfFile: path)
    }
    
    if let root = carsPlist {
      let carsDictionary = root.object(forKey: "Cars")
      
      if let carsDict = carsDictionary as? NSDictionary {
        for (key, value) in carsDict {
          guard let carName = key as? String else { return }
          var carModels = [String]()
          
          if let models = value as? [String] {
            for carModel in models {
              carModels.append(carModel)
            }
          }
          self.cars.append(Car(mark: carName, model: "", models: carModels))
          
        }
      }
    }
    self.cars = self.cars.sorted{$0.mark.localizedCaseInsensitiveCompare($1.mark) == ComparisonResult.orderedAscending}
    self.filteredCars = self.cars
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
    
    let car = filteredCars[indexPath.item]
    
    if clientProfileController != nil {
      let carModelPickerController = CarModelPickerController(collectionViewLayout: UICollectionViewFlowLayout())
      carModelPickerController.carMark = car.mark
      carModelPickerController.delegate = clientProfileController
      carModelPickerController.models = car.models!
      
      navigationController?.pushViewController(carModelPickerController, animated: true)
      return
    }
    
    clientDetailsController?.carMarkTextField.text = car.mark
    clientDetailsController?.carModelTextField.text = ""
    clientDetailsController?.models = car.models
    clientDetailsController?.handleTextInputChange()

    dismiss(animated: true, completion: nil)
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filteredCars.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CarPickerCell
    
    cell.car = filteredCars[indexPath.item]
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width, height: 44)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
}
