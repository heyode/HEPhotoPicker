//
//  HEPhotoBrowserViewController.swift
//  SwiftPhotoSelector
//
//  Created by apple on 2018/9/20.
//  Copyright © 2018年 heyode. All rights reserved.
//

import UIKit
import Photos


class HEPhotoBrowserViewController: HEBaseViewController {
    var delegate : HEPhotoPickerViewControllerDelegate?
    typealias HEPhotoBrowserViewControllerCallback = (_ selecedModels:[HEPhotoPickerListModel])->Void
    // 供外部赋值，用于取最新的selectedimage值
    var selecedModelUpdateCallBack : HEPhotoBrowserViewControllerCallback?
    var models = [HEPhotoPickerListModel]()
    var selectedModels = [HEPhotoPickerListModel](){
        didSet{
            updateNextBtnTitle()
        }
    }
    var selectedImages = [UIImage]()
    
    var todoArray = [HEPhotoPickerListModel]()
    var phAssets : PHFetchResult<PHAsset>!
    var image = UIImage()
    let barHeight : CGFloat = 130
    lazy var bootomBar : UIView = {
        let navigationMaxY : CGFloat = Tool.isiPhoneX() ? 88 : 64
        let view = UIView.init(frame: CGRect.init(x: 0, y: self.view.bounds.size.height -  barHeight -  navigationMaxY , width: self.view.bounds.width, height: barHeight))
        view.backgroundColor = UIColor.init(r: 50, g: 50, b: 50, a: 0.3)
        view.addSubview(bottomCollectionView)
        view.isHidden = true
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
        collectionView.register(HEPhoneBrowserBottomCell.classForCoder(), forCellWithReuseIdentifier: HEPhoneBrowserBottomCell.className)
        return collectionView
    }()
    var imageIndex : IndexPath?
    var checkBtn  : UIButton!
    let layout = UICollectionViewFlowLayout.init()
    lazy var collectionView : UICollectionView = {
        layout.itemSize = CGSize.init(width: kScreenWidth, height: kScreenHeight)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let y : CGFloat = Tool.isiPhoneX() ? -88 : -64
        let collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: y, width: kScreenWidth, height: kScreenHeight), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HEPhotoBrowserCell.classForCoder(), forCellWithReuseIdentifier: HEPhotoBrowserCell.className)
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
        configUI()
    }
    
    func configUI() {
        let rightBtn = UIButton.init(type: .custom)
        rightBtn.layer.cornerRadius = 4
        rightBtn.layer.masksToBounds = true
        rightBtn.setBackgroundImage(UIColor.hex(hexString: "E98F36").image(), for:.normal)
        rightBtn.setBackgroundImage(UIColor.hex(hexString: "EEEEEE").image(), for: .disabled)
        rightBtn.setTitleColor(UIColor.hex(hexString: "FFFFFF"), for: .normal)
        rightBtn.setTitleColor(UIColor.hex(hexString: "666666"), for: .disabled)
        rightBtn.setTitle("下一步", for: .disabled)
        rightBtn.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 10, bottom: 5, right: 10)
        rightBtn.sizeToFit()
        rightBtn.addTarget(self, action: #selector(nextBtnClick), for: .touchUpInside)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        rightBtn.isEnabled = false
        let right = UIBarButtonItem.init(customView: rightBtn)
        navigationItem.rightBarButtonItem = right
        
        updateNextBtnTitle()
        
        checkBtn = UIButton.init(type: .custom)
        checkBtn.setImage(UIImage.init(named: "btn-check-selected"), for: .selected)
        checkBtn.setImage(UIImage.init(named: "btn-check-normal"), for: .normal)
        checkBtn.addTarget(self, action: #selector(selectedBtnClick(_:)), for: .touchUpInside)
        let btnW : CGFloat = 30
        checkBtn.frame = CGRect.init(x:view.bounds.width - 10 - btnW, y: 10, width: btnW, height: btnW)
        view.addSubview(collectionView)
        view.addSubview(checkBtn)
        view.addSubview(bootomBar)
        
        collectionView.setContentOffset(CGPoint.init(x: CGFloat(self.imageIndex?.row ?? 0) * kScreenWidth, y: 0), animated: false)

    }
    func updateNextBtnTitle() {
        guard let rightBtn = self.navigationItem.rightBarButtonItem?.customView as? UIButton  else {
            return
        }
        
        rightBtn.isEnabled = self.selectedModels.count > 0
        bootomBar.isHidden = self.selectedModels.count <= 0
        rightBtn.setTitle(String.init(format: "下一步(%d)", self.selectedModels.count), for: .normal)
        rightBtn.sizeToFit()
    }
    func getImages(){
        
        let option = PHImageRequestOptions()
        option.deliveryMode = .highQualityFormat
        if todoArray.count == 0 {
            delegate?.pickerController(self, didFinishPicking: self.selectedImages)
        }
        if todoArray.count > 0 {
            PHImageManager.default().requestImage(for: (todoArray.first?.asset)!, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: option) {[weak self] (image, _) in
                DispatchQueue.main.async {
                    self?.todoArray.removeFirst()
                    self?.selectedImages.append(image ?? UIImage())
                    self?.getImages()
                }
            }
        }
        
    }
    @objc func nextBtnClick(){
        todoArray = self.selectedModels
        getImages()
    }
    @objc func selectedBtnClick(_ btn: UIButton){
        guard selectedModels.count < 9 else {
            HELog(message: "提示用户已经超过9个了")
            return
        }
        
        btn.isSelected = !btn.isSelected
        let row = Int(collectionView.contentOffset.x / collectionView.frame.width)
        
        let model = models[row]
        model.isSelected = btn.isSelected
        
        if btn.isSelected{
            
            selectedModels.append(model)
        }else{
            
            let arr = selectedModels
            selectedModels = (arr.filter{$0.index != model.index})
            
        }
        
        
        if let callBack = selecedModelUpdateCallBack {
            callBack(self.selectedModels)
        }
        self.bottomCollectionView.reloadData()
        
        let count = self.selectedModels.count
        if  count > 0 {
            // 刷新选中的cell
            let index = IndexPath.init(row: self.selectedModels.count - 1, section: 0)
            bottomCollectionView.selectItem(at: index, animated: false, scrollPosition: .centeredHorizontally)
        }
        
    }
    
}
extension HEPhotoBrowserViewController : UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate{
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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HEPhotoBrowserCell.className, for: indexPath) as? HEPhotoBrowserCell  else {
                fatalError("unexpected cell in collection view")
            }
            let model  = models[indexPath.row]
            cell.model = model
            
            return cell
        }else{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HEPhoneBrowserBottomCell.className, for: indexPath) as? HEPhoneBrowserBottomCell  else {
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
            for (index,_) in self.models.enumerated(){
                if  index == selectedModel.index{
                    self.checkBtn.isSelected = true
                    self.collectionView.setContentOffset(CGPoint.init(x: CGFloat(index) * collectionView.frame.width , y: 0), animated: false)
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == self.collectionView {
            let row = Int(scrollView.contentOffset.x / scrollView.frame.width)
            let currentModel = self.models[row]
            checkBtn.isSelected = currentModel.isSelected
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
extension HEPhotoBrowserViewController : HEPhotoBrowserAnimatorPopDelegate{
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
