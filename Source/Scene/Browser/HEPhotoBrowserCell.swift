//
//  HEPhotoBrowserCell.swift
//  SwiftPhotoSelector
//
//  Created by heyode on 2018/9/23.
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
class HEPhotoBrowserCell: UICollectionViewCell {
    var playerLayer: AVPlayerLayer?

    var imageView : UIImageView!
    var palyBtn : UIButton!
    var palyBtnCloser :((_ cell:UICollectionViewCell,_ model:HEPhotoAsset)->Void)?
    var model : HEPhotoAsset!{
        didSet{
            palyBtn.isHidden = model.asset.mediaType != .video
            
            HETool.heRequestImage(for: model.asset,
                                                  targetSize: self.bounds.size,
                                                  contentMode: .aspectFill)
            { (image, nil) in
                self.imageView.image = image
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.black
        self.contentView.addSubview(imageView)
        
        palyBtn = UIButton.init(type: .custom)
        palyBtn.addTarget(self, action: #selector(HEPhotoBrowserCell.palyBtnClick), for: .touchUpInside)
        
        palyBtn.isHidden = true
        palyBtn.setImage(UIImage.heinit(name: "play-btn"), for: .normal)
        contentView.addSubview(palyBtn)
    }
    
    @objc func palyBtnClick()  {
        palyBtn.isHidden = true
        play(asset: model.asset)
    }

    func play(asset:PHAsset) {
        if playerLayer != nil {
            playerLayer?.player!.play()
        } else {
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .automatic
            PHImageManager.default().requestPlayerItem(forVideo:asset, options: options, resultHandler: { playerItem, info in
                DispatchQueue.main.sync {
                    guard self.playerLayer == nil else { return }
                    
                    let player = AVPlayer(playerItem: playerItem)
                    let playerLayer = AVPlayerLayer(player: player)
                    
                    playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                    playerLayer.frame = self.layer.bounds
                    self.contentView.layer.insertSublayer(playerLayer, below: self.palyBtn.layer)
                    
                    player.play()
                  
                    self.playerLayer = playerLayer
                }
            })
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
         guard self.playerLayer != nil else { return }
        playerLayer?.player!.pause()
        palyBtn.isHidden = false
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
        let playBtnW = CGFloat(100)
        let playBtnH = playBtnW
        palyBtn.frame = CGRect.init(x: (self.bounds.width-playBtnW)/2, y: (self.bounds.height-playBtnH)/2, width: playBtnW, height: playBtnH)

        
    }
    deinit {
       canlePlayerAction()
    }
    
    func canlePlayerAction() {
        
        guard self.playerLayer != nil else { return }
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        palyBtn.isHidden = false

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
