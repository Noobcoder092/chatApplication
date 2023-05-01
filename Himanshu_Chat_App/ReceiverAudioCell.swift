//
//  ReceiverAudioCell.swift
//  Himanshu_Chat_App
//
//  Created by Ongraph Technologies on 30/09/22.
//

import UIKit
import AVFoundation

class ReceiverAudioCell: UITableViewCell , AVAudioPlayerDelegate{

    @IBOutlet weak var imgAudioPlayer: UIImageView!
    
    @IBOutlet weak var lblTime: UILabel!
    
    var audioUrl : String? = nil
    var audioPLayer : AVAudioPlayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    @IBAction func btnPlayAudio(_ sender: Any) {
        guard let audioUrl = audioUrl else {
            print("audioUrl not found")
            return
        }
        self.downloadFileFromURL(url:NSURL(string: "\(audioUrl)")!)
    }
    
       func downloadFileFromURL(url:NSURL){
           var downloadTask:URLSessionDownloadTask
           downloadTask = URLSession.shared.downloadTask(with: url as URL, completionHandler: { url, response, error in
               if error == nil{
                   guard let audioUrl = url?.absoluteString else {
                       return
                   }
                   self.playReceivedAudio(audioUrl: URL(string: "\(audioUrl)")!)
               }
           })
           downloadTask.resume()
       }
    
    func playReceivedAudio(audioUrl : URL){
        let asset = AVURLAsset(url: audioUrl)
        let audioDuration = asset.duration.timescale
        print(audioDuration)
//        let durationInSeconds = CMTimeGetSeconds(audioDuration)
//        print(durationInSeconds)
        do{
            self.audioPLayer = try AVAudioPlayer(contentsOf: audioUrl)
            self.audioPLayer.delegate = self
            self.audioPLayer.prepareToPlay()
            self.audioPLayer.volume = 100.0
            self.audioPLayer.play()
            self.imgAudioPlayer.loadGif(name: "Player")
        }
        catch{
            print("Unable to play received audio,", error.localizedDescription)
        }
    }

}
