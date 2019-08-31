//
//  LikeWeiBoViewController.swift
//  HEPhotoPicker_Example
//
//  Created by heyode on 2018/11/6.
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
import HEPhotoPicker
import Photos
class LikeWeiBoViewController: UIViewController {
    var animator : HEPhotoBrowserAnimator = {
        let a = HEPhotoBrowserAnimator()
        a.transitionType = .modal
        return a
    }()
    
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedModel = [HEPhotoAsset]()
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
    func pickerController(_ picker: UIViewController, didFinishPicking selectedImages: [UIImage],selectedModel:[HEPhotoAsset]) {
        // 实现多次累加选择时，需要把选中的模型保存起来，传给picker
        self.selectedModel = selectedModel
      
        self.visibleImages = selectedImages
        
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
            HETool.heRequestImage(for:selectedModel[indexPath.row].asset ,
                                                  targetSize: size,
                                                  contentMode: .aspectFill)
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
            let options = HEPickerOptions.init()
            // 只能选择一个视频
            options.singleVideo = true
            // 图片和视频只能选择一种
            options.mediaType = .imageOrVideo
            // 将上次选择的数据传入，表示支持多次累加选择，
            options.defaultSelections = self.selectedModel
            // 选择图片的最大个数
            options.maxCountOfImage = 9
            // 创建选择器
            let picker = HEPhotoPickerViewController.init(delegate: self, options:options)
            // 弹出
            hePresentPhotoPickerController(picker: picker, animated: true)
            
        }
    }
    
}


extension LikeWeiBoViewController: HEPhotoBrowserAnimatorPushDelegate{
    
    public func imageViewRectOfAnimatorStart(at indexPath: IndexPath) -> CGRect {
        // 获取指定cell的laout
        let cellLayout = collectionView.layoutAttributesForItem(at: indexPath)
        let homeFrame =  UIApplication.shared.keyWindow?.convert(cellLayout?.frame ??  CGRect.zero, from: collectionView) ?? CGRect.zero
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
