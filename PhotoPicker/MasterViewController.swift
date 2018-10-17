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

    @IBOutlet weak var collectionView: UICollectionView!
    
    var visibleImages = [UIImage](){
        didSet{
            if oldValue != visibleImages{
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "从相册选择照片"
    }
  
    @IBAction func selectorBtnClick(_ sender: Any) {
        let picker = HEPhotoPickerViewController()
        picker.delegate = self
        picker.maxCount = 5
        let nav = UINavigationController.init(rootViewController: picker)
        self.present(nav, animated: true, completion: nil)
    }
}
extension MasterViewController : HEPhotoPickerViewControllerDelegate{
    func pickerController(_ picker: UIViewController, didFinishPicking selectedImages: [UIImage]) {
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
         return visibleImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MasterCell.className, for: indexPath) as? MasterCell else {
             fatalError("unexpected cell in collection view")
        }
        cell.imageView.image = visibleImages[indexPath.row]
        return cell
    }
    
 
}
