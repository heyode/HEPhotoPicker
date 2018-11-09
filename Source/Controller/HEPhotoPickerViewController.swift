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
    ///   - selectedImages: 选择的图片数组(如果是视频，就取视频第一帧作为图片保存)
    ///   - selectedModel: 选择的数据模型
    func pickerController(_ picker:UIViewController, didFinishPicking selectedImages:[UIImage],selectedModel:[HEPhotoPickerListModel])
    
    /// 选择照片取消后调用的方法
    ///
    /// - Parameter picker: 选择图片的控制器
    @objc optional func pickerControllerDidCancel(_ picker:UIViewController)
}
public enum HEMediaType : Int {
    /// 只显示图片
    case image
    /// 只显示视频
    case video
    /// 所有类型都显示,并且都可以选择
    case imageAndVideo
    /// 所有类型都显示,但只能选一类
    case imageOrVideo
}
open class HEPhotoPickerOptions : NSObject{
    /// 要挑选的数据类型
    public var mediaType : HEMediaType = .imageAndVideo
    /// 列表是否按创建时间升序排列
    public var ascendingOfCreationDateSort : Bool = false
    /// 挑选图片的最大个数
    public var maxCountOfImage = 9
    /// 挑选视频的最大个数
    public var maxCountOfVideo = 2
    /// 是否支持图片单选，默认是false，如果是ture只允许选择一张图片（如果 mediaType = imageAndVideo 或者 imageOrVideo 此属性无效）
    public var singlePicture = false
    /// 是否支持视频单选 默认是false，如果是ture只允许选择一个视频（如果 mediaType = imageAndVideo 此属性无效）
    public var singleVideo = false
    ///  实现多次累加选择时，需要传入的选中的模型。为空时表示不需要多次累加
    public var defaultSelections : [HEPhotoPickerListModel]?
}
public class HEPhotoPickerViewController: HEBaseViewController {
    /// 选择器配置
    public var pickerOptions : HEPhotoPickerOptions!
    
    private var todoArray = [HEPhotoPickerListModel]()
    private var models = [HEPhotoPickerListModel]()
    
    private var selectedModels =  [HEPhotoPickerListModel](){
        didSet{
            selectedImageModels = selectedModels.filter{$0.asset.mediaType == .image}
            selectedVideoModels = selectedModels.filter{$0.asset.mediaType == .video}
        }
    }
    private var selectedImages = [UIImage]()
    private var selectedVideoModels = [HEPhotoPickerListModel]()
    private var selectedImageModels = [HEPhotoPickerListModel]()
    public var homeFrame = CGRect.zero
    
    /// 图片请求项的配置
    private let options = PHImageRequestOptions()
    /// 相册请求项
    private let photosOptions = PHFetchOptions()
    /// 代理
    public var delegate : HEPhotoPickerViewControllerDelegate?
    
    
    private var animator = HEPhotoBrowserAnimator()
    
    
   
    /// 所有的相册
    private var smartAlbums: PHFetchResult<PHAssetCollection>!
    /// 整理过后的相册
    private var tempAlbums = [HEAlbum]()
    /// 所有展示的多媒体数据集合
    private var phAssets : PHFetchResult<PHAsset>!
    private var thumbnailSize: CGSize!
    private let layout = UICollectionViewFlowLayout.init()
    private var titleBtn : UIButton!
    
    
    /// 待刷新的IndexPath
    private var willUpadateIndex = [IndexPath]()
    /// titleBtn展开的tableView的上一个选中的IndexPath
    private var preSelectedTableViewIndex = IndexPath.init(row: 0, section: 0 )
    private lazy var collectionView : UICollectionView = {
        let cellW = (self.view.frame.width - 3) / 4.0
        layout.itemSize = CGSize.init(width: cellW, height: cellW)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        var height = CGFloat(0)
        if HETool.isiPhoneX(){
            height =  kScreenHeight - 88
        }else{
            height = kScreenHeight - 64
        }
        let collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height:height), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 34, right: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HEPhotoPickerCell.classForCoder(), forCellWithReuseIdentifier: HEPhotoPickerCell.className)
        
        return collectionView
    }()
    // MARK:- 初始化
    
    public init(delegate: HEPhotoPickerViewControllerDelegate,options:HEPhotoPickerOptions = HEPhotoPickerOptions() ) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.pickerOptions = options
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- 控制器生命周期和设置UI
    public override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.edgesForExtendedLayout =  []
        let scale = UIScreen.main.scale
        let cellSize = layout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }
    
    public override  func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    public override  func viewDidLoad() {
        super.viewDidLoad()
        animator.pushDelegate = self
        options.isSynchronous = true
        options.resizeMode = .none
        configPickerOption()
        
        navigationController?.delegate = self
        
        getAllPhotos()
        getClassList()
        // 注册相册库的通知(要写在getAllPhoto后面)
        PHPhotoLibrary.shared().register(self)
        
        configUI()
        if self.selectedModels.count > 0{
            updateUI()
        }
    }
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
      
    }
    func configUI() {
        view.addSubview(collectionView)
        let btn = HEAlbumTitleView.init(type: .custom)
        titleBtn = btn
        if let title = tempAlbums.first?.title{
            btn.setTitle(title, for: .normal)
        }else{
            btn.setTitle("相机胶卷", for: .normal)
        }
        btn.addTarget(self, action: #selector(HEPhotoPickerViewController.titleViewClick(_:)), for: .touchUpInside)
        
        self.navigationItem.titleView = btn
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
        
        
        let right = UIBarButtonItem.init(customView: rightBtn)
        navigationItem.rightBarButtonItem = right
        rightBtn.isEnabled = false
    }
    
    override public func configNavigationBar() {
        super.configNavigationBar()
        
        let leftBtn = UIButton.init(type: .custom)
        leftBtn.setTitle("取消", for: .normal)
        leftBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        leftBtn.setTitleColor(UIColor.gray, for: .normal)
        let left = UIBarButtonItem.init(customView: leftBtn)
        navigationItem.leftBarButtonItem = left
    }
    
    
    /// 将给定类型模型设为不可点击状态
    ///
    /// - Parameter type: 给定媒体数据类型
    func setCellDisableEnable(with type:PHAssetMediaType){
        for item in self.models{
            if item.asset.mediaType == type{
                item.isEnable = false
            }
        }
        self.collectionView.reloadData()
    }
    func updateNextBtnTitle() {
        let rightBtn = self.navigationItem.rightBarButtonItem?.customView as! UIButton
        rightBtn.isEnabled = self.selectedModels.count > 0
        
        rightBtn.isEnabled = self.selectedModels.count > 0
        rightBtn.setTitle(String.init(format: "选择(%d)", self.selectedModels.count), for: .normal)
        rightBtn.sizeToFit()
    }
    
    /// 数据源重置后更新UI
    func updateUI(){
        self.updateNextBtnTitle()
        let count = selectedModels.count
        
        if count >= self.pickerOptions.maxCountOfImage + self.pickerOptions.maxCountOfVideo{
            setCellState(isEnable: false, isUpdateSelecetd: true)
        }else{
            setCellState(isEnable: true, isUpdateSelecetd: true)
        }
    }
    
    
    /// 设置cell的可用和选中状态
    ///
    /// - Parameters:
    ///   - isEnable:其他cell是否能被选中
    ///   - isUpdateSelecetd: 是否更新选中状态
    
    func setCellState(isEnable:Bool,isUpdateSelecetd:Bool = false){
        willUpadateIndex = [IndexPath]()
        var isfalg : Bool? = nil
        if self.pickerOptions.mediaType == .imageOrVideo && self.selectedModels.count > 0{
            isfalg = true
        }else if self.pickerOptions.mediaType == .imageOrVideo && self.selectedModels.count <= 0{
            isfalg = false
        }
        for item in self.models{
            if isUpdateSelecetd == true{
                for selItem in self.selectedModels{
                    if item.asset.localIdentifier ==  selItem.asset.localIdentifier{
                        item.isSelected = true
                    }
                }
            }
            if item.isSelected == false{// 根据当前用户选中的个数，将所有未选中的cell重置给定可用状态
                item.isEnable = isEnable
                if let falg = isfalg,falg == true{ //选中模式：是图片和视频只能选中其中一种，并且已经选中了至少一个
                    if self.selectedModels.first?.asset.mediaType == .image{ // 用户选中的是图片的话，就把视频类型的cell都设置为不可选中
                        if item.asset.mediaType == .video{
                            item.isEnable = false
                        }
                    }else if self.selectedModels.first?.asset.mediaType == .video{
                        if item.asset.mediaType == .image{
                            item.isEnable = false
                        }
                    }
                    
                }
                willUpadateIndex.append(IndexPath.init(row: item.index, section: 0))
            }
        }
        if isUpdateSelecetd {// 整个数据源重置，必须刷新所有cell
            self.collectionView.reloadData()
        }else{
            self.collectionView.reloadItems(at: willUpadateIndex)
        }
        
    }
    // MARK:- 初始化配置项
    
    func configPickerOption() {
       
        switch pickerOptions.mediaType {
        case .imageAndVideo:
            pickerOptions.singlePicture = false
            pickerOptions.singleVideo = false
        case .imageOrVideo:
            pickerOptions.singlePicture = false
        case .image:
            pickerOptions.maxCountOfVideo = 0
            
        case .video:
            pickerOptions.maxCountOfImage = 0
        }
        if pickerOptions.singleVideo {
            pickerOptions.maxCountOfVideo = 0
        }
        if pickerOptions.singlePicture{
            pickerOptions.maxCountOfImage = 0
        }
       
        if let models = pickerOptions.defaultSelections{
            selectedModels = models
        }
        
    }
    
    /// 如果是单选模式隐藏多选按钮
    ///
    /// - Parameter model: 当前模型
    func checkIsSingle(model:HEPhotoPickerListModel){
        if self.pickerOptions.singlePicture == true{
            if model.asset.mediaType == .image{
                model.isEnableSelected = false
            }
        }
        if self.pickerOptions.singleVideo == true{
            if model.asset.mediaType == .video{
                model.isEnableSelected = false
            }
        }
    }
    
    // MARK:- UI Actions
    @objc func titleViewClick(_ sender:UIButton){
        sender.isSelected = true
        let popViewFrame : CGRect!
//        if HETool.isiPhoneX() {
        popViewFrame = CGRect.init(x: 0, y: (self.navigationController?.navigationBar.frame.maxY)!, width: kScreenWidth, height: kScreenHeight/2)
//        }else{
//            popViewFrame = CGRect.init(x: 0, y: 64, width: kScreenWidth, height: kScreenHeight/2)
//        }
        let listView =  HEAlbumListView.showOnKeyWidows(rect: popViewFrame, assetCollections: tempAlbums, cellClick: { [weak self](list,ablum,selecedIndex) in
            self?.preSelectedTableViewIndex = selecedIndex
            self?.models = [HEPhotoPickerListModel]()
            self?.titleBtn.setTitle(ablum.title, for: .normal)
            self?.titleBtn.sizeToFit()
            ablum.fetchResult.enumerateObjects {[weak self] (asset, index, ff) in
                let model = HEPhotoPickerListModel.init(asset: asset)
                self?.checkIsSingle(model: model)
                model.index = index
                self?.models.append(model)
            }
            self?.updateUI()
            
            },dismiss:{
                sender.isSelected = false
        })
        listView.tableView.selectRow(at: preSelectedTableViewIndex, animated: false, scrollPosition: .top)
    }
    @objc func nextBtnClick(){
        todoArray = self.selectedModels
        getImages()
    }
    @objc  func goBack(){
        navigationController?.dismiss(animated: true, completion: nil)
        delegate?.pickerControllerDidCancel?(self)
    }
    
    
    
    
    //  MARK:- 获取全部图片
    private func getAllPhotos() {
        switch self.pickerOptions.mediaType{
        case .image:
            photosOptions.predicate = NSPredicate.init(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        case .video:
            photosOptions.predicate = NSPredicate.init(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        default:
            break
        }
        photosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: self.pickerOptions.ascendingOfCreationDateSort)]
        phAssets = PHAsset.fetchAssets(with: photosOptions)
        models =  [HEPhotoPickerListModel]()
        phAssets.enumerateObjects {[weak self] (asset, index, ff) in
            let model = HEPhotoPickerListModel.init(asset: asset)
            self?.checkIsSingle(model: model)
            model.index = index
            self?.models.append(model)
            
            self?.collectionView.reloadData()
            
        }
    }
    
    private func getClassList(){
        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        
        smartAlbums.enumerateObjects { [weak self] (collection, index, stop) in
            let asset = PHAsset.fetchAssets(in: collection, options: self!.photosOptions)
            let album = HEAlbum.init(result: asset, title: collection.localizedTitle)
            if asset.count > 0 && collection.localizedTitle != "最近删除" &&  collection.localizedTitle != "Recently Deleted"{
                if collection.localizedTitle == "所有照片" || collection.localizedTitle == "All Photos"{
                    self?.tempAlbums.insert(album, at: 0)
                }else{
                    self?.tempAlbums.append(album)
                }
            }
        }
        
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
    
    
}
extension HEPhotoPickerViewController :UIPopoverPresentationControllerDelegate{
    private func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    private func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}
extension HEPhotoPickerViewController: PHPhotoLibraryChangeObserver{
    open  func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            if let changeDetails = changeInstance.changeDetails(for: phAssets){
                phAssets = changeDetails.fetchResultAfterChanges
            }
            models =  [HEPhotoPickerListModel]()
            phAssets.enumerateObjects {[weak self] (asset, index, ff) in
                let model = HEPhotoPickerListModel.init(asset: asset)
                self?.checkIsSingle(model: model)
                model.index = index
                self?.models.append(model)
                
                self?.collectionView.reloadData()
                
            }
            
            // Update the cached fetch results, and reload the table sections to match.
            if let changeDetails = changeInstance.changeDetails(for: smartAlbums) {
                smartAlbums = changeDetails.fetchResultAfterChanges
                smartAlbums.enumerateObjects { [weak self] (collection, index, stop) in
                    let asset = PHAsset.fetchAssets(in: collection, options: self?.photosOptions)
                    let album = HEAlbum.init(result: asset, title: collection.localizedTitle)
                    if asset.count > 0 && collection.localizedTitle != "最近删除" &&  collection.localizedTitle != "Recently Deleted"{
                        if collection.localizedTitle == "所有照片" || collection.localizedTitle == "All Photos"{
                            self?.tempAlbums.insert(album, at: 0)
                        }else{
                            self?.tempAlbums.append(album)
                        }
                    }
                }
            }
            
        }
    }
}
extension HEPhotoPickerViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    public  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:HEPhotoPickerCell.className , for: indexPath) as! HEPhotoPickerCell
        
        let model = self.models[indexPath.row]
        cell.model = model
        
        cell.checkBtnnClickClosure = {[unowned self] (selectedBtn) in
            if !selectedBtn.isSelected{
                let maxImageCount = self.pickerOptions.maxCountOfImage
                let selectedImageCount =  self.selectedImageModels.count
                if  model.asset.mediaType == .image{
                    guard selectedImageCount < maxImageCount else{
                        let title = String.init(format: "最多只能选择%d个照片", maxImageCount)
                        HETool.presentAlert(title: title, viewController: self)
                        return
                    }
                    
                }
                let maxVideoCount = self.pickerOptions.maxCountOfVideo
                let selectedVideoCount =  self.selectedVideoModels.count
                if  model.asset.mediaType == .video {
                    guard selectedVideoCount < maxVideoCount else{
                        let title = String.init(format: "最多只能选择%d个视频", maxVideoCount)
                        HETool.presentAlert(title: title, viewController: self)
                        return
                    }
                    
                }
            }
            selectedBtn.isSelected = !selectedBtn.isSelected
            
            self.models[indexPath.row].isSelected = selectedBtn.isSelected
            if selectedBtn.isSelected{
                self.selectedModels.append(model)
//                if model.asset.mediaType == .image{
//                    self.selectedImageModels.append(model)
//                }
//                if model.asset.mediaType == .video{
//                    self.selectedVideoModels.append(model)
//                }
            }else{
                let arr = self.selectedModels
                self.selectedModels = arr.filter{$0.index != model.index}
//                if model.asset.mediaType == .image{
//                    self.selectedImageModels = self.selectedImageModels.filter{$0.index != model.index}
//                }
//                if model.asset.mediaType == .video{
//                    self.selectedVideoModels = self.selectedVideoModels.filter{$0.index != model.index}
//                }
            }
            self.updateNextBtnTitle()
            
            
            let  count = self.selectedModels.count
            
            if count >= self.pickerOptions.maxCountOfImage + self.pickerOptions.maxCountOfVideo{// 根据当前用户选中的个数，将所有未选中的cell重置给定可用状态
                self.setCellState(isEnable: false)
            }else{
                self.setCellState(isEnable: true)
            }
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        animator.selIndex = indexPath
        let size = CGSize.init(width: kScreenWidth, height: kScreenWidth)
        PHImageManager.default().requestImage(for: phAssets[indexPath.row] ,
                                              targetSize: size,
                                              contentMode: .aspectFill,
                                              options: options)
        { (image, nil) in
            let photoDetail = HEPhotoBrowserViewController()
            photoDetail.delegate = self.delegate
            photoDetail.pickerOptions = self.pickerOptions
            photoDetail.image = image!
            photoDetail.imageIndex = indexPath
            
            photoDetail.models = self.models
            photoDetail.selectedModels = self.selectedModels
            photoDetail.selectedVideoModels = self.selectedVideoModels
            photoDetail.selectedImageModels = self.selectedImageModels
            photoDetail.selecedModelUpdateCallBack = {[weak self] model in
                self?.selectedModels = model
            }
            photoDetail.closer = { [weak self] in
                if self?.selectedModels.count ?? 0 >= 0{
                    self?.updateUI()
                }
                
            }
            self.animator.popDelegate = photoDetail
            self.navigationController?.pushViewController(photoDetail, animated: true)
        }
    }
}

extension HEPhotoPickerViewController : UINavigationControllerDelegate{
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.operation = operation
        return animator
    }
}

extension HEPhotoPickerViewController: HEPhotoBrowserAnimatorPushDelegate{
    

    
    public func imageViewRectOfAnimatorStart(at indexPath: IndexPath) -> CGRect {
        guard   let cell = collectionView.cellForItem(at: indexPath) as? HEPhotoPickerCell else{
            fatalError("unexpected cell in collection view")
        }
        homeFrame =  UIApplication.shared.keyWindow?.convert(cell.imageView.frame, from: cell.contentView) ?? CGRect.zero
        //返回具体的尺寸
        return homeFrame
    }
    public func imageViewRectOfAnimatorEnd(at indexPath: IndexPath) -> CGRect {
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
    public func imageView(at indexPath: IndexPath) -> UIImageView {
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

