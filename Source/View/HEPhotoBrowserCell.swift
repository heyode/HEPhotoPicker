//
//  HEPhotoBrowserCell.swift
//  SwiftPhotoSelector
//
//  Created by heyode on 2018/9/23.
//  Copyright © 2018年 heyode. All rights reserved.
//

import UIKit
import Photos
class HEPhotoBrowserCell: UICollectionViewCell {
    var playerLayer: AVPlayerLayer?

    var imageView : UIImageView!
    var palayBtn : UIButton!
    var palyBtnCloser :((_ cell:UICollectionViewCell,_ model:HEPhotoPickerListModel)->Void)?
    var model : HEPhotoPickerListModel!{
        didSet{
            
            if model.asset.mediaType == .video {
                palayBtn.isHidden = false
               
            }else{
                palayBtn.isHidden = true
            }
            let options = PHImageRequestOptions()
            PHCachingImageManager.default().requestImage(for: model.asset,
                                                  targetSize: self.bounds.size,
                                                  contentMode: .aspectFill,
                                                  options: options)
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
        
        palayBtn = UIButton.init(type: .custom)
        palayBtn.addTarget(self, action: #selector(HEPhotoBrowserCell.palyBtnClick), for: .touchUpInside)
        palayBtn.isHidden = true
        palayBtn.setImage(UIImage.init(named: "play-btn", in: HETool.bundle, compatibleWith: nil), for: .normal)
        contentView.addSubview(palayBtn)
        
        
    }
    @objc func palyBtnClick()  {
        palayBtn.isHidden = true
        play(asset: model.asset)
    }
    /// - Tag: PlayVideo
    func play(asset:PHAsset) {
        if playerLayer != nil {
            // The app already created an AVPlayerLayer, so tell it to play.
            playerLayer?.player!.play()
        } else {
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .automatic
//            options.progressHandler = { progress, _, _, _ in
//                // The handler may originate on a background queue, soÒ
//                // re-dispatch to the main queue for UI work.
//                DispatchQueue.main.sync {
//                    //                    self.progressView.progress = Float(progress)
//                }
//            }
            // Request an AVPlayerItem for the displayed PHAsset.
            // Then configure a layer for playing it.
            PHImageManager.default().requestPlayerItem(forVideo:asset, options: options, resultHandler: { playerItem, info in
                DispatchQueue.main.sync {
                    guard self.playerLayer == nil else { return }
                    
                    // Create an AVPlayer and AVPlayerLayer with the AVPlayerItem.
                    let player = AVPlayer(playerItem: playerItem)
                    let playerLayer = AVPlayerLayer(player: player)
                    
                    // Configure the AVPlayerLayer and add it to the view.
                    playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                    playerLayer.frame = self.layer.bounds
                    self.contentView.layer.insertSublayer(playerLayer, below: self.palayBtn.layer)
                    
                    player.play()
                    
                    // Cache the player layer by reference, so you can remove it later.
                    self.playerLayer = playerLayer
                }
            })
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
         guard self.playerLayer != nil else { return }
        playerLayer?.player!.pause()
        palayBtn.isHidden = false
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
        let playBtnW = CGFloat(50)
        let playBtnH = playBtnW
        palayBtn.frame = CGRect.init(x: (self.bounds.width-playBtnW)/2, y: (self.bounds.height-playBtnH)/2, width: playBtnW, height: playBtnH)
        
    }
    deinit {
       canlePlayerAction()
    }
    
    func canlePlayerAction() {
        
        guard self.playerLayer != nil else { return }
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
//        playerLayer?.player!.pause()
        palayBtn.isHidden = false
//        playerLayer?.player?.seek(to: CMTime.init(value: 0, timescale: 1))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
