//
//  ChoiseController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit


class ChoiseController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    navigationController?.isNavigationBarHidden = true

    setupViews()
  }
  
  let logoContainerView: UIView = {
    let view = UIView()
    
    let logoImageView = UIImageView(image: #imageLiteral(resourceName: "logo"))
    logoImageView.contentMode = .scaleAspectFill
    
    view.addSubview(logoImageView)
    logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
    logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    
    view.backgroundColor = Settings.Color.blue
    return view
  }()
  
  let registerLabel: UILabel = {
    let label = UILabel()
    label.text = "Зарегистрируйтесь, как"
    label.textColor = .lightGray
    label.font = UIFont.systemFont(ofSize: 16)
    label.textAlignment = .center
    return label
  }()
  
  let orLabel: UILabel = {
    let label = UILabel()
    label.text = "Или"
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = .lightGray
    return label
  }()
  
  let clientButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Клиент", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 10
    button.tag = 1
    button.backgroundColor = Settings.Color.blue
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    button.addTarget(self, action: #selector(handleSelection), for: .touchUpInside)
    return button
  }()
  
  let masterButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Мастер", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 10
    button.tag = 2
    button.backgroundColor = Settings.Color.orange
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    button.addTarget(self, action: #selector(handleSelection), for: .touchUpInside)
    return button
  }()
  
  @objc func handleSelection(_ sender: UIButton) {
    let signUpController = SignUpController()
    switch sender.tag {
    case 1:
      //client
      signUpController.isClient = true
      navigationController?.pushViewController(signUpController, animated: true)
    case 2:
      //master
      signUpController.isClient = false
      navigationController?.pushViewController(signUpController, animated: true)
    default:
      break
    }
  }
  
  let alreadyHaveAccountButton: UIButton = {
    let button = UIButton(type: .system)
    
    let attributedTitle = NSMutableAttributedString(string: "Уже есть аккаунт? ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
    
    attributedTitle.append(NSAttributedString(string: "Войти", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237)
      ]))
    
    button.setAttributedTitle(attributedTitle, for: .normal)
    
    button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
    return button
  }()
  
  @objc func handleAlreadyHaveAccount() {
    let loginController = LoginController()
    navigationController?.pushViewController(loginController, animated: true)
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
 
  
  fileprivate func setupViews() {
    view.addSubview(logoContainerView)
    
    logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)

    view.addSubview(orLabel)
    
    orLabel.anchorCenterXToSuperview()
    orLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 80).isActive = true
    
    view.addSubview(clientButton)
    view.addSubview(masterButton)
    
    clientButton.anchor(top: nil, left: view.leftAnchor, bottom: orLabel.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 12, paddingRight: 20, width: 0, height: 50)
    
    masterButton.anchor(top: orLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
    
    view.addSubview(registerLabel)
    
    registerLabel.anchor(top: nil, left: view.leftAnchor, bottom: clientButton.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 12, paddingRight: 0, width: 0, height: 0)
    
    view.addSubview(alreadyHaveAccountButton)
    
    alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
  }
  
  
}
