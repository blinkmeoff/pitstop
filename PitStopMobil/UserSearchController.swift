//
//  UserSearchController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import LBTAComponents

extension UserSearchController: CLLocationManagerDelegate, GMSMapViewDelegate {
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedWhenInUse {
      
      locationManager.startUpdatingLocation()
      
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      
      googleMap.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
      
      locationManager.stopUpdatingLocation()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}

class UserSearchController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
  
  let cellId = "cellId"
  let locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    setupMap()
    setupCollectionView()
    setupNavBar()
    fetchUsers()
  }
  
  lazy var googleMap: GMSMapView = {
    let map = GMSMapView()
    map.delegate = self
    map.isMyLocationEnabled = true
    map.settings.zoomGestures = true
    map.padding = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
    return map
  }()
  
  
  fileprivate func setupMap() {
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
    
    view.addSubview(googleMap)
    googleMap.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    refreshControl.endRefreshing()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    searchBar.isHidden = false
    tabBarController?.tabBar.isHidden = false
  }
  
  lazy var searchBar: UISearchBar = {
    let sb = UISearchBar()
    sb.placeholder = "Введите имя мастера"
    sb.barTintColor = .gray
    UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
    sb.delegate = self
    return sb
  }()
  
  @objc func handleCancelSearch() {
    searchBar.resignFirstResponder()
    searchBar.text = ""
    self.searchBarRightAnchor?.constant = -8
    self.collectionView.alpha = 0

    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.navigationController?.navigationBar.layoutIfNeeded()
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
  lazy var cancelSearchButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Отмена", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.addTarget(self, action: #selector(handleCancelSearch), for: .touchUpInside)
    return button
  }()
  
  func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    self.filteredUsers = users
    self.collectionView.reloadData()
    
    self.searchBarRightAnchor?.constant = -80
    self.collectionView.alpha = 1
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.navigationController?.navigationBar.layoutIfNeeded()
      self.view.layoutIfNeeded()
    }, completion: nil)
    
    return true
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
    if searchText.isEmpty {
      filteredUsers = users
    } else {
      filteredUsers = self.users.filter { (master) -> Bool in
        return master.username.lowercased().contains(searchText.lowercased())
      }
    }
    
    DispatchQueue.main.async {
      self.collectionView.reloadData()
    }
  }
  
  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.delegate = self
    cv.dataSource = self
    cv.alwaysBounceVertical = true
    cv.backgroundColor = .white
    cv.keyboardDismissMode = .onDrag
    cv.alpha = 0
    return cv
  }()
  
  fileprivate func setupCollectionView() {
    collectionView.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
    collectionView.refreshControl = refreshControl
    
    view.addSubview(collectionView)
    collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 64, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
  }
  
  lazy var refreshControl: UIRefreshControl = {
    let rf = UIRefreshControl()
    rf.tintColor = UIColor(r: 243, g: 72, b: 96)
    rf.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    return rf
  }()
  
  @objc func handleRefresh() {
    filteredUsers.removeAll()
    users.removeAll()
    fetchUsers()
  }
  
  var searchBarRightAnchor: NSLayoutConstraint?
  
  fileprivate func setupNavBar() {
    navigationController?.navigationBar.addSubview(searchBar)
    navigationController?.navigationBar.addSubview(cancelSearchButton)
    
    let navBar = navigationController?.navigationBar
    
    searchBarRightAnchor = searchBar.anchorWithReturnAnchors(navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)[3]
    
    cancelSearchButton.anchor(navBar?.topAnchor, left: searchBar.rightAnchor, bottom: navBar?.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 80, heightConstant: 0)
  }
  
  fileprivate func dismissSearchBar() {
    searchBar.isHidden = true
    searchBar.resignFirstResponder()
    handleCancelSearch()
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    guard let masterUID = filteredUsers[indexPath.item].uid else { return }
    presentProfile(uid: masterUID)
  }
  
  var filteredUsers = [Master]()
  var users = [Master]()
  
  fileprivate func fetchUsers() {
    print("Fetching users..")
    
    let ref = Database.database().reference().child("users")
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
      guard let dictionaries = snapshot.value as? [String: Any] else { return }
      
      dictionaries.forEach({ (key, value) in
        guard let values = value as? [String: Any] else { return }
        
        if values["isClient"] as? Int == 1 {
          print("Found client, omit from list")
          return
        }
        
        guard let userDictionary = value as? [String: Any] else { return }
        
        let user = Master(uid: key, dictionary: userDictionary)
        self.users.append(user)
      })
      
      self.users.sort(by: { (u1, u2) -> Bool in
        
        return u1.username.compare(u2.username) == .orderedAscending
        
      })
      
      self.filteredUsers = self.users
      self.addMarkersToMap()
      self.collectionView.reloadData()
      self.refreshControl.endRefreshing()
      
      
    }) { (err) in
      self.refreshControl.endRefreshing()
      print("Failed to fetch users for search:", err)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filteredUsers.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
    
    cell.user = filteredUsers[indexPath.item]
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 66)
  }
  
  
  //MARK: MAP
  fileprivate func addMarkersToMap() {
    
    filteredUsers.forEach { (master) in
      
      let profileImageView = CachedImageView()
      profileImageView.frame.size = CGSize(width: 40, height: 40)
      profileImageView.layer.cornerRadius = 20
      profileImageView.layer.borderWidth = 1
      profileImageView.layer.borderColor = UIColor.white.cgColor
      profileImageView.loadImage(urlString: master.profileImageUrl, completion: {
        let marker = GMSMarker()
        marker.iconView = profileImageView
        marker.position = CLLocationCoordinate2D(latitude: master.latitude, longitude: master.longitude)
        marker.map = self.googleMap
        marker.title = master.username
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0)
        marker.appearAnimation = .pop
        marker.snippet = master.uid
        marker.tracksInfoWindowChanges = true

      })
    }
  }
  
  func fetchWindowInfo(marker: GMSMarker) -> UIView? {
    
    let whiteView = UIView()
    whiteView.backgroundColor = .white
    whiteView.layer.cornerRadius = 5
    whiteView.layer.borderColor = UIColor.lightGray.cgColor
    whiteView.layer.borderWidth = 1
    whiteView.frame = CGRect(x: 0, y: 0, width: 150, height: 60)
    
    let nameLabel = UILabel()
    nameLabel.text = marker.title
    nameLabel.textColor = .black
    nameLabel.textAlignment = .center
    
    whiteView.addSubview(nameLabel)
    nameLabel.anchor(top: whiteView.topAnchor, left: whiteView.leftAnchor, bottom: nil, right: whiteView.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
    let ratingImageView = UIImageView()
    ratingImageView.contentMode = .scaleAspectFit
    ratingImageView.clipsToBounds = true
    ratingImageView.image = #imageLiteral(resourceName: "0_stars")
    
    whiteView.addSubview(ratingImageView)
    ratingImageView.anchor(top: nameLabel.bottomAnchor, left: whiteView.leftAnchor, bottom: nil, right: whiteView.rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 20)
    
    var rating: Float = 0
    fetchFeedback(for: marker.snippet) {
      self.feedbacks.forEach({ (feedback) in
        rating += Float(feedback.rating)
        ratingImageView.image = self.setupStars(rating: rating / Float(self.feedbacks.count))
      })
    }
    
    return whiteView

  }
  
  func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
    return fetchWindowInfo(marker: marker)
  }
  
  private func setupStars(rating: Float) -> UIImage? {
    switch rating {
    case 0..<0.5:
      return #imageLiteral(resourceName: "0_stars")
    case 0.5..<1:
      return #imageLiteral(resourceName: "05_stars")
    case 1..<1.5:
      return #imageLiteral(resourceName: "1_stars")
    case 1.5..<2:
      return #imageLiteral(resourceName: "15_stars")
    case 2..<2.5:
      return #imageLiteral(resourceName: "2_stars")
    case 2.5..<3:
      return #imageLiteral(resourceName: "25_stars")
    case 3..<3.5:
      return #imageLiteral(resourceName: "3_stars")
    case 3.5..<4:
      return #imageLiteral(resourceName: "35_stars")
    case 4..<4.5:
      return #imageLiteral(resourceName: "4_stars")
    case 4.5..<5:
      return #imageLiteral(resourceName: "45_stars")
    case 5:
      return #imageLiteral(resourceName: "5_stars")
    default:
      return #imageLiteral(resourceName: "0_stars")
    }
  }
  
  var feedbacks = [Feedback]()
  
  private func fetchFeedback(for id: String?, completion: @escaping () -> ()) {
    guard let id = id else { return }
    let ref = Database.database().reference().child("feedbacks").child(id)
    ref.observe(.value) { (snapshot) in
      
      guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
      self.feedbacks.removeAll()
      allObjects.forEach({ (snapshot) in
        guard let dictionary = snapshot.value as? [String: Any] else { return }
        self.feedbacks.append(Feedback(dictionary: dictionary))
      })
      completion()
    }
  }
  
  func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
    if let masterUID = marker.snippet {
       self.presentProfile(uid: masterUID)
    }
  }
  
  fileprivate func presentProfile(uid: String) {
    
    dismissSearchBar()
    
    let userProfileController = MasterProfileController(collectionViewLayout: UICollectionViewFlowLayout())
    userProfileController.userId = uid
    tabBarController?.tabBar.isHidden = true
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    navigationController?.navigationBar.tintColor = .black
    navigationController?.pushViewController(userProfileController, animated: true)
  }
  
}





