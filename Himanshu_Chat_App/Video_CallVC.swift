//
//  Video_CallVC.swift
//  Himanshu_Chat_App
//
//  Created by Ongraph Technologies on 19/10/22.
//

import UIKit
import AgoraRtcKit

class Video_CallVC : UIViewController {
    
    @IBOutlet weak var selfVideoView: UIView!
    
    @IBOutlet weak var receiverVideoView: UIView!
    
    @IBOutlet weak var btnSpeakerOutlet: UIButton!
    
    @IBOutlet weak var btnMuteOutlet: UIButton!
    
    @IBOutlet weak var btnHideVideoOutlet: UIButton!
    
    var agoraEngine: AgoraRtcEngineKit!
    var userRole: AgoraClientRole = .broadcaster
    let appID = "38854693649c4f50a4377bee6bf377a5"
    var RTCtoken = "007eJxTYFj7Tm+K4mN1iZIrC2uP56XwN6ZmFYXXxThGX92R7KjQzKzAYGxhYWpiZmlsZmKZbJJmapBoYmxunpSaapaUBmQkmgZXv0luCGRkkG35w8jIAIEgviCDR2ZuYl5xRmm8c0ZiSbxjQQEDAwB15yKv"
    var channelName = "Himanshu_Chat_App"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.receiverVideoView.isHidden = true
        self.initializeAgoraEngine()
        self.joinChannel()
    }
    
    @IBAction func btnEndCall(_ sender: Any) {
        self.leaveChannel()
    }
    
    @IBAction func btnMute(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.agoraEngine.muteLocalAudioStream(sender.isSelected)
        if sender.isSelected{
            self.btnMuteOutlet.setImage(UIImage(named: "btn_mute_blue"), for: .normal) 
        }
        else{
            self.btnMuteOutlet.setImage(UIImage(named: "btn_mute"), for: .normal)
        }
    }
    
    @IBAction func btnSpeaker(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.agoraEngine.setEnableSpeakerphone(sender.isSelected)
        if sender.isSelected{
            self.btnSpeakerOutlet.setImage(UIImage(named: "btn_speaker_blue"), for: .normal)
        }
        else{
            self.btnSpeakerOutlet.setImage(UIImage(named: "btn_speaker"), for: .normal)
        }
    }
    
    @IBAction func btnSwitchCamera(_ sender: Any) {
        self.agoraEngine.switchCamera()
    }
    
    @IBAction func btnHideVideo(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.agoraEngine.muteLocalVideoStream(sender.isSelected)
        if sender.isSelected {
            self.selfVideoView.alpha = 0.2
            
        }
        else{
            self.selfVideoView.alpha = 1.0
        }
    }
}

extension Video_CallVC : AgoraRtcEngineDelegate{
    
    func initializeAgoraEngine() {
        let config = AgoraRtcEngineConfig()
        config.appId = appID
        agoraEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
    }
    
    func joinChannel() -> Bool {
        let option = AgoraRtcChannelMediaOptions()
        
        if self.userRole == .broadcaster {
            option.clientRoleType = .broadcaster
            setupLocalVideo()
        } else {
            option.clientRoleType = .audience
        }
        
        option.channelProfile = .communication
        
        let result = agoraEngine.joinChannel(
            byToken: RTCtoken, channelId: channelName, uid: 0, mediaOptions: option,
            joinSuccess: { (channel, uid, elapsed) in }
        )
        
        if (result == 0) {
            print("Successfully joined the video channel")
        }
        return true
    }
    
    func leaveChannel() {
        agoraEngine.stopPreview()
        let result = agoraEngine.leaveChannel(nil)
        if (result == 0) {
            print("Successfully left the video channel")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        self.receiverVideoView.isHidden = false
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .hidden
        videoCanvas.view = receiverVideoView
        agoraEngine.setupRemoteVideo(videoCanvas)
    }
    
    func setupLocalVideo() {
        agoraEngine.enableVideo()
        agoraEngine.startPreview()
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = selfVideoView
        agoraEngine.setupLocalVideo(videoCanvas)
    }
}
