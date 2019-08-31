//
//  HEAlbumListView.swift
//  HEPhotoPicker
//
//  Created by heyode on 2018/10/26.
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
typealias HEAlbumListViewCloser = ((_ :HEAlbumListView,_ : HEAlbum,_ selIndexPath:IndexPath)->Void)
class HEAlbumListView: UIView {
  
    var didSelectedCloser : HEAlbumListViewCloser?
    var dismissCloser : (()->Void)?
    var assetCollections = [HEAlbum]()
    lazy var backgroundView : UIView = {
        let backView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(HEAlbumListView.backViewTap))
        backView.addGestureRecognizer(tap)
        backView.backgroundColor = UIColor.init(r: 0, g: 0, b: 0, a: 0.1)
        return backView
    }()
    lazy var tableView : UITableView = {
        let table = UITableView.init(frame:self.bounds)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        let budle = Bundle.heBundle
        table.register(UINib.init(nibName: HEAlbumListCell.className, bundle: budle), forCellReuseIdentifier: HEAlbumListCell.className)
        return table
    }()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static func showOnKeyWidows(rect:CGRect,assetCollections:[HEAlbum],cellClick:@escaping HEAlbumListViewCloser,dismiss:(()->Void)? = nil) ->HEAlbumListView{
       var startRect = rect
        // 给视图增加弹性效果的额外高度
        startRect.size.height = rect.height + 4
        startRect.origin.y = -startRect.size.height
        // 弥补增加额外高度
        let endRectY = rect.origin.y - 4
        
         let listView = HEAlbumListView.init(frame:  startRect)
        listView.assetCollections = assetCollections
        listView.didSelectedCloser = cellClick
        listView.dismissCloser = dismiss
        UIApplication.shared.keyWindow?.addSubview(listView.backgroundView)
        UIApplication.shared.keyWindow?.addSubview(listView)
        UIView.animate(withDuration: 0.5, animations: {
            listView.frame.origin.y = rect.origin.y
           
        }) { (_) in
            UIView.animate(withDuration: 0.2, animations: {
                listView.frame.origin.y = endRectY
            }, completion: { (_) in
                
            })
        }
        return listView
    }
    
    public func dismiss(){
        removeFromSuperview()
        backgroundView.removeFromSuperview()
    }
    private func dismissAnimate(){
        let startY = frame.origin.y + 4
        let endY = -frame.size.height
        tableView.alpha = 1
        UIView.animate(withDuration: 0.2, animations: {
            self.frame.origin.y = startY
            
        }) { (_) in
            UIView.animate(withDuration: 0.2, animations: {
                self.frame.origin.y = endY
                self.tableView.alpha = 0.2
            }, completion: { (_) in
                self.dismiss()
                if let block = self.dismissCloser{
                    block()
                }
            })
        }
        
    }
    // - Action
    @objc func backViewTap(){
        
       dismissAnimate()
    }
}
extension HEAlbumListView : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assetCollections.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HEAlbumListCell.className, for: indexPath) as! HEAlbumListCell
        cell.album = assetCollections[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let blcok = didSelectedCloser {
            blcok(self,assetCollections[indexPath.row],indexPath)
            dismissAnimate()
        }
        
    }
}
