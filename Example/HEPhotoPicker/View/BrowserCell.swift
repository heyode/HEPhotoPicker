//
//  BrowserCell.swift
//  HEPhotoPicker_Example
//
//  Created by heyode on 2018/11/8.
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
class BrowserCell: UICollectionViewCell {
    var playerLayer: AVPlayerLayer?
    
    var imageView : UIImageView!
    var palayBtn : UIButton!
    var palyBtnCloser :((_ cell:UICollectionViewCell,_ model:HEPhotoAsset)->Void)?
    var model : HEPhotoAsset!{
        didSet{
            
            if model.asset.mediaType == .video {
                palayBtn.isHidden = false
                
            }else{
                palayBtn.isHidden = true
            }
            
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
        
        palayBtn = UIButton.init(type: .custom)
        palayBtn.addTarget(self, action: #selector(BrowserCell.palyBtnClick), for: .touchUpInside)
        palayBtn.isHidden = true
        palayBtn.setImage(UIImage.heinit(name: "play-btn"), for: .normal)
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
