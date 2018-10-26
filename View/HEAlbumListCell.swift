//
//  HEAlbumListCell.swift
//  HEPhotoPicker
//
//  Created by apple on 2018/10/25.
//

import UIKit

class HEAlbumListCell: UITableViewCell {

    @IBOutlet weak var countLab: UILabel!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var albumImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
