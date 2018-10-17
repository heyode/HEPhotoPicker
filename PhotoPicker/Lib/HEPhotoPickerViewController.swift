//
//  HEPhotoPickerViewController.swift
//  SwiftPhotoSelector
//
//  Created by apple on 2018/9/19.
//  Copyright © 2018年 heyode. All rights reserved.
//

import UIKit
import Photos
//屏宽
let kScreenWidth = UIScreen.main.bounds.size.width
//屏高
let kScreenHeight = UIScreen.main.bounds.size.height

@objc public protocol HEPhotoPickerViewControllerDelegate
{
    
    /// 选择照片完成后调用的代理
    ///
    /// - Parameters:
    ///   - picker: 选择图片的控制器
    ///   - selectedImages: 选择的图片数组
    func pickerController(_ picker:UIViewController, didFinishPicking selectedImages:[UIImage])
    
   /// 选择照片取消后调用的方法
   ///
   /// - Parameter picker: 选择图片的控制器
   @objc optional func pickerControllerDidCancel(_ picker:UIViewController)
}
class HEPhotoPickerViewController: HEBaseViewController {
  
    public var maxCount = 9
    var delegate : HEPhotoPickerViewControllerDelegate?
    var options = PHImageRequestOptions()//请求选项设置
    var selectedImages = [UIImage]()
    var animator = HEPhotoBrowserAnimator()
    var todoArray = [HEPhotoPickerListModel]()
    var selectedModels =  [HEPhotoPickerListModel](){
        didSet{
            updateNextBtnTitle()
        }
    }
    var models = [HEPhotoPickerListModel]()

    fileprivate var thumbnailSize: CGSize!
    var phAssets : PHFetchResult<PHAsset>!
    let layout = UICollectionViewFlowLayout.init()
    lazy var collectionView : UICollectionView = {
        let cellW = (kScreenWidth - 3) / 4.0
        layout.itemSize = CGSize.init(width: cellW, height: cellW)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        
        let collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 64), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HEPhotoPickerCell.classForCoder(), forCellWithReuseIdentifier: HEPhotoPickerCell.className)
        return collectionView
    }()

  
    
     // MARK: UIViewController / Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.edgesForExtendedLayout =  []
        let scale = UIScreen.main.scale
        let cellSize = layout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.pushDelegate = self
        options.isSynchronous = true
        navigationController?.delegate = self
        getAllPhotos()
        // 注册相册库的通知(要写在getAllPhoto后面)
        PHPhotoLibrary.shared().register(self)
       
        configUI()
        
    }
   func configUI() {
    
        title = "相机胶卷"
        options.resizeMode = .none
     
        view.addSubview(collectionView)
   
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
        
        
        let right = UIBarButtonItem.init(customView: rightBtn)
         navigationItem.rightBarButtonItem = right
         rightBtn.isEnabled = false
    }
    override func configNavigationBar() {
        super.configNavigationBar()
        
        let leftBtn = UIButton.init(type: .custom)
        leftBtn.setTitle("取消", for: .normal)
        leftBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        leftBtn.setTitleColor(UIColor.gray, for: .normal)
        let left = UIBarButtonItem.init(customView: leftBtn)

        navigationItem.leftBarButtonItem = left
       
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
    // MARK: UI Actions
    @objc func nextBtnClick(){
         todoArray = self.selectedModels
        getImages()
       

    }
    @objc  func goBack(){

        navigationController?.dismiss(animated: true, completion: nil)
        delegate?.pickerControllerDidCancel?(self)
    }
   
    func setCellEnable(isEnable:Bool,selectedIndexPath:IndexPath,count:Int){
        for item in self.models{
            if item.isSelected == false{
                item.isEnable = isEnable
            }
        }
        if count >= self.maxCount - 1{
            
            self.collectionView.reloadData()
        }else{
            self.collectionView.reloadItems(at: [selectedIndexPath])
        }
    }
    func updateNextBtnTitle() {
        let rightBtn = self.navigationItem.rightBarButtonItem?.customView as! UIButton
        rightBtn.isEnabled = self.selectedModels.count > 0
        
        rightBtn.isEnabled = self.selectedModels.count > 0
        rightBtn.setTitle(String.init(format: "下一步(%d)", self.selectedModels.count), for: .normal)
         rightBtn.sizeToFit()
    }

    //  MARK:- 获取全部图片
    private func getAllPhotos() {
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        phAssets = PHAsset.fetchAssets(with: allPhotosOptions)
        phAssets.enumerateObjects { (asset, index, ff) in
            let model = HEPhotoPickerListModel.init(asset: asset)
            model.index = index
            self.models.append(model)
        }
        self.collectionView.reloadData()
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

}
extension HEPhotoPickerViewController: PHPhotoLibraryChangeObserver{
    func photoLibraryDidChange(_ changeInstance: PHChange) {

        DispatchQueue.main.async {
            self.getAllPhotos()
            
        }
    }
}
extension HEPhotoPickerViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return phAssets.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:HEPhotoPickerCell.className , for: indexPath) as! HEPhotoPickerCell
        let model = self.models[indexPath.row]
        cell.model = model
        cell.topViewClickBlock = {[weak self] in
            let title = String.init(format: "最多只能选择%d个照片", self?.maxCount ?? 0)
            let alertView = UIAlertController.init(title: "提示", message: title, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title:"确定", style: .default) { okAction in
                
            }
            alertView.addAction(okAction)
            self?.present(alertView, animated: true, completion: nil)
        }
        cell.checkBtnnClickClosure = {[weak self] (selectedBtn) in
            selectedBtn.isSelected = !selectedBtn.isSelected
            self?.models[indexPath.row].isSelected = selectedBtn.isSelected
            if selectedBtn.isSelected{
                self?.selectedModels.append(model)
            }else{
                let arr = self?.selectedModels
                self?.selectedModels = (arr?.filter{$0.index != model.index})!
            }
            guard let count = self?.selectedModels.count else {return}
            if count >= (self?.maxCount)!{
                self?.setCellEnable(isEnable: false,selectedIndexPath: indexPath,count: count)
            }else{
                self?.setCellEnable(isEnable: true,selectedIndexPath: indexPath,count:count )
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        animator.selIndex = indexPath
        let size = CGSize.init(width: kScreenWidth, height: kScreenWidth)
        PHImageManager.default().requestImage(for: phAssets[indexPath.row] ,
                                              targetSize: size,
                                              contentMode: .aspectFill,
                                              options: options)
        { (image, nil) in
            let photoDetail = HEPhotoBrowserViewController()
            photoDetail.delegate = self.delegate
            photoDetail.maxCount = self.maxCount
            photoDetail.image = image!
            photoDetail.imageIndex = indexPath
            photoDetail.phAssets = self.phAssets
            photoDetail.models = self.models
            photoDetail.selectedModels = self.selectedModels
            photoDetail.selecedModelUpdateCallBack = {[weak self] model in
                self?.selectedModels = model
            }
            self.animator.popDelegate = photoDetail
            self.navigationController?.pushViewController(photoDetail, animated: true)
        }
    }
}

extension HEPhotoPickerViewController : UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.operation = operation
        return animator
    }
}

extension HEPhotoPickerViewController: HEPhotoBrowserAnimatorPushDelegate{
    func imageViewRectOfAnimatorStart(at indexPath: IndexPath) -> CGRect {
        guard   let cell = collectionView.cellForItem(at: indexPath) as? HEPhotoPickerCell else{
             fatalError("unexpected cell in collection view")
        }
        let homeFrame =   UIApplication.shared.keyWindow?.convert(cell.imageView.frame, from: cell.contentView)
        //返回具体的尺寸
        return homeFrame!
    }
    func imageViewRectOfAnimatorEnd(at indexPath: IndexPath) -> CGRect {
        //取出cell
        let cell = (collectionView.cellForItem(at: indexPath))! as! HEPhotoPickerCell
        //取出cell中显示的图片
        let image = cell.imageView.image
        let x: CGFloat = 0
        let width: CGFloat = kScreenWidth
        let height: CGFloat = width / (image!.size.width) * (image!.size.height)
        var y: CGFloat = 0
        if height < kScreenHeight {
            y = (kScreenHeight -   height) * 0.5
        }
        //计算方法后的图片的frame
        return CGRect(x: x, y: y, width: width, height: height)
        
    }
    func imageView(at indexPath: IndexPath) -> UIImageView {
        //创建imageView对象
        let imageView = UIImageView()
        //取出cell
        let cell = (collectionView.cellForItem(at: indexPath))! as! HEPhotoPickerCell
        //取出cell中显示的图片
        let image = cell.imageView.image
        //设置imageView相关属性(拉伸模式)
        imageView.contentMode = .scaleAspectFit
        //设置图片
        imageView.image = image
        //将多余的部分裁剪
        imageView.clipsToBounds = true
        //返回图片
        return imageView
    }
}

