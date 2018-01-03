//
//  MenuBar.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.12.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//


    
import UIKit
    
class MenuBar: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
      
    lazy var collectionView: UICollectionView = {
      let layout = UICollectionViewFlowLayout()
      let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
      cv.backgroundColor = .white
      cv.dataSource = self
      cv.delegate = self
      return cv
    }()
  
    let cellId = "cellId"
    let titles = ["Ожидающие", "Подтвержденные"]
  
    var clientOrdersController: ClientOrdersController?
  
    override init(frame: CGRect) {
      super.init(frame: frame)
      
      collectionView.register(MenuCell.self, forCellWithReuseIdentifier: cellId)
      
      addSubview(collectionView)
      addConstraintsWithFormat("H:|[v0]|", views: collectionView)
      addConstraintsWithFormat("V:|[v0]|", views: collectionView)
      
      let selectedIndexPath = IndexPath(item: 0, section: 0)
      collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
      
      setupHorizontalBar()
    }
  
    var horizontalBarLeftAnchorConstraint: NSLayoutConstraint?
  
    func setupHorizontalBar() {
      let horizontalBarView = UIView()
      horizontalBarView.backgroundColor = .black
      horizontalBarView.translatesAutoresizingMaskIntoConstraints = false
      addSubview(horizontalBarView)
      
      //old school frame way of doing things
      //        horizontalBarView.frame = CGRectMake(<#T##x: CGFloat##CGFloat#>, <#T##y: CGFloat##CGFloat#>, <#T##width: CGFloat##CGFloat#>, <#T##height: CGFloat##CGFloat#>)
      
      //new school way of laying out our views
      //in ios9
      //need x, y, width, height constraints
      
      horizontalBarLeftAnchorConstraint = horizontalBarView.leftAnchor.constraint(equalTo: self.leftAnchor)
      horizontalBarLeftAnchorConstraint?.isActive = true
      
      horizontalBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
      horizontalBarView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/2).isActive = true
      horizontalBarView.heightAnchor.constraint(equalToConstant: 2).isActive = true
    }
  
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
      //        print(indexPath.item)
      //        let x = CGFloat(indexPath.item) * frame.width / 4
      //        horizontalBarLeftAnchorConstraint?.constant = x
      //
      //        UIView.animateWithDuration(0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {
      //            self.layoutIfNeeded()
      //            }, completion: nil)
      
      clientOrdersController?.scrollToMenuIndex(indexPath.item)
    }
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return 2
    }
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MenuCell
      
      cell.title = titles[indexPath.item]
      cell.tintColor = UIColor(r: 91, g: 14, b: 13)
      
      return cell
    }
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      return CGSize(width: frame.width / 2, height: frame.height)
    }
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
      return 0
    }
  
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  
}
    


  class MenuCell: BaseCell {
    
    var title: String? {
      didSet {
        titleLabel.text = title
      }
    }
    
    let titleLabel: UILabel = {
      let label = UILabel()
      label.textColor = .lightGray
      label.font = UIFont.boldSystemFont(ofSize: 15)
      label.textAlignment = .center
      return label
    }()
    
    let separatorLine: UIView = {
      let view = UIView()
      view.backgroundColor = UIColor(white: 0, alpha: 0.5)
      return view
    }()
    
    override var isHighlighted: Bool {
      didSet {
        titleLabel.textColor = isHighlighted ? UIColor.black : UIColor.lightGray
      }
    }
    
    override var isSelected: Bool {
      didSet {
        titleLabel.textColor = isSelected ? UIColor.black : UIColor.lightGray
      }
    }
    
    override func setupUI() {
      super.setupUI()
      backgroundColor = UIColor(r: 247, g: 247, b: 247, a: 1)
      addSubview(titleLabel)
      titleLabel.fillSuperview()
      addSubview(separatorLine)
      separatorLine.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
}

