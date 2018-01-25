//
//  NewOrderController.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.09.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase

class NewOrderController: UIViewController {
  
  var selectedSkills = [String]()
  var client: Client?
  
  let cellId = "cellId"
  let skills = ["Шиномонтаж",
                  "Кузовщик",
                  "Маляр",
                  "Электрик",
                  "Ходовик",
                  "Развальщик",
                  "Моторист"]
  
  lazy var createButton: UIButton = {
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
    let newOrderCarChooseVC = NewOrderCarChooseVC(collectionViewLayout: UICollectionViewFlowLayout())
    newOrderCarChooseVC.client = client
    newOrderCarChooseVC.selectedSkills = self.selectedSkills
    navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain
      , target: self, action: nil)
    navigationController?.pushViewController(newOrderCarChooseVC, animated: true)
  }
  
  let chooseLabel: UILabel = {
    let label = UILabel()
    label.text = "Выберите услуги мастера"
    label.textColor = .black
    label.font = UIFont.boldSystemFont(ofSize: 17)
    label.numberOfLines = 0
    label.textAlignment = .center
    return label
  }()
  
  lazy var tableView: UITableView = {
    let tv = UITableView(frame: .zero, style: UITableViewStyle.plain)
    tv.delegate = self
    tv.dataSource = self
    tv.backgroundColor = .clear
    return tv
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    fetchClientInfo()
    setupNavBar()
    setupTable()
    setupUI()
  }
  
  fileprivate func fetchClientInfo() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    Database.fetchUserWithUID(uid: uid, isMaster: false) { (client) in
      self.client = client as? Client
    }
  }
  
  private func setupTable() {
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    tableView.tableFooterView = UIView()
    tableView.allowsMultipleSelection = true
    tableView.separatorStyle = .none
    view.addSubview(tableView)
    tableView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 330)
    tableView.anchorCenterYToSuperview()
  }
  
  private func setupNavBar() {
    navigationItem.title = "Новая Заявка"
    let leftCancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(handleDismiss))
    leftCancelButton.tintColor = .black
    navigationItem.leftBarButtonItem = leftCancelButton
  }
  
  @objc private func handleDismiss() {
    dismiss(animated: true, completion: nil)
  }
  
  private func setupUI() {
    view.addSubview(createButton)
    createButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    
    view.addSubview(chooseLabel)
    chooseLabel.anchor(top: topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: tableView.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
  }
  
}


extension NewOrderController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
    cell.textLabel?.text = skills[indexPath.row]
    cell.selectionStyle = .none
    cell.tintColor = Settings.Color.pink
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return skills.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 46
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    cell.accessoryType = .checkmark
    
    if let skill = cell.textLabel?.text {
      selectedSkills.append(skill)
      createButton.backgroundColor = Settings.Color.pink
      createButton.isEnabled = true
    }
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    cell.accessoryType = .none
    
    if let skill = cell.textLabel?.text {
      if let index = selectedSkills.index(of: skill) {
        selectedSkills.remove(at: index)
      }
      
      if selectedSkills.isEmpty {
        createButton.backgroundColor = Settings.Color.disabledPink
        createButton.isEnabled = false
      }
    }
  }
}
