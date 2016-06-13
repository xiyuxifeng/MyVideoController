//
//  MyVideoViewController.swift
//  MyVideoController
//
//  Created by WangHui on 16/6/12.
//  Copyright © 2016年 WangHui. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class MyVideoViewController: UIViewController {
    
    var isLoop: Bool!
    var isContinue: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isLoop = getLoopMode()
        isContinue = getNewVCPlayMode()
        
        createPlayer()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // 监听完成事件
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyVideoViewController.playbackFinished(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        // 监听失败事件
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyVideoViewController.playbackError(_:)), name: AVPlayerItemFailedToPlayToEndTimeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyVideoViewController.orientationChanged(_:)) , name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        addPlayer()
        
        if isContinue == true {
            play()
        } else {
            replay()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemFailedToPlayToEndTimeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func orientationChanged(notification: NSNotification) {
        // 全屏旋转时改变frame
        MyPlayer.shareInstance.playerLayer?.frame = view.layer.bounds
    }
}

// MARK: - Player Method
extension MyVideoViewController {
    
    class MyPlayer {
        static var shareInstance = MyPlayer()
        private init() {}
        
        var playerLayer: AVPlayerLayer?
    }
    
    // 创建PlayerLayer
    func createPlayer() {
        
        var playerLayer = MyPlayer.shareInstance.playerLayer
        
        if playerLayer == nil {
            
            let urlString = getVideoUrl()
            var url: NSURL?
            
            if urlString.hasPrefix("https://") || urlString.hasPrefix("http://") {
                url = NSURL(string: urlString)
            } else {
                url = NSBundle.mainBundle().URLForResource(urlString, withExtension: getVideoType())
            }
            
            guard let _ = url else {
                fatalError("请正确配置URL")
            }
            
            // AVPlayer
            let item = AVPlayerItem(URL: url!)
            playerLayer = AVPlayerLayer(player: AVPlayer(playerItem: item))
            playerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            playerLayer?.frame = view.layer.bounds
            
            // 保存playerLayer
            MyPlayer.shareInstance.playerLayer = playerLayer
        }
    }
    
    // 添加AVPlayerLayer
    func addPlayer() {
        var isAdd = false
        if view.layer.sublayers?.count > 0 {
            for layer in view.layer.sublayers! {
                if layer is AVPlayerLayer {
                    isAdd = true
                    break
                }
            }
        }
        
        if !isAdd {
            // 添加 执行过releasePlayer后playerLayer = nil
            if let playerLayer = MyPlayer.shareInstance.playerLayer {
                playerLayer.zPosition = -1
                view.layer.addSublayer(playerLayer)
            }
        }
    }
    
    // 播放
    func play() {
        MyPlayer.shareInstance.playerLayer?.player?.play()
    }
    
    // 重新播放
    func replay() {
        // 跳到最新的时间点开始播放
        let myPlayer = MyPlayer.shareInstance.playerLayer?.player
        myPlayer?.seekToTime(CMTimeMake(0, 1))
        myPlayer?.play()
    }
    
    // 暂停
    func pause() {
        MyPlayer.shareInstance.playerLayer?.player?.pause()
    }
    
    // release 方法 当不需要再显示Video的时候可以调用释放资源
    func releasePlayer() {
        let myPlayer = MyPlayer.shareInstance
        myPlayer.playerLayer?.player?.pause()
        myPlayer.playerLayer?.player = nil
        myPlayer.playerLayer?.removeFromSuperlayer()
        myPlayer.playerLayer = nil
    }
    
    // 播放完成
    func playbackFinished(notification: NSNotification) {
        if isLoop == true {
            replay()
        }
    }
    
    // 播放失败
    func playbackError(notification: NSNotification) {
        replay()
    }
}

// MARK: - VideoInfo Method
extension MyVideoViewController {
    
    enum VideoInfo: String {
        case URL            // 设置播放Video的名称或路径 网络Video可以设置网址
        case VideoType      // Video类型 MP4
        case LoopMode       // 是否循环播放 默认为true
        case NewVCPlayContinue  // 当弹出新页面的时候 是否接着上一个页面的播放时间 继续播放 默认为true
    }
    
    private func getUserInfo() -> NSDictionary {
        let _path = NSBundle.mainBundle().pathForResource("video-info", ofType: "plist")
        
        guard let path = _path else {
            fatalError("没有找到video-info.plist,请确认正确配置了")
        }
        
        let dict = NSDictionary(contentsOfFile: path)!
        return dict
    }
    
    private func getVideoUrl() -> String {
        let videoUrl = getUserInfo().objectForKey(VideoInfo.URL.rawValue)
        
        guard let url = videoUrl as? String else {
            fatalError("请配置URL")
        }
        return url
    }
    
    private func getVideoType() -> String {
        let videoType = getUserInfo().objectForKey(VideoInfo.VideoType.rawValue)
        
        guard let type = videoType as? String else {
            fatalError("请配置VideoType")
        }
        return type
    }
    
    private func getLoopMode() -> Bool {
        let loopMode = getUserInfo().objectForKey(VideoInfo.LoopMode.rawValue)
        
        guard let loop = loopMode as? Bool else {
            return true
        }
        return loop
    }
    
    private func getNewVCPlayMode() -> Bool {
        let playContinue = getUserInfo().objectForKey(VideoInfo.NewVCPlayContinue.rawValue)
        
        guard let play = playContinue as? Bool else {
            return true
        }
        return play
    }
}