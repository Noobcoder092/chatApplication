//
//  callScreenVC.swift
//  Himanshu_Chat_App
//
//  Created by Ongraph Technologies on 18/10/22.
//

import UIKit
import AgoraRtcKit

class callScreenVC: UIViewController , AgoraRtcEngineDelegate {

    
    @IBOutlet weak var lblReceiverName: UILabel!
    
    @IBOutlet weak var lblCallDuration: UILabel!

    @IBOutlet weak var btnMute: UIButton!
    
    @IBOutlet weak var btnSpeaker: UIButton!
    var receiverName : String? = nil
    
    //  AGORA VOICE CALLING IMPLEMENTATION
    var agoraEngine : AgoraRtcEngineKit!
    var userRole : AgoraClientRole = .broadcaster
    let option = AgoraRtcChannelMediaOptions()
    let appID = "38854693649c4f50a4377bee6bf377a5"
    var RTCtoken = "007eJxTYLix6LvhY9Fsxd1Xvc2vrTx+Onrd/Tj11LU16nOsmhYG97xUYDC2sDA1MbM0NjOxTDZJMzVINDE2N09KTTVLSgMyEk1r1/knNwQyMixIlmdghEIQX5DBIzM3Ma84ozTeOSOxJN6xoICBAQB5OSUL"
    var channelName = "Himanshu_Chat_App"
    
    var timer = Timer()
    var counter = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        self.lblReceiverName.text = self.receiverName
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.initializeAgoraEngine()
        self.joinChannel()
    }

    @objc func updateTimer(){
        counter += 0.1
        self.lblCallDuration.text = String(format: "%.1f", counter)
    }
    
    @IBAction func btnEndCall(_ sender: UIButton) {
        self.leaveChannel()
        self.navigationController?.popViewController(animated: true)
//        self.timer.invalidate()
//        counter = 0
//        self.lblCallDuration.text = "\(0.0)"
    }
    
    @IBAction func btnSpeaker(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.agoraEngine.setEnableSpeakerphone(sender.isSelected)
        if sender.isSelected{
            self.btnSpeaker.setImage(UIImage(named: "btn_speaker_blue"), for: .normal)
        }
        else{
            self.btnSpeaker.setImage(UIImage(named: "btn_speaker"), for: .normal)
        }
    }
    
    @IBAction func btnMute(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.agoraEngine.muteLocalAudioStream(sender.isSelected)
        if sender.isSelected {
            self.btnMute.setImage(UIImage(named: "btn_mute_blue"), for: .normal)
        }
        else{
            self.btnMute.setImage(UIImage(named: "btn_mute"), for: .normal)
        }
    }
}

extension callScreenVC {                                  // IMPLEMENTING VOICE CALL HERE
    
    func joinChannel() -> Bool {
        if self.userRole == .broadcaster {
            option.clientRoleType = .broadcaster
        } else {
            option.clientRoleType = .audience
        }
        option.channelProfile = .communication
        
        let result = agoraEngine.joinChannel(
            byToken: RTCtoken, channelId: channelName, uid: 0, mediaOptions: option,
            joinSuccess: { (channel, uid, elapsed) in
            }
        )
        if (result == 0) {
            UIApplication.shared.isIdleTimerDisabled = true
            print("Successfully joined the audio channel")
        }
        return true
    }
    
    func leaveChannel(){
        let result = agoraEngine.leaveChannel(nil)
        if (result == 0) {
            UIApplication.shared.isIdleTimerDisabled = false
            print("Successfully left the audio channel")
        }
    }
    
    func initializeAgoraEngine() {
        let config = AgoraRtcEngineConfig()
        config.appId = appID
        agoraEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
    }
    
    // Callback called when a new host joins the channel
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        print(uid)
        print(userRole)
    }
}
