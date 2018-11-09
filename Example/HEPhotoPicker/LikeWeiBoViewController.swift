//
//  LikeWeiBoViewController.swift
//  HEPhotoPicker_Example
//
//  Created by apple on 2018/11/6.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import HEPhotoPicker
import Photos
class LikeWeiBoViewController: UIViewController {
    var animator : HEPhotoBrowserAnimator = {
        let a = HEPhotoBrowserAnimator()
        a.transitionType = .modal
        return a
    }()
    var homeFrame = CGRect.zero
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedModel = [HEPhotoPickerListModel]()
    var visibleImages = [UIImage](){
        didSet{
            if oldValue != visibleImages{
                collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
}
extension LikeWeiBoViewController : HEPhotoPickerViewControllerDelegate{
    func pickerController(_ picker: UIViewController, didFinishPicking selectedImages: [UIImage],selectedModel:[HEPhotoPickerListModel]) {
        // 实现多次累加选择时，需要把选中的模型保存起来，传给picker
        self.selectedModel = selectedModel
      
        self.visibleImages = selectedImages
        picker.dismiss(animated: true, completion: nil)
    }
    func pickerControllerDidCancel(_ picker: UIViewController) {
        // 取消选择后的一些操作
    }
    
}
extension LikeWeiBoViewController : UICollectionViewDelegate,UICollectionViewDataSource{

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let first = selectedModel.first {
            if first.asset.mediaType == .video{
                return selectedModel.count
            }
        }
        return selectedModel.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MasterCell.className, for: indexPath) as? MasterCell else {
            fatalError("unexpected cell in collection view")
        }
        if indexPath.row < selectedModel.count {
            
            cell.mediaModel = self.selectedModel[indexPath.row]
            
            cell.closeBtn.isHidden = false
            cell.closeBtnClickHandle = {[weak self] in
                self?.visibleImages.remove(at: indexPath.row)
                self?.selectedModel.remove(at: indexPath.row)
                self?.collectionView.reloadData()
            }
        }else{// 添加图片的的cell
            cell.imageView.image = UIImage.init(named: "add-btn")
            cell.durationBackView.isHidden = true
            cell.closeBtn.isHidden = true
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < selectedModel.count {
            animator.selIndex = indexPath
            let option = PHImageRequestOptions()
                option.isSynchronous = true
            option.resizeMode = .none
            let size = CGSize.init(width: kScreenWidth, height: kScreenWidth)
            PHImageManager.default().requestImage(for:selectedModel[indexPath.row].asset ,
                                                  targetSize: size,
                                                  contentMode: .aspectFill,
                                                  options: option)
            { (image, nil) in
                let browser = BrowserViewController()
                browser.image = image!
                browser.imageIndex = indexPath
                browser.models = self.selectedModel
                browser.selectedModels = self.selectedModel
                self.animator.popDelegate = browser
                self.animator.pushDelegate = self
                browser.modalPresentationStyle = .custom
                
                browser.transitioningDelegate = self.animator 
                self.present(browser, animated: true, completion: nil)
            }
        }else{// 添加图片的的cell被点击时
            self.view.endEditing(true)
            // 配置项
            let option = HEPhotoPickerOptions.init()
            // 只能选择一个视频
            option.singleVideo = true
            // 图片和视频只能选择一种
            option.mediaType = .imageOrVideo
            // 将上次选择的数据传入，表示支持多次累加选择，
            option.defaultSelections = self.selectedModel
            // 选择图片的最大个数
            option.maxCountOfImage = 9
            // 创建选择器
            let picker = HEPhotoPickerViewController.init(delegate: self, options: option)
            // 弹出
            hePresentPhotoPickerController(picker: picker)
            
        }
    }
    
}


extension LikeWeiBoViewController: HEPhotoBrowserAnimatorPushDelegate{
    
    public func imageViewRectOfAnimatorStart(at indexPath: IndexPath) -> CGRect {
        guard   let cell = collectionView.cellForItem(at: indexPath) as? MasterCell else{
            fatalError("unexpected cell in collection view")
        }
        homeFrame =   UIApplication.shared.keyWindow?.convert(cell.imageView.frame, from: cell.contentView) ?? CGRect.zero
        //返回具体的尺寸
        return homeFrame
    }
    public func imageViewRectOfAnimatorEnd(at indexPath: IndexPath) -> CGRect {
        //取出cell
        let cell = (collectionView.cellForItem(at: indexPath))! as! MasterCell
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
        let cell = (collectionView.cellForItem(at: indexPath))! as! MasterCell
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
