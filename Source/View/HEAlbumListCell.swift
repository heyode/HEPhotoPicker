//
//  HEAlbumListCell.swift
//  HEPhotoPicker
//
//  Created by apple on 2018/10/25.
//

import UIKit
import Photos
class HEAlbumListCell: UITableViewCell {

    @IBOutlet weak var countLab: UILabel!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var albumImageView: UIImageView!
    var album : HEAlbum!{
        didSet{
            titleLab.text = album.title
       
            
            countLab.text = String.init(format: "%d", album.count)
            let scale = UIScreen.main.scale
            let size = CGSize.init(width: albumImageView.frame.width * scale, height:albumImageView.frame.height * scale)
            guard let asset = album.fetchResult.firstObject else{
                return
            }
            PHCachingImageManager.default().requestImage(for:asset,
                                                  targetSize: size,
                                                  contentMode: .aspectFill,
                                                  options: nil, resultHandler:  { image, _ in
                                                    self.albumImageView.image = image
            })
          
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
