//
//  BrowserViewController.swift
//  HEPhotoPicker_Example
//
//  Created by apple on 2018/11/8.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import HEPhotoPicker
//屏宽
let kScreenWidth = UIScreen.main.bounds.size.width
//屏高
let kScreenHeight = UIScreen.main.bounds.size.height


class BrowserViewController: UIViewController {
 

        var models = [HEPhotoPickerListModel]()
        var selectedModels = [HEPhotoPickerListModel]()
        var image = UIImage()
        let barHeight : CGFloat = 130
        lazy var bootomBar : UIView = {
        
            let view = UIView.init(frame: CGRect.init(x: 0, y: self.view.bounds.size.height -  barHeight , width: self.view.bounds.width, height: barHeight))
            view.backgroundColor = UIColor.init(r: 50, g: 50, b: 50, a: 0.3)
            view.addSubview(bottomCollectionView)

            return view
        }()
        let bottomLayout = UICollectionViewFlowLayout.init()
        lazy var bottomCollectionView : UICollectionView = {
            let cellW : CGFloat = 80
            bottomLayout.itemSize = CGSize.init(width: cellW, height: cellW)
            bottomLayout.minimumLineSpacing = 5
            bottomLayout.minimumInteritemSpacing = 0
            bottomLayout.scrollDirection = .horizontal
            
            let collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 10, width: kScreenWidth, height: cellW), collectionViewLayout: bottomLayout)
            collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
            collectionView.backgroundColor = UIColor.clear
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(BrowserBottomCell.classForCoder(), forCellWithReuseIdentifier: BrowserBottomCell.className)
            return collectionView
        }()
        var currentIndex : Int!
        var imageIndex : IndexPath!
    
        let layout = UICollectionViewFlowLayout.init()
        lazy var collectionView : UICollectionView = {
            layout.itemSize = CGSize.init(width: kScreenWidth, height: kScreenHeight)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.scrollDirection = .horizontal
            
            let collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight), collectionViewLayout: layout)
            collectionView.backgroundColor = UIColor.white
            collectionView.isPagingEnabled = true
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(BrowserCell.classForCoder(), forCellWithReuseIdentifier: BrowserCell.className)
            return collectionView
        }()
        
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.navigationBar.barStyle = .black
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            self.scrollViewDidEndDecelerating(self.collectionView)
            
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            currentIndex = imageIndex.row
            configUI()
            
            
        }
    
   
        
        func configUI() {
        
            view.addSubview(collectionView)
            view.addSubview(bootomBar)
            collectionView.setContentOffset(CGPoint.init(x: CGFloat(currentIndex) * kScreenWidth, y: 0), animated: false)
            
        }
  
    static func isiPhoneX() -> Bool {
        if kScreenHeight == 812 {
            return true
        }else{
            return false
        }
    }
       
    
    
            
  }
    extension BrowserViewController : UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate{
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if collectionView == self.collectionView {
                return models.count
            }else{
                return selectedModels.count
            }
        }
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            if collectionView == self.collectionView {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BrowserCell.className, for: indexPath) as? BrowserCell  else {
                    fatalError("unexpected cell in collection view")
                }
                let model  = models[indexPath.row]
                
                cell.model = model
                
                return cell
            }else{
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BrowserBottomCell.className, for: indexPath) as? BrowserBottomCell  else {
                    fatalError("unexpected cell in collection view")
                }
                let model  = selectedModels[indexPath.row]
                cell.model = model
                
                return cell
            }
            
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            if collectionView == self.bottomCollectionView {
                let selectedModel = selectedModels[indexPath.row]
                for (index,model) in self.models.enumerated(){
                    if  model.asset.localIdentifier == selectedModel.asset.localIdentifier{
                       
                        self.collectionView.setContentOffset(CGPoint.init(x: CGFloat(index) * collectionView.frame.width , y: 0), animated: false)
                    }
                }
            }else{
                 self.dismiss(animated: true, completion: nil)
            }
        }
        func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            let model  = models[indexPath.row]
            
            if model.asset.mediaType == .video{
                if let browserCell = cell as? BrowserCell{
                    browserCell.canlePlayerAction()
                }
            }
            
        }
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            
            if scrollView == self.collectionView {
                let row = Int(scrollView.contentOffset.x / scrollView.frame.width)
                currentIndex = row
                let currentModel = self.models[row]
                
                
                
           
                if currentModel.isSelected == true{
                    for (index,item) in self.selectedModels.enumerated(){
                        if item.index == currentModel.index{
                            self.bottomCollectionView.selectItem(at: IndexPath.init(row: index, section: 0), animated: false, scrollPosition: .centeredHorizontally)
                        }
                    }
                }else{
                    self.bottomCollectionView.reloadData()
                }
            }
        }
    }
extension BrowserViewController : HEPhotoBrowserAnimatorPopDelegate{
        func indexOfPopViewImageView() -> IndexPath {
            
            return imageIndex ?? IndexPath.init()
        }
        func imageViewOfPopView() -> UIImageView {
            let temp = UIImageView()
            let x: CGFloat = 0
            let width: CGFloat = kScreenWidth
            let height: CGFloat = width / (image.size.width) * (image.size.height)
            var y: CGFloat = 0
            if height < kScreenHeight {
                y = (kScreenHeight  -  height) * 0.5
            }
            temp.frame =  CGRect(x: x, y: y, width: width, height: height)
            temp.image = image
            temp.clipsToBounds = true
            return temp
        
        }
}
