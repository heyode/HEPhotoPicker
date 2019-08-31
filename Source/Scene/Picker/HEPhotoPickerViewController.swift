//
//  HEPhotoPickerViewController.swift
//  SwiftPhotoSelector
//
//  Created by heyode on 2018/9/19.
//  Copyright (c) 2018 heyode <1025335931@qq.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.



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
    func pickerController(_ picker:UIViewController, didFinishPicking selectedImages:[UIImage],selectedModel:[HEPhotoAsset])
    
    /// 选择照片取消后调用的方法
    ///
    /// - Parameter picker: 选择图片的控制器
    @objc optional func pickerControllerDidCancel(_ picker:UIViewController)
}


public class HEPhotoPickerViewController: HEBaseViewController {
    // MARK : - Public
    /// 选择器配置
    public var pickerOptions : HEPickerOptions!
    /// 选择完成后的相关代理
    public var delegate : HEPhotoPickerViewControllerDelegate?
    
    // MARK : - Private
    /// 图片列表的数据模型
    private var models : [HEPhotoAsset]!
    /// 选中的数据模型
    private var selectedModels =  [HEPhotoAsset](){
        didSet{
            if let first = selectedModels.first{
                // 记录上一次选中模型集合中的数据类型
                preSelecetdType = first.asset.mediaType
            }
        }
    }
    
    /// 选中的图片模型（若有视频，则取它第一帧作为图片保存）
    private lazy var selectedImages = [UIImage]()
    /// 用于处理选中的数组
    private lazy var todoArray = [HEPhotoAsset]()
  
    /// 相册请求项
    private let photosOptions = PHFetchOptions()
    /// 过场动画
    private var animator = HEPhotoBrowserAnimator()
    ///  相册原有数据
    private var smartAlbums :PHFetchResult<PHAssetCollection>!
    /// 整理过后的相册
    private var albumModels : [HEAlbum]!
    /// 所有展示的多媒体数据集合
    private var phAssets : PHFetchResult<PHAsset>!
    /// 相册按钮
    private var titleBtn : UIButton!
    
    /// titleBtn展开的tableView的上一个选中的IndexPath
    private var preSelectedTableViewIndex = IndexPath.init(row: 0, section: 0 )
    /// titleBtn展开的tableView的上一个选中的con
    private var preSelectedTableViewContentOffset = CGPoint.zero
    
    /// 待刷新的IndexPath（imageOrVideo模式下更新cell可用状态专用）
    private var willUpadateIndex = Set<IndexPath>()
    /// 当选中数组为空时，记录上一次选中模型集合中的数据类型（imageOrVideo模式下更新cell可用状态专用）
    private var preSelecetdType : PHAssetMediaType!
    
    /// 图片视图
    private lazy var collectionView : UICollectionView = {
        
        let cellW = (self.view.frame.width - 3) / 4.0
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: cellW, height: cellW)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        var height = CGFloat(0)
        if UIDevice.isContansiPhoneX(){
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
    public init(delegate: HEPhotoPickerViewControllerDelegate,options:HEPickerOptions = HEPickerOptions() ) {
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
        
        navigationController?.delegate = self
        
        configPickerOption()
        
        requestAndFetchAssets()
       
    }
    
    private func requestAndFetchAssets() {
        if HETool.canAccessPhotoLib() {
            self.getAllPhotos()
        } else {
            HETool.requestAuthorizationForPhotoAccess(authorized:self.getAllPhotos, rejected: HETool.openIphoneSetting)
        }
    }
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func configUI() {
        view.addSubview(collectionView)
        
        let btn = HEAlbumTitleView.init(type: .custom)
        titleBtn = btn
        if let title = albumModels.first?.title{
            btn.setTitle(title, for: .normal)
        }
        btn.addTarget(self, action: #selector(HEPhotoPickerViewController.titleViewClick(_:)), for: .touchUpInside)
        
        navigationItem.titleView = btn
        let rightBtn = HESeletecedButton.init(type: .custom)
        rightBtn.setTitle(pickerOptions.selectDoneButtonTitle)
        
        rightBtn.addTarget(self, action: #selector(nextBtnClick), for: .touchUpInside)
        let right = UIBarButtonItem.init(customView: rightBtn)
        navigationItem.rightBarButtonItem = right
        rightBtn.isEnabled = false
    }
    
    override public func configNavigationBar() {
        super.configNavigationBar()
        navigationItem.leftBarButtonItem = setLeftBtn()
    }
    
    func setLeftBtn() -> UIBarButtonItem{
        let leftBtn = UIButton.init(type: .custom)
        leftBtn.setTitle(pickerOptions.cancelButtonTitle, for: .normal)
        leftBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        leftBtn.setTitleColor(UIColor.gray, for: .normal)
        let left = UIBarButtonItem.init(customView: leftBtn)
        return left
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
        let rightBtn = navigationItem.rightBarButtonItem?.customView as! HESeletecedButton
        rightBtn.isEnabled = selectedModels.count > 0
        if selectedModels.count > 0 {
            rightBtn.setTitle(String.init(format: "%@(%d)",pickerOptions.selectDoneButtonTitle, selectedModels.count))
        }else{
            rightBtn.setTitle(pickerOptions.selectDoneButtonTitle)
        }
        
        
    }
    
    /// 数据源重置后更新UI
    func updateUI(){
        updateNextBtnTitle()
        setCellState(selectedIndex: nil, isUpdateSelecetd: true)
        
    }
    
    
    // MARK: - 更新cell
    
    /// 更新cell的选中状态
    ///
    /// - Parameters:
    ///   - selectedIndex: 选中的索引
    ///   - selectedBtn: 选择按钮
    func updateSelectedCell(selectedIndex:Int,selectedBtn:UIButton) {
        let model = self.models[selectedIndex]
        if selectedBtn.isSelected {
            switch model.asset.mediaType {
            case .image:
                let selectedImageCount =  self.selectedModels.count{$0.asset.mediaType == .image}
                guard selectedImageCount < self.pickerOptions.maxCountOfImage  else{
                    let title = String.init(format: pickerOptions.maxPhotoWaringTips, self.pickerOptions.maxCountOfImage)
                    presentAlert(title: title)
                    selectedBtn.isSelected = false
                    return
                }
            case .video:
                let selectedVideoCount =  self.selectedModels.count{$0.asset.mediaType == .video}
                guard selectedVideoCount < self.pickerOptions.maxCountOfVideo else{
                    let title = String.init(format: pickerOptions.maxVideoWaringTips, self.pickerOptions.maxCountOfVideo)
                    presentAlert(title: title)
                    selectedBtn.isSelected = false
                    return
                }
            default:
                break
            }
            selectedBtn.isSelected = true
            self.selectedModels.append(model)
        }else{// 切勿使用index去匹配
            self.selectedModels.removeAll(where: {$0.asset.localIdentifier == model.asset.localIdentifier})
            selectedBtn.isSelected = false
        }
        models[selectedIndex].isSelected = selectedBtn.isSelected
        updateNextBtnTitle()
        
        // 根据当前用户选中的个数，将所有未选中的cell重置给定可用状态
        setCellState(selectedIndex: selectedIndex)
        
    }
    /// 设置cell的可用和选中状态
    ///
    /// - Parameters:
    ///   - selectedIndex:当前选中的cell索引
    ///   - isUpdateSelecetd: 是否更新选中状态
    func setCellState(selectedIndex:Int?,isUpdateSelecetd:Bool = false){
        // 初始化将要刷新的索引集合
        willUpadateIndex = Set<IndexPath>()
        let  selectedCount = selectedModels.count
        let  optionMaxCount = pickerOptions.maxCountOfImage + pickerOptions.maxCountOfVideo
        // 尽量将所有需要更新状态的操作都放在这个循环里面，节约开销
        for item in models{
            if isUpdateSelecetd == true{// 整个数据源重置，要重设选中状态
                item.isSelected = selectedModels.contains(where: {$0.asset.localIdentifier == item.asset.localIdentifier})
            }
            // 如果未选中的话，并且是imageOrVideo，就需要更新cell的可用状态
            // 根据当前用户选中的个数，将所有未选中的cell重置给定可用状态
            if item.isSelected == false && pickerOptions.mediaType == .imageOrVideo{
                // 选中的数量小于允许选中的最大数，就可用
                if selectedCount < optionMaxCount &&  item.isEnable == false{
                    // 选中的数量小于允许选中的最大数，就可用
                    item.isEnable = true
                    // 将待刷新的索引加入到数组
                    willUpadateIndex.insert(IndexPath.init(row: item.index, section: 0))
                }else if selectedCount >= optionMaxCount &&  item.isEnable == true{//选中的数量大于或等于最大数，就不可用
                    item.isEnable = false
                    // 将待刷新的索引加入到数组
                    willUpadateIndex.insert(IndexPath.init(row: item.index, section: 0))
                }
                if  selectedModels.count > 0{
                    if selectedModels.first?.asset.mediaType == .image{ // 用户选中的是图片的话，就把视频类型的cell都设置为不可选中
                        if item.asset.mediaType == .video{
                            item.isEnable = false
                            if let i = selectedIndex,item.index != i{// 点击是自动刷新，所以要排除
                                // 将待刷新的索引加入到数组
                                willUpadateIndex.insert(IndexPath.init(row: item.index, section: 0))
                            }
                        }
                    }else if selectedModels.first?.asset.mediaType == .video{
                        if item.asset.mediaType == .image{
                            item.isEnable = false
                            if let i = selectedIndex,item.index != i{// 点击是自动刷新，所以要排除
                                willUpadateIndex.insert(IndexPath.init(row: item.index, section: 0))
                            }
                        }
                    }
                }
                
            }
            if selectedModels.count <= 0  && pickerOptions.mediaType == .imageOrVideo{//是imageOrVideo状态下，取消所有选择，要找出哪些cell需要刷新可用状态
                item.isEnable = true
                // 将待刷新的索引加入到数组
                willUpadateIndex.insert(IndexPath.init(row: item.index, section: 0))
            }
        }
        

        
        if isUpdateSelecetd {// 整个数据源重置，必须刷新所有cell
            collectionView.reloadData()
        }else{
           
            collectionView.reloadItems(at: Array.init(willUpadateIndex) )
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
    func isSinglePicture(model:HEPhotoAsset) ->Bool{
        return model.asset.mediaType == .image &&  pickerOptions.singlePicture == true
    }
    func isSingleVideo(model:HEPhotoAsset) ->Bool{
        return model.asset.mediaType == .video &&  pickerOptions.singleVideo == true
    }
    /// 如果当前模型是单选模式隐藏多选按钮
    ///
    /// - Parameter model: 当前模型
    func checkIsSingle(model:HEPhotoAsset){
        if isSinglePicture(model: model) ||  isSingleVideo(model: model) {
            model.isEnableSelected = false
        }
    }
    
    // MARK:- UI Actions
    @objc func titleViewClick(_ sender:UIButton){
        sender.isSelected = true
        let popViewFrame : CGRect!
        popViewFrame = CGRect.init(x: 0, y: (navigationController?.navigationBar.frame.maxY)!, width: kScreenWidth, height: kScreenHeight/2)
        let listView =  HEAlbumListView.showOnKeyWidows(rect: popViewFrame, assetCollections: albumModels, cellClick: { [weak self](list,ablum,selecedIndex) in
            self?.preSelectedTableViewIndex = selecedIndex
            //            self?.preSelectedTableViewContentOffset = list.tableView.contentOffset
            self?.titleBtn.setTitle(ablum.title, for: .normal)
            self?.titleBtn.sizeToFit()
            
            self?.fetchPhotoModels(photos: ablum.fetchResult)
            self?.updateUI()
            
            },dismiss:{
                sender.isSelected = false
        })
        
        listView.tableView.selectRow(at: preSelectedTableViewIndex, animated: false, scrollPosition:.middle)
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
        fetchPhotoModels(photos: phAssets)
        
        getAllAlbums()
        // 注册相册库的通知(要写在getAllPhoto后面)
        PHPhotoLibrary.shared().register(self)
        
        configUI()
        if selectedModels.count > 0{
            updateUI()
        }
    }
    func getAllAlbums(){
        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        fetchAlbumsListModels(albums: smartAlbums)
    }
    private func fetchPhotoModels(photos:PHFetchResult<PHAsset>){
        models =  [HEPhotoAsset]()
        photos.enumerateObjects {[weak self] (asset, index, ff) in
            let model = HEPhotoAsset.init(asset: asset)
            self?.checkIsSingle(model: model)
            model.index = index
            self?.models.append(model)
            self?.collectionView.reloadData()
        }
    }
    private func fetchAlbumsListModels(albums:PHFetchResult<PHAssetCollection>){
        albumModels = [HEAlbum]()
        albums.enumerateObjects { [weak self] (collection, index, stop) in
            let asset = PHAsset.fetchAssets(in: collection, options: self!.photosOptions)
            let album = HEAlbum.init(result: asset, title: collection.localizedTitle)
            if asset.count > 0 && collection.localizedTitle != "最近删除" &&  collection.localizedTitle != "Recently Deleted"{
                if collection.localizedTitle == "所有照片"
                    || collection.localizedTitle == "All Photos"
                    || collection.localizedTitle == "相机胶卷"
                    || collection.localizedTitle == "Camera Roll" {
                    self?.albumModels.insert(album, at: 0)
                }else{
                    self?.albumModels.append(album)
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
            HETool.heRequestImage(for: (todoArray.first?.asset)!, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill) {[weak self] (image, _) in
                DispatchQueue.main.async {
                    self?.todoArray.removeFirst()
                    self?.selectedImages.append(image ?? UIImage())
                    self?.getImages()
                }
            }
        }
        
    }
    
    
}

extension HEPhotoPickerViewController: PHPhotoLibraryChangeObserver{
    open  func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            if let changeDetails = changeInstance.changeDetails(for: phAssets){
                phAssets = changeDetails.fetchResultAfterChanges
                fetchPhotoModels(photos: phAssets)
            }
            // Update the cached fetch results, and reload the table sections to match.
            if let changeDetails = changeInstance.changeDetails(for: smartAlbums) {
                smartAlbums = changeDetails.fetchResultAfterChanges
                fetchAlbumsListModels(albums: smartAlbums)
                if let title = albumModels.first?.title{
                    titleBtn.setTitle(title, for: .normal)
                    titleBtn.sizeToFit()
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
        cell.pickerOptions = self.pickerOptions
        cell.checkBtnnClickClosure = {[unowned self] (selectedBtn) in
            
            self.updateSelectedCell(selectedIndex: indexPath.row, selectedBtn: selectedBtn)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        animator.selIndex = indexPath
        let size = CGSize.init(width: kScreenWidth, height: kScreenWidth)
        HETool.heRequestImage(for: phAssets[indexPath.row] ,
                                              targetSize: size,
                                              contentMode: .aspectFill)
        { (image, nil) in
            let photoDetail = HEPhotoBrowserViewController()
            photoDetail.delegate = self.delegate
            photoDetail.pickerOptions = self.pickerOptions
            photoDetail.imageIndex = indexPath
            photoDetail.models = self.models
            photoDetail.selectedModels = self.selectedModels
            photoDetail.selectedCloser = { selectedIndex in
                self.models[selectedIndex].isSelected = true
                self.selectedModels.append(self.models[selectedIndex])
                self.updateUI()
                
            }
            photoDetail.unSelectedCloser = { selectedIndex in
                self.models[selectedIndex].isSelected = false
                self.selectedModels.removeAll{$0 == self.models[selectedIndex]}
                self.updateUI()
                
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
    
}

