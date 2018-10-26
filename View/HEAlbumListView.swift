//
//  HEAlbumListView.swift
//  HEPhotoPicker
//
//  Created by apple on 2018/10/26.
//

import UIKit

class HEAlbumListView: UIView {
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
        let budle = Bundle(path: Bundle(for: HEAlbumListView.self).path(forResource: "HEPhotoPicker", ofType: "bundle")!)!
        table.register(UINib.init(nibName: HEAlbumListCell.className, bundle: budle), forCellReuseIdentifier: HEAlbumListCell.className)
        return table
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(tableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static func showOnKeyWidows(rect:CGRect,cellClick:((_: Any)->Void)) ->HEAlbumListView{
        let listView = HEAlbumListView.init(frame: rect)
        UIApplication.shared.keyWindow?.addSubview(listView.backgroundView)
        UIApplication.shared.keyWindow?.addSubview(listView)
        return listView
    }
    
    public func dismiss(){
        self.removeFromSuperview()
        backgroundView.removeFromSuperview()
    }
    // - Action
    @objc func backViewTap(){
        dismiss()
    }
}
extension HEAlbumListView : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HEAlbumListCell.className, for: indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss()
    }
}
