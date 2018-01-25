//
//  ViewController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.08.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
  
  override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    guard let items = tabBar.items else { return }
    if items.index(of: item) == 1 || items.index(of: item) == 3 {
      item.badgeValue = nil
    }
    _ = navigationController?.popToRootViewController(animated: true)
  }
  
  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    
    if !isClient {
      return true
    }
    
    let index = viewControllers?.index(of: viewController)
    if index == 2 {

      let newOrderController = NewOrderController()
      let navController = UINavigationController(rootViewController: newOrderController)

      present(navController, animated: true, completion: nil)

      return false
    }
    
    return true
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.delegate = self
    view.backgroundColor = .white
    self.navigationController?.navigationBar.tintColor = .red

    activityIndicatorView.startAnimating()
    setupNavigationBarTitleView()
    
    if Auth.auth().currentUser == nil {
      //show if not logged in
      userIsNotAuthorized()
      return
    }
    
    setupViewControllers()
    isConnectedToTheInternet()
    setupUI()
  }
  
  let activityIndicatorView: UIActivityIndicatorView = {
    let aiv = UIActivityIndicatorView()
    aiv.activityIndicatorViewStyle = .gray
    aiv.hidesWhenStopped = true
    return aiv
  }()
  
  func setupUI() {
    view.addSubview(noConnectionLabel)
    noConnectionLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    
    view.addSubview(activityIndicatorView)
    activityIndicatorView.fillSuperview()
  }
  
  let noConnectionLabel: UILabel = {
    let label = UILabel()
    let attrString = NSMutableAttributedString(attributedString: NSAttributedString(string: "Отсутствует доступ к интернету\n\n", attributes: [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17)]))
    attrString.append(NSAttributedString(string: "Пожалуйста, проверьте подключение", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
    label.attributedText = attrString
    label.isHidden = true
    label.numberOfLines = 0
    label.textAlignment = .center
    return label
  }()
  
  func noInternetConnection() {
    noConnectionLabel.isHidden = false
    activityIndicatorView.stopAnimating()
  }
  
  func isConnectedToTheInternet() {
    let reachability = Reachability()!
    
    reachability.whenReachable = { reachability in
      if reachability.connection == .wifi {
        print("Reachable via WiFi")
      } else {
        print("Reachable via Cellular")
      }
    }
    reachability.whenUnreachable = { _ in
      print("Not reachable")
      self.noInternetConnection()
    }
    
    do {
      try reachability.startNotifier()
    } catch {
      print("Unable to start notifier")
    }
  }
  
  fileprivate func userIsNotAuthorized() {
    DispatchQueue.main.async {
      let choiseController = ChoiseController()
      let navController = UINavigationController(rootViewController: choiseController)
      self.present(navController, animated: true, completion: nil)
    }
  }
  
  fileprivate func setupNavigationBarTitleView() {
    navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2").withRenderingMode(.alwaysOriginal))
  }
  
  var isClient = true
  
  func setupViewControllers(completed: ((Bool) -> ())? = nil) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let ref = Database.database().reference().child("users").child(uid)
    
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
      guard let dictionary = snapshot.value as? [String: Any] else {
        self.userIsNotAuthorized()
        completed?(true)
        return
      }
      
      self.noConnectionLabel.isHidden = true
      self.activityIndicatorView.stopAnimating()
      
      if dictionary["isClient"] as? Int == 1 {
        self.isClient = true
        self.setupClientViewControllers()
      } else {
        self.isClient = false
        self.setupMasterViewControllers()
      }
      
      completed?(true)
    }) { (err) in
      print(err)
      return
    }
    
  }
  
  fileprivate func setupMasterViewControllers() {
    //home
    let homeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "master_main_gray"), selectedImage: #imageLiteral(resourceName: "master_main_black"), rootViewController: MasterHomeController(collectionViewLayout: UICollectionViewFlowLayout()))
    
    //search
    let messageNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "messages_gray"), selectedImage: #imageLiteral(resourceName: "messages_black"), rootViewController: MessagesController())
    
    //user profile
    
    let userProfileNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "profile_gray"), selectedImage: #imageLiteral(resourceName: "profile_black"), rootViewController: MasterProfileController(collectionViewLayout: UICollectionViewFlowLayout()))

    tabBar.tintColor = .black
    
    viewControllers = [homeNavController,
                       messageNavController,
                       userProfileNavController]
    
    //modify tab bar item insets
    guard let items = tabBar.items else { return }
    //select first tab bar controller

    for item in items {
      item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
      item.badgeColor = .red
    }
    self.navigationController?.isNavigationBarHidden = true

  }
  
  fileprivate func setupClientViewControllers() {
    
    //Main search
    let searchNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "main_gray"), selectedImage: #imageLiteral(resourceName: "main_black"), rootViewController: UserSearchController())
    
    let jobsNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "master_main_gray"), selectedImage: #imageLiteral(resourceName: "master_main_black"), rootViewController: ClientOrdersController())
    
    let plusNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "plus"), selectedImage: #imageLiteral(resourceName: "plus"), rootViewController: NewOrderController())
    
    let messagesNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "messages_gray"), selectedImage: #imageLiteral(resourceName: "messages_black"), rootViewController: MessagesController())
    
    //user profile
    let userProfileNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "profile_gray"), selectedImage: #imageLiteral(resourceName: "profile_black"), rootViewController: ClientProfileController())
    
    tabBar.tintColor = .black
    
    viewControllers = [searchNavController,
                       jobsNavController,
                       plusNavController,
                       messagesNavController,
                       userProfileNavController]
    
    //modify tab bar item insets
    guard let items = tabBar.items else { return }
    
    for item in items {
      item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
    }
    
    self.navigationController?.isNavigationBarHidden = true
  }
 
  
  fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
    let viewController = rootViewController
    let navController = UINavigationController(rootViewController: viewController)
    navController.tabBarItem.image = unselectedImage
    navController.tabBarItem.selectedImage = selectedImage
    return navController
  }
}








