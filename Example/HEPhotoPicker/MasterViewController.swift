//
//  ViewController.swift
//  SwiftPhotoSelector
//
//  Created by apple on 2018/9/19.
//  Copyright © 2018年 heyode. All rights reserved.
//

import UIKit
import Photos
class MasterViewController: UIViewController {

    @IBOutlet weak var maxCountTextfield: UITextField!
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    @IBAction func selectorBtnClick(_ sender: Any) {
        self.view.endEditing(true)
        let picker = HEPhotoPickerViewController(delegate: self)
        picker.delegate = self
        guard let str = maxCountTextfield.text,let count = Int(str) else {
            return
        }
        hePresentPhotoPickerController(picker: picker, maxCount: count)
        
    }
    @IBAction func cleanSelectedBtnClick(_ sender: Any) {
        self.view.endEditing(true)
        selectedModel = [HEPhotoPickerListModel]()
        visibleImages = [UIImage]()
        
    }
}
extension MasterViewController : HEPhotoPickerViewControllerDelegate{
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
extension MasterViewController : UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return visibleImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MasterCell.className, for: indexPath) as? MasterCell else {
             fatalError("unexpected cell in collection view")
        }
        if indexPath.row < visibleImages.count {
            cell.imageView.image = visibleImages[indexPath.row]
            
            cell.closeBtn.isHidden = false
            cell.closeBtnClickHandle = {[weak self] in
                self?.visibleImages.remove(at: indexPath.row)
                self?.selectedModel.remove(at: indexPath.row)
                self?.collectionView.reloadData()
            }
        }else{// 添加图片的的cell
           cell.imageView.image = UIImage.init(named: "add-btn")
            
           cell.closeBtn.isHidden = true
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < visibleImages.count {
        }else{// 添加图片的的cell被点击时
            let picker = HEPhotoPickerViewController(delegate: self)
            guard let str = maxCountTextfield.text,let count = Int(str) else {
                return
            }
            hePresentPhotoPickerController(picker: picker, maxCount: count,defaultSelections: selectedModel)
           
        }
    }
 
}
