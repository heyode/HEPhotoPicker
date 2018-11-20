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
    
    var delegate : HEPhotoPickerViewControllerDelegate?
    var selectedCloser : ((_ seletedIndex:Int)->Void)?
    var clickBottomCellCloser : ((_ seletedIndex:Int)->Void)?
    var unSelectedCloser : ((_ seletedIndex:Int)->Void)?
    /// 配置
    public var pickerOptions = HEPhotoPickerOptions()
    
    var models = [HEPhotoPickerListModel]()
   
    var selectedModels = [HEPhotoPickerListModel](){
        didSet{
            updateNextBtnTitle()
        }
    }
    
    var selectedImages = [UIImage]()
    
    var todoArray = [HEPhotoPickerListModel]()
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
    var currentIndex : Int!{
        get{
            return Int(pageCollectionView.contentOffset.x / pageCollectionView.frame.width)
        }
    }
    var imageIndex : IndexPath!
    var checkBtn  : UIButton!
    let layout = UICollectionViewFlowLayout.init()
    lazy var pageCollectionView : UICollectionView = {
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
        scrollViewDidEndDecelerating(pageCollectionView)
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
        view.addSubview(pageCollectionView)
        view.addSubview(bootomBar)
        view.addSubview(checkBtn)
        pageCollectionView.setContentOffset(CGPoint.init(x: CGFloat(imageIndex.row) * kScreenWidth, y: 0), animated: false)
    }
    func updateNextBtnTitle() {
        guard let rightBtn = navigationItem.rightBarButtonItem?.customView as? UIButton  else {return}
        rightBtn.isEnabled = selectedModels.count > 0
        rightBtn.setTitle(String.init(format: "选择(%d)", selectedModels.count), for: .normal)
        guard currentIndex < models.count else{return}
        let currentModel = models[currentIndex]
 
        if isEnableSinglePicture(model: currentModel) || isEnableSingleVideo(model: currentModel) {
            rightBtn.isEnabled = true
            rightBtn.setTitle("选择", for: .normal)
        }
        
        rightBtn.sizeToFit()
        bootomBar.isHidden = selectedModels.count <= 0
    }
    
    func getImages(){
        
        let option = PHImageRequestOptions()
        option.deliveryMode = .highQualityFormat
        if todoArray.count == 0 {
            delegate?.pickerController(self, didFinishPicking: selectedImages,selectedModel: selectedModels)
            dismiss(animated: true, completion: nil)
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

    /// 检查当前模型是否为图片，是否可用，是否为图片单选模式，
    func isEnableSinglePicture(model:HEPhotoPickerListModel) ->Bool{
        return model.asset.mediaType == .image &&  pickerOptions.singlePicture == true && model.isEnable == true
    }
     /// 检查当前模型是否为视频，是否可用，是否为视频单选模式，
    func isEnableSingleVideo(model:HEPhotoPickerListModel) ->Bool{
        return model.asset.mediaType == .video &&  pickerOptions.singleVideo == true && model.isEnable == true
    }
    @objc func nextBtnClick(){
        guard currentIndex < models.count else{return}
        let currentModel = models[currentIndex]
        if isEnableSinglePicture(model: currentModel) || isEnableSingleVideo(model: currentModel){
            selectedModels.append(currentModel)
        }
        todoArray = selectedModels
        getImages()
    }
    @objc func selectedBtnClick(_ btn: UIButton){
        let model = models[currentIndex]
        if !btn.isSelected{
            let selectedImageCount =  selectedModels.count{$0.asset.mediaType == .image}
            if  model.asset.mediaType == .image{
                if selectedImageCount >= pickerOptions.maxCountOfImage {
                    let title = String.init(format: "最多只能选择%d个照片", pickerOptions.maxCountOfImage)
                    HETool.presentAlert(title: title, viewController: self)
                    return
                }
            }
            
            let selectedVideoCount =  selectedModels.count{$0.asset.mediaType == .video}
            if  model.asset.mediaType == .video {
                if selectedVideoCount >= pickerOptions.maxCountOfVideo {
                    let title = String.init(format: "最多只能选择%d个视频", pickerOptions.maxCountOfVideo)
                    HETool.presentAlert(title: title, viewController: self)
                    return
                }
                
            }
        }
        btn.isSelected = !btn.isSelected
        model.isSelected = btn.isSelected
        if btn.isSelected{
            if let block = selectedCloser{
                if let i = models.firstIndex(where: {$0.asset.localIdentifier == model.asset.localIdentifier}) {
                    block(i)
                }
            }
            selectedModels.append(model)
        }else{
            if let block  = unSelectedCloser{
                if let i = models.firstIndex(where: {$0.asset.localIdentifier == model.asset.localIdentifier}) {
                    block(i)
                }
            }
            selectedModels.removeAll(where: {$0.asset.localIdentifier == model.asset.localIdentifier})
        }
        bottomCollectionView.reloadData()
        let count = selectedModels.count
        if  count > 0 && selectedModels[selectedModels.count - 1].index < models.count{// 有选中的图片，并且最后一个照片在当前相册，就设置底部cell的选中外框
            // 刷新选中的cell
            let index = IndexPath.init(row: selectedModels.count - 1, section: 0)
            bottomCollectionView.selectItem(at: index, animated: false, scrollPosition: .centeredHorizontally)
        }
    }
    
}
extension HEPhotoBrowserViewController : UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == pageCollectionView {
            return models.count
        }else{
            return selectedModels.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == pageCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HEPhotoBrowserCell.className, for: indexPath) as? HEPhotoBrowserCell  else {
                fatalError("unexpected cell in collection view")
            }
            cell.model = models[indexPath.row]
            return cell
        }else{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HEPhoneBrowserBottomCell.className, for: indexPath) as? HEPhoneBrowserBottomCell  else {
                fatalError("unexpected cell in collection view")
            }
            cell.model = selectedModels[indexPath.row]
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == bottomCollectionView {
            let selectedModel = selectedModels[indexPath.row]
            for (index,model) in models.enumerated(){
                if  model.asset.localIdentifier == selectedModel.asset.localIdentifier{//所选的照片在当前相册内
                    checkBtn.isSelected = true
                   pageCollectionView.setContentOffset(CGPoint.init(x: CGFloat(index) * collectionView.frame.width , y: 0), animated: false)
                    if let block = clickBottomCellCloser{
                        block(index)
                    }
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.row < models.count else {return}
        if models[indexPath.row].asset.mediaType == .video{
            if let browserCell = cell as? HEPhotoBrowserCell{
                browserCell.canlePlayerAction()
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == pageCollectionView {
            let currentModel = models[currentIndex]
            checkBtn.isSelected = currentModel.isSelected
            // 是否支持视频图片二选一的模式
            var isfalg : Bool? = nil
            if pickerOptions.mediaType == .imageOrVideo && selectedModels.count > 0{
                isfalg = true
            }else if pickerOptions.mediaType == .imageOrVideo && selectedModels.count <= 0{
                isfalg = false
            }
            if let falg = isfalg, falg == true{// 如果是
                if currentModel.asset.mediaType == selectedModels.first?.asset.mediaType{//与已选择的文件类型相同，显示可选按钮
                    checkBtn.isHidden = false
                }else{
                    checkBtn.isHidden = true
                }
            }else{//如果不是
                checkBtn.isHidden = !currentModel.isEnableSelected
                updateNextBtnTitle()
            }
            if currentModel.isSelected == true{
                for (index,item) in selectedModels.enumerated(){
                    if item.asset.localIdentifier == currentModel.asset.localIdentifier{
                        bottomCollectionView.selectItem(at: IndexPath.init(row: index, section: 0), animated: false, scrollPosition: .centeredHorizontally)
                    }
                }
            }else{
                bottomCollectionView.reloadData()
            }
        }
    }
}
extension HEPhotoBrowserViewController : HEPhotoBrowserAnimatorPopDelegate{
    func indexOfPopViewImageView() -> IndexPath {
        return IndexPath.init(item: currentIndex, section: 0)
    }
    func imageViewOfPopView() -> UIImageView {
        guard  let cell = pageCollectionView.cellForItem(at: IndexPath.init(item: currentIndex, section: 0)) as? HEPhotoBrowserCell ,let img = cell.imageView.image else {
            fatalError("unexpected cell in collection view")
        }
        let temp = UIImageView()
        let x: CGFloat = 0
        let width: CGFloat = kScreenWidth
        let height: CGFloat = width / (img.size.width) * (img.size.height)
        var y: CGFloat = 0
        if height < kScreenHeight {
            y = (kScreenHeight  -  height) * 0.5 
        }
        temp.frame =  CGRect(x: x, y: y, width: width, height: height)
        temp.image = img
        temp.clipsToBounds = true
        
        return temp
    }
}
