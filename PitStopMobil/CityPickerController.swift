//
//  CityPickerController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit

class CityPickerController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
  
  let cellId = "cellId"
  var filteredCities = [String]()
  var cities = ["Винницкая область",
                "Волынская область",
                "Днепропетровская область",
                "Донецкая область",
                "Житомирская область",
                "Закарпатская область",
                "Запорожская область",
                "Ивано-Франковская область",
                "Киевская область",
                "Кировоградская область",
                "Луганская область",
                "Львовская область",
                "Николаевская область",
                "Одесская область",
                "Полтавская область",
                "Ровненская область",
                "Сумская область",
                "Тернопольская область",
                "Харьковская область",
                "Херсонская область",
                "Хмельницкая область",
                "Черкасская область",
                "Черниговская область",
                "Черновицкая область"]
  
  var masterDetailsController: MasterDetailsController?
  
  lazy var searchBar: UISearchBar = {
    let sb = UISearchBar()
    sb.placeholder = "Введите область"
    sb.barTintColor = .gray
    UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
    sb.delegate = self
    return sb
  }()
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
    if searchText.isEmpty {
      filteredCities = cities
    } else {
      filteredCities = self.cities.filter { (city) -> Bool in
        return city.lowercased().contains(searchText.lowercased())
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
    
    collectionView?.register(CityPickerCell.self, forCellWithReuseIdentifier: cellId)
    
    collectionView?.alwaysBounceVertical = true
    collectionView?.keyboardDismissMode = .onDrag
    sortCities()
  }
  
  
  fileprivate func sortCities() {
    self.cities = self.cities.sorted{$0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending}
    self.filteredCities = self.cities
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
    
    let city = filteredCities[indexPath.item]
    masterDetailsController?.cityTextField.text = city
    dismiss(animated: true, completion: nil)
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filteredCities.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CityPickerCell
    
    cell.city = filteredCities[indexPath.item]
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width, height: 44)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
}
