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


public class HEPhotoPickerViewController: HEBaseViewController {
    // MARK : - Public
    /// 选择器配置
    public var pickerOptions : HEPhotoPickerOptions!
    /// 选择完成后的相关代理
    public var delegate : HEPhotoPickerViewControllerDelegate?
    
    // MARK : - Private
    
    /// 图片列表的数据模型
    private var models = [HEPhotoPickerListModel]()
    /// 选中的数据模型
    private var selectedModels =  [HEPhotoPickerListModel]()
    /// 选中的图片模型（若有视频，则取它第一帧作为图片保存）
    private var selectedImages = [UIImage]()
    /// 用于处理选中的数组
    private var todoArray = [HEPhotoPickerListModel]()
    /// 图片请求项的配置
    private let options = PHImageRequestOptions()
    /// 相册请求项
    private let photosOptions = PHFetchOptions()
    /// 过场动画
    private var animator = HEPhotoBrowserAnimator()
    /// 所有的相册
    private var smartAlbums: PHFetchResult<PHAssetCollection>!
    /// 整理过后的相册
    private var tempAlbums = [HEAlbum]()
    /// 所有展示的多媒体数据集合
    private var phAssets : PHFetchResult<PHAsset>!
    /// 相册按钮
    private var titleBtn : UIButton!
    /// 待刷新的IndexPath
    private var willUpadateIndex = [IndexPath]()
    /// titleBtn展开的tableView的上一个选中的IndexPath
    private var preSelectedTableViewIndex = IndexPath.init(row: 0, section: 0 )
    /// 图片视图
    private lazy var collectionView : UICollectionView = {
        let cellW = (self.view.frame.width - 3) / 4.0
        let layout = UICollectionViewFlowLayout.init()
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

    /// 初始化方法
    ///
    /// - Parameters:
    ///   - delegate: 控制器的代理
    ///   - options: 配置项
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
        edgesForExtendedLayout =  []
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
        if selectedModels.count > 0{
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
        
        navigationItem.titleView = btn
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
        for item in models{
            if item.asset.mediaType == type{
                item.isEnable = false
            }
        }
        collectionView.reloadData()
    }
    
    func updateNextBtnTitle() {
        let rightBtn = navigationItem.rightBarButtonItem?.customView as! UIButton
        rightBtn.isEnabled = selectedModels.count > 0
        rightBtn.setTitle(String.init(format: "选择(%d)", selectedModels.count), for: .normal)
        rightBtn.sizeToFit()
    }
    
    /// 数据源重置后更新UI
    func updateUI(){
        updateNextBtnTitle()
        let count = selectedModels.count
        
        if count >= pickerOptions.maxCountOfImage + pickerOptions.maxCountOfVideo{
            setCellState(isEnable: false,sel: nil, isUpdateSelecetd: true)
        }else{
            setCellState(isEnable: true,sel: nil, isUpdateSelecetd: true)
        }
    }
    
    /// 设置cell的可用和选中状态
    ///
    /// - Parameters:
    ///   - isEnable:其他cell是否能被选中
    ///   - sel:当前选中的cell索引
    ///   - isUpdateSelecetd: 是否更新选中状态
    func setCellState(isEnable:Bool,sel:Int?,isUpdateSelecetd:Bool = false){
        var isfalg : Bool? = nil
        if pickerOptions.mediaType == .imageOrVideo && selectedModels.count > 0{
            isfalg = true
        }else if pickerOptions.mediaType == .imageOrVideo && selectedModels.count <= 0{
            isfalg = false
        }
        for item in models{
            if isUpdateSelecetd == true{
                for selItem in selectedModels{
                    if item.asset.localIdentifier ==  selItem.asset.localIdentifier{
                        item.isSelected = true
                    }
                }
            }
            if item.isSelected == false{// 根据当前用户选中的个数，将所有未选中的cell重置给定可用状态
                item.isEnable = isEnable
                if let falg = isfalg,falg == true{ //选中模式：是图片和视频只能选中其中一种，并且已经选中了至少一个
                    if selectedModels.first?.asset.mediaType == .image{ // 用户选中的是图片的话，就把视频类型的cell都设置为不可选中
                        if item.asset.mediaType == .video{
                            item.isEnable = false
                        }
                    }else if selectedModels.first?.asset.mediaType == .video{
                        if item.asset.mediaType == .image{
                            item.isEnable = false
                        }
                    }
                }
                if let i = sel,item.index != i{// 当前点击的cell已经在前面加入了，所以要排除
                    willUpadateIndex.append(IndexPath.init(row: item.index, section: 0))
                }
            }
        }
        if isUpdateSelecetd {// 整个数据源重置，必须刷新所有cell
            collectionView.reloadData()
        }else{
            collectionView.reloadItems(at: willUpadateIndex)
        }
    }
    
    /// 更新cell的选中状态
    ///
    /// - Parameters:
    ///   - sel: 选中的索引
    ///   - isSelected: 是否选中
    func updateSelectedCell(sel:Int,isSelected:Bool) {
        let model = models[sel]
        if isSelected {
            switch model.asset.mediaType {
            case .image:
                let selectedImageCount =  selectedModels.count{$0.asset.mediaType == .image}
                guard selectedImageCount < pickerOptions.maxCountOfImage  else{
                    let title = String.init(format: "最多只能选择%d个照片", pickerOptions.maxCountOfImage)
                    HETool.presentAlert(title: title, viewController: self)
                    return
                }
            case .video:
                let selectedVideoCount =  selectedModels.count{$0.asset.mediaType == .video}
                guard selectedVideoCount < pickerOptions.maxCountOfVideo else{
                    let title = String.init(format: "最多只能选择%d个视频", pickerOptions.maxCountOfVideo)
                    HETool.presentAlert(title: title, viewController: self)
                    return
                }
            default:
                break
            }
            selectedModels.append(model)
        }else{// 切勿使用index去匹配
            selectedModels.removeAll(where: {$0.asset.localIdentifier == model.asset.localIdentifier})
        }
        models[sel].isSelected = isSelected
        updateNextBtnTitle()
        let  count = selectedModels.count
        willUpadateIndex = [IndexPath]()
        willUpadateIndex.append(IndexPath.init(row: sel, section: 0))
        if count >= pickerOptions.maxCountOfImage + pickerOptions.maxCountOfVideo{// 根据当前用户选中的个数，将所有未选中的cell重置给定可用状态
            setCellState(isEnable: false, sel: sel)
        }else{
            setCellState(isEnable: true, sel: sel)
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
    func isSinglePicture(model:HEPhotoPickerListModel) ->Bool{
        return model.asset.mediaType == .image &&  pickerOptions.singlePicture == true
    }
    func isSingleVideo(model:HEPhotoPickerListModel) ->Bool{
        return model.asset.mediaType == .video &&  pickerOptions.singleVideo == true
    }
    /// 如果当前模型是单选模式隐藏多选按钮
    ///
    /// - Parameter model: 当前模型
    func checkIsSingle(model:HEPhotoPickerListModel){
        if isSinglePicture(model: model) ||  isSingleVideo(model: model) {
            model.isEnableSelected = false
        }
    }
    
    // MARK:- UI Actions
    @objc func titleViewClick(_ sender:UIButton){
        sender.isSelected = true
        let popViewFrame : CGRect!
        popViewFrame = CGRect.init(x: 0, y: (navigationController?.navigationBar.frame.maxY)!, width: kScreenWidth, height: kScreenHeight/2)
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
        todoArray = selectedModels
        getImages()
    }
    @objc  func goBack(){
        navigationController?.dismiss(animated: true, completion: nil)
        delegate?.pickerControllerDidCancel?(self)
    }
    
    //  MARK:- 获取全部图片
    private func getAllPhotos() {
        switch pickerOptions.mediaType{
        case .image:
            photosOptions.predicate = NSPredicate.init(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        case .video:
            photosOptions.predicate = NSPredicate.init(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        default:
            break
        }
        photosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: pickerOptions.ascendingOfCreationDateSort)]
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
                if collection.localizedTitle == "所有照片"
                    || collection.localizedTitle == "All Photos"
                    || collection.localizedTitle == "相机胶卷"
                    || collection.localizedTitle == "Camera Roll" {
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
                        if collection.localizedTitle == "所有照片"
                            || collection.localizedTitle == "All Photos"
                            || collection.localizedTitle == "相机胶卷"
                            || collection.localizedTitle == "Camera Roll"{
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
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    public  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:HEPhotoPickerCell.className , for: indexPath) as! HEPhotoPickerCell
        let model = models[indexPath.row]
        cell.model = model
        cell.checkBtnnClickClosure = {[unowned self] (selectedBtn) in
            if !selectedBtn.isSelected{
                self.updateSelectedCell(sel: indexPath.row, isSelected: true)
            }else{
                self.updateSelectedCell(sel: indexPath.row, isSelected: false)
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
            photoDetail.imageIndex = indexPath
            photoDetail.models = self.models
            photoDetail.selectedModels = self.selectedModels
            photoDetail.selectedCloser = { selectedIndex in
                self.updateSelectedCell(sel: selectedIndex, isSelected: true)
            }
            photoDetail.unSelectedCloser = { selectedIndex in
                self.updateSelectedCell(sel: selectedIndex, isSelected: false)
            }
            photoDetail.clickBottomCellCloser = { selectedIndex in
               collectionView.scrollToItem(at: IndexPath.init(item: selectedIndex, section: 0), at: .centeredVertically, animated: false)
                
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
        // 获取指定cell的laout
        let cellLayout = collectionView.layoutAttributesForItem(at: indexPath)
        let homeFrame =  UIApplication.shared.keyWindow?.convert(cellLayout?.frame ??  CGRect.zero, from: collectionView) ?? CGRect.zero
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

