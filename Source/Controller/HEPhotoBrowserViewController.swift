//
//  HEPhotoBrowser.swift
//  SwiftPhotoSelector
//
//  Created by apple on 2018/9/20.
//  Copyright © 2018年 heyode. All rights reserved.
//

import UIKit
import Photos


class HEPhotoBrowserViewController: HEBaseViewController {
    typealias HEPhotoBrowserViewCotrollerCloser = ()->Void
    // 供外部赋值，在pop后调用刷新上个控制器的数据
    var closer : HEPhotoBrowserViewCotrollerCloser?
    var delegate : HEPhotoPickerViewControllerDelegate?
  
    /// 配置
    public var pickerOptions = HEPhotoPickerOptions()
    typealias HEPhotoBrowserCallback = (_ selecedModels:[HEPhotoPickerListModel])->Void
    // 供外部赋值，用于取最新的selectedimage值
    var selecedModelUpdateCallBack : HEPhotoBrowserCallback?
    var models = [HEPhotoPickerListModel]()
   
    var selectedModels = [HEPhotoPickerListModel](){
        didSet{
            updateNextBtnTitle()
        }
    }
    var selectedVideoModels = [HEPhotoPickerListModel]()
    var selectedImageModels = [HEPhotoPickerListModel]()
    var selectedImages = [UIImage]()
    
    var todoArray = [HEPhotoPickerListModel]()

    var image = UIImage()
    let barHeight : CGFloat = 130
    lazy var bootomBar : UIView = {
        let navigationMaxY : CGFloat = HETool.isiPhoneX() ? 88 : 64
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
    var currentIndex : Int!
    var imageIndex : IndexPath!
    var checkBtn  : UIButton!
    let layout = UICollectionViewFlowLayout.init()
    lazy var collectionView : UICollectionView = {
        layout.itemSize = CGSize.init(width: kScreenWidth, height: kScreenHeight)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let y : CGFloat = HETool.isiPhoneX() ? -88 : -64
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
 
    override func pressBack() {
        super.pressBack()
        if let block = closer{
            block()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentIndex = imageIndex.row
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
        rightBtn.setTitle("选择", for: .disabled)
        rightBtn.contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 10, bottom: 5, right: 10)
        rightBtn.sizeToFit()
        rightBtn.addTarget(self, action: #selector(nextBtnClick), for: .touchUpInside)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        rightBtn.isEnabled = false
        let right = UIBarButtonItem.init(customView: rightBtn)
        navigationItem.rightBarButtonItem = right
        
        updateNextBtnTitle()
        
       
        checkBtn = UIButton.init(type: .custom)
        let budle = Bundle(path: Bundle(for: HEPhotoBrowserViewController.self).path(forResource: "HEPhotoPicker", ofType: "bundle")!)!
        let selImage = UIImage(named: "btn-check-selected", in: budle, compatibleWith: nil)
        let norImage = UIImage(named: "btn-check-normal", in: budle, compatibleWith: nil)
        checkBtn.setImage(selImage, for: .selected)
        checkBtn.setImage(norImage, for: .normal)
        checkBtn.addTarget(self, action: #selector(selectedBtnClick(_:)), for: .touchUpInside)
        let btnW : CGFloat = 30
        checkBtn.frame = CGRect.init(x:view.bounds.width - 10 - btnW, y: 10, width: btnW, height: btnW)
        
        
        view.addSubview(collectionView)
        view.addSubview(bootomBar)
        view.addSubview(checkBtn)
        
        collectionView.setContentOffset(CGPoint.init(x: CGFloat(currentIndex) * kScreenWidth, y: 0), animated: false)

    }
    func updateNextBtnTitle() {
        guard let rightBtn = self.navigationItem.rightBarButtonItem?.customView as? UIButton  else {
            return
        }
        rightBtn.isEnabled = self.selectedModels.count > 0
        rightBtn.setTitle(String.init(format: "选择(%d)", self.selectedModels.count), for: .normal)
        if self.pickerOptions.singlePicture == true || self.pickerOptions.singleVideo == true{
            let currentModel = models[currentIndex]
            
            if self.pickerOptions.singlePicture == true && currentModel.asset.mediaType == .image {
                    rightBtn.isEnabled = true
                    rightBtn.setTitle("选择", for: .normal)
                }
            if  self.pickerOptions.singleVideo == true && currentModel.asset.mediaType == .video{
                    rightBtn.isEnabled = true
                    rightBtn.setTitle("选择", for: .normal)
            }
        }
        rightBtn.sizeToFit()
        bootomBar.isHidden = self.selectedModels.count <= 0
        
        
    }
    
    func getImages(){
        
        let option = PHImageRequestOptions()
        option.deliveryMode = .highQualityFormat
        if todoArray.count == 0 {
            delegate?.pickerController(self, didFinishPicking: self.selectedImages,selectedModel: self.selectedModels)
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
        let currentModel = self.models[currentIndex]
        if currentModel.asset.mediaType == .image &&  self.pickerOptions.singlePicture == true && currentModel.isEnable == true{
            selectedModels.append(currentModel)
            todoArray = self.selectedModels
            getImages()
        }else if  currentModel.asset.mediaType == .video &&  self.pickerOptions.singleVideo == true && currentModel.isEnable == true{
            selectedModels.append(currentModel)
            todoArray = self.selectedModels
            getImages()
        }else{
            todoArray = self.selectedModels
            getImages()
        }
        
        
    }
    @objc func selectedBtnClick(_ btn: UIButton){
       
        let row = Int(collectionView.contentOffset.x / collectionView.frame.width)
        
        let model = models[row]
        if !btn.isSelected{
            let maxImageCount = self.pickerOptions.maxCountOfImage
            let selectedImageCount =  self.selectedImageModels.count
            
            if  model.asset.mediaType == .image{
                if selectedImageCount >= maxImageCount {
                    let title = String.init(format: "最多只能选择%d个照片", maxImageCount)
                    HETool.presentAlert(title: title, viewController: self)
                    return
                }
                
            }
            let maxVideoCount = self.pickerOptions.maxCountOfVideo
            let selectedVideoCount =  self.selectedVideoModels.count
            if  model.asset.mediaType == .video {
                if selectedVideoCount >= maxVideoCount {
                    let title = String.init(format: "最多只能选择%d个视频", maxVideoCount)
                    HETool.presentAlert(title: title, viewController: self)
                    return
                }
                
            }
        }
        
        btn.isSelected = !btn.isSelected
        
        model.isSelected = btn.isSelected
        
        if btn.isSelected{
            
            selectedModels.append(model)
            if model.asset.mediaType == .image{
                self.selectedImageModels.append(model)
            }
            if model.asset.mediaType == .video{
                self.selectedVideoModels.append(model)
            }
        }else{
            
            let arr = selectedModels
            selectedModels = (arr.filter{$0.index != model.index})
            if model.asset.mediaType == .image{
                self.selectedImageModels = self.selectedImageModels.filter{$0.index != model.index}
            }
            if model.asset.mediaType == .video{
                self.selectedVideoModels = self.selectedVideoModels.filter{$0.index != model.index}
            }
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
            for (index,model) in self.models.enumerated(){
                if  model.asset.localIdentifier == selectedModel.asset.localIdentifier{
                    self.checkBtn.isSelected = true
                    self.collectionView.setContentOffset(CGPoint.init(x: CGFloat(index) * collectionView.frame.width , y: 0), animated: false)
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.row < models.count else {return}
        let model  = models[indexPath.row]
        
        if model.asset.mediaType == .video{
            if let browserCell = cell as? HEPhotoBrowserCell{
                browserCell.canlePlayerAction()
            }
        }
        
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == self.collectionView {
            let row = Int(scrollView.contentOffset.x / scrollView.frame.width)
            currentIndex = row
            let currentModel = self.models[row]
            
            checkBtn.isSelected = currentModel.isSelected
            // 是否支持视频图片二选一的模式
            var isfalg : Bool? = nil
            if self.pickerOptions.mediaType == .imageOrVideo && self.selectedModels.count > 0{
                isfalg = true
            }else if self.pickerOptions.mediaType == .imageOrVideo && self.selectedModels.count <= 0{
                isfalg = false
            }
            if let falg = isfalg, falg == true{// 如果是
                if currentModel.asset.mediaType == self.selectedModels.first?.asset.mediaType{//与已选择的文件类型相同，显示可选按钮
                    checkBtn.isHidden = false
                }else{
                    checkBtn.isHidden = true
                }
            }else{//如果不是
                
                checkBtn.isHidden = !currentModel.isEnableSelected
                updateNextBtnTitle()
            }
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
