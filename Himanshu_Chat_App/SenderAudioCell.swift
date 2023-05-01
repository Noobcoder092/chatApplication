//
//  SenderAudioCell.swift
//  Himanshu_Chat_App
//
//  Created by Ongraph Technologies on 30/09/22.
//

import UIKit
import AVFoundation

class SenderAudioCell: UITableViewCell, AVAudioPlayerDelegate {

    @IBOutlet weak var lblTime : UILabel!

    @IBOutlet weak var imgSent: UIImageView!
    
    @IBOutlet weak var imgDelievered: UIImageView!
    
    @IBOutlet weak var imgRead: UIImageView!
    
    @IBOutlet weak var imgAudioPlayer: UIImageView!
    
    var audioUrl : String? = nil
    var audioPlayer : AVAudioPlayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgDelievered.isHidden = true
        self.imgRead.isHidden = true
    }
    
    @IBAction func btnPlayAudio(_ sender: Any) {
        guard let audioUrl = audioUrl else {
            print("NO Audio url found")
            return 
        }
        self.downloadFileFromURL(url: NSURL(string: "\(audioUrl)") as! NSURL)
    }
 
    func downloadFileFromURL(url:NSURL){
        var downloadTask:URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url as URL, completionHandler: { url, response, error in
            if error == nil{
                guard let audioUrl = url?.absoluteString else {
                    return
                }
                self.setupPlayer(audioUrl: audioUrl)
            }
        })
        downloadTask.resume()
    }
    
    func setupPlayer(audioUrl : String) {
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: NSURL(string: audioUrl) as! URL)
            self.audioPlayer.delegate = self
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.volume = 100.0
            self.audioPlayer.play()
//            let asset = AVURLAsset(url: NSURL(string: "\(audioUrl)") as! URL)
//            let audioDuration = asset.duration
            self.imgAudioPlayer.loadGif(name: "Player")
        } catch {
            print("Error while playing audio ," , error.localizedDescription)
        }
    }
}
