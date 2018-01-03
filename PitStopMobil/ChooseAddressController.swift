//
//  ChooseAdressController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

class ChooseAddressController: UIViewController, UINavigationBarDelegate, CLLocationManagerDelegate, GMSPlacePickerViewControllerDelegate {
  
  var placesClient: GMSPlacesClient!
  var locationManager = CLLocationManager()
  
  var masterDetailsController: MasterDetailsController?
  
  var googleMapsView: GMSMapView = {
    let map = GMSMapView()
    return map
  }()
  
  let bottomContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  let nameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.textAlignment = .center
    label.textColor = .red
    label.font = UIFont.boldSystemFont(ofSize: 15)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  let addressLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 15)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 0
    return label
  }()
  
  
  let distanceLabel: UILabel = {
    let label = UILabel()
    label.textColor = .blue
    label.font = UIFont.systemFont(ofSize: 20)
    label.textAlignment = .center
    label.text = ""
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 0
    return label
  }()
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Выберите место"
    
    requestCurrentLocation()
    setupViews()
    setupNavBarButtons()
  }
  
  fileprivate func requestCurrentLocation() {
    placesClient = GMSPlacesClient.shared()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
  }
  
  fileprivate func setupNavBarButtons() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleSearch))
  }
  
  @objc func handleSearch() {
    let config = GMSPlacePickerConfig(viewport: nil)
    let placePicker = GMSPlacePickerViewController(config: config)
    placePicker.delegate = self
    present(placePicker, animated: true, completion: nil)
  }
  
  var marker: GMSMarker?
  
  func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
    viewController.dismiss(animated: true) {
      let center = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
      self.marker?.map = nil
      self.marker = GMSMarker(position: center)
      self.placesClient.lookUpPlaceID(place.placeID, callback: { (placeLikelihoodList, err) in
        if let error = err {
          print("Pick Place error: \(error.localizedDescription)")
          return
        }
        
        self.nameLabel.text = "No current place"
        self.addressLabel.text = ""
        
        var address = String()
        
        if let placeLikelihoodList = placeLikelihoodList {
          
          if let addr = placeLikelihoodList.addressComponents {
            for value in addr {
              if value.type == "route" {
                address.append("\( value.name) ")
              } else if value.type == "street_number" {
                address.append("\( value.name) ")
              } else if value.type == "sublocality_level_1" {
                address.append("\( value.name) ")
              }
            }
          }
          
          self.nameLabel.text = placeLikelihoodList.name
          self.addressLabel.text = address
          self.masterDetailsController?.longitude = place.coordinate.longitude
          self.masterDetailsController?.latitude = place.coordinate.latitude
          self.masterDetailsController?.addressTextField.text = self.addressLabel.text
          self.masterDetailsController?.handleTextInputChange()
          }
        
      })
      print("Latitude :- \(place.coordinate.latitude)")
      print("Longitude :-\(place.coordinate.longitude)")
      
      self.marker?.map = self.googleMapsView
      
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
    // Dismiss the place picker, as it cannot dismiss itself.
    viewController.dismiss(animated: true, completion: nil)
    
    print("No place selected")
  }
  
  func setupViews() {
    self.googleMapsView = GMSMapView(frame: view.frame)
    self.googleMapsView.settings.compassButton = true
    self.googleMapsView.isMyLocationEnabled = true
    self.googleMapsView.settings.myLocationButton = true
    view.addSubview(googleMapsView)
    
  }
  
  private func locationManager(manager: CLLocationManager, didFailWithError error: Error) {
    print("Error", error)
  }
  
  var currentLocationMarker: GMSMarker?
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let userLocation = locations.last
    let center = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
    
    let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude, zoom: 15);
    self.googleMapsView.camera = camera
    self.googleMapsView.isMyLocationEnabled = true
    
    let marker = GMSMarker(position: center)
    callPlacesFunc()

    currentLocationMarker = marker
    locationManager.stopUpdatingLocation()
  }
  
  func callPlacesFunc() {
    placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
      if let error = error {
        print("Pick Place error: \(error.localizedDescription)")
        return
      }
      
      self.nameLabel.text = "Текущее местоположение не определенно"
      self.addressLabel.text = ""
      
      if let placeLikelihoodList = placeLikelihoodList {
        let place = placeLikelihoodList.likelihoods.first?.place
        if let place = place {
          print(place.name)
          self.nameLabel.text = "Текущее местоположение - \(place.name)"
          
        }
      }
    })
  }
  
}
