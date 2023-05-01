// 
//  chatVC.swift
//  Himanshu_Chat_App
//
//  Created by Ongraph Technologies on 20/07/22.
//


import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase
import FirebaseDatabase
import MessageKit
import FirebaseStorage
import SDWebImage
import AVFoundation
import AVKit


class chatVC: UIViewController , UITableViewDataSource , UITableViewDelegate{
    
    @IBOutlet weak var typedMessages: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblReceiverName: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var lblOnline: UILabel?
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var btnCancelImage: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnRecorder: UIButton!
    @IBOutlet weak var btnGallery: UIButton!
    @IBOutlet weak var btnRecordVideo: UIButton!
    @IBOutlet weak var btnStopRecorder: UIButton!
    
    var arrMSG = [receivedData]()
    var senderId : String? = nil
    var senderName : String? = nil
    var receiverName : String? = nil
    var receiverId : String? = nil
    var online : Int = 1
    var onChatVc : Bool?
    var receiverIslogin : Bool?
    
    var audioRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var fileName: String = "audioFiles.m4a"
    
    let database = Firestore.firestore()  // ADDED
    var reference : CollectionReference?
    var messageListener : ListenerRegistration?
    
    deinit {
        messageListener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let voice_Call = UIBarButtonItem(title: "AUDIO", style: .done, target: self, action: #selector(chatVC.btnVoiceCall(_:)))
        let video_Call = UIBarButtonItem(title: "VIDEO", style: .done, target: self, action: #selector(chatVC.btnVideoCall(_:)))
        navigationItem.rightBarButtonItems = [voice_Call , video_Call]
        self.onChatVc = true
        self.typedMessages.delegate = self
        self.btnCancelImage.isHidden = true
        self.btnSend.isHidden = true
        self.btnStopRecorder.isHidden = true
        lblReceiverName.text = receiverName
        self.setupRecorder()
        self.fetchMyMessages()
        self.fetchReceivedMessages()
        self.fetchOnlinestatus()
        //       self.setBlueTickToMessages()
        
        guard let receiverId = receiverId else {
            return
        }
        guard let senderId = senderId else {
            return
        }
        
        let reference = database.collection("userMessages/\(receiverId)*\(senderId)/chatRoom")
        messageListener = reference.addSnapshotListener({ querySnapshot, error in
            if error == nil {
                if let snapShot = querySnapshot?.documents {
                    print("Received Message Count = ",snapShot.count)
                    for i in snapShot {
                        if let mainDict = i.data() as? [String : AnyObject] {
                            var senderId = mainDict["senderId"] as? String
                            let receiverId = mainDict["receiverId"] as? String
                            let message = mainDict["message"] as? String
                            let date = mainDict["date"] as? String
                            let time = mainDict["time"] as? String
                            let receiverIsLogin = mainDict["receiverIsLogin"] as? Bool
                            let picUrl = mainDict["picUrl"] as?  String
                            let seen = mainDict["seen"] as? Bool
                            let audioUrl = mainDict["audioUrl"] as? String
                            let videoUrl = mainDict["videoURL"] as? String
                            let videoThumbnail = mainDict["videoThumbnail"] as? String
                            // self.fetchMyMessages()
                            self.arrMSG.append(receivedData(message: message ?? "message not found", time: time ?? "time unavailable", picUrl: picUrl ?? "no image found", audioUrl: audioUrl ?? "no audio found", date: date ?? "date not found",senderId: senderId ?? "" , receiverId: receiverId ?? "", seen: seen ?? false, receiverIsLogin: receiverIsLogin ?? false, videoURL: videoUrl ?? "no video URL", videoThumbnail: videoThumbnail ?? "no thumbnail"))
                            self.tableView.reloadData()
                            print(mainDict)
                        }
                    }
                }
            }
        })
    }
    
    func saveMessages(_ message: Dictionary<String, Any>) {
        guard let senderId = self.senderId else {
            return
        }
        guard let receiverId = self.receiverId else {
            return
        }
        reference = database.collection("userMessages/\(senderId)*\(receiverId)/chatRoom")
        reference?.addDocument(data: message, completion: { error in
            if error != nil {
                print("Error while sending message")
            }
        })
    }
    
    @IBAction func btnVoiceCall(_ sender: Any) {
        let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "callScreenVC") as! callScreenVC
        storyboard.receiverName = self.receiverName
        self.navigationController?.pushViewController(storyboard, animated: true)
    }
    
    @IBAction func btnVideoCall(_ sender: Any){
        let videoCallVC = self.storyboard?.instantiateViewController(withIdentifier: "Video_CallVC") as! Video_CallVC
        self.navigationController?.pushViewController(videoCallVC, animated: true)
    }
    
    @IBAction func moveToUserListVc(_ sender : Any){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendMessage(_ sender: Any) {
        self.showMessageSendingAlert( )
        guard let message = typedMessages.text
        else{
            return
        }
        
        let userMessages = ["senderId" : senderId,"receiverId" : receiverId,"receiverName" :receiverName, "message" : message , "date" : getDate() , "time" : getTime() , "seen" : false , "receiverIsLogin" : false] as [String : Any]
        
        if typedMessages.text?.count != 0 {
            saveMessages(userMessages)           // SENDING MESSAGES TO FIREBASE
            self.tableView.reloadData()
            typedMessages.text = ""
        }
        
        if typedMessages.isHidden == true {
            self.uploadImage(selectedImage.image!) { url in
                print("Image sent to storage & firestore database")
            }
            self.btnCancelImage.isHidden = true
            self.selectedImage.isHidden = true
            self.typedMessages.isHidden = false
            self.btnSend.isHidden = true
            self.btnRecorder.isHidden = false
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.typedMessages.delegate = self
        if typedMessages.text?.count != 0{
            self.btnRecorder.isHidden = true
            self.btnSend.isHidden = false
        }
        else{
            self.btnSend.isHidden = true
            self.btnRecorder.isHidden = false
        }
    }
    
    
    @IBAction func btnRecordVideoAction(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "VideoRecorderVC") as! VideoRecorderVC
        viewController.delegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func btnRecorderAction(_ sender: Any) {
        self.btnStopRecorder.isHidden = false
        self.btnRecorder.isHidden = true
        self.audioRecorder.record()
        print("Started Recording.......")
    }
    
    @IBAction func btnStopRecorderAction(_ sender: Any) {
        self.showMessageSendingAlert()
        self.btnRecorder.isHidden = false
        self.btnStopRecorder.isHidden = true
        self.audioRecorder.stop()
        self.sendAudioToFirebase()
        print("Stopped Recording.........")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrMSG = arrMSG.removingDuplicates()
        return arrMSG.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        arrMSG = arrMSG.sorted(by: {$0.time < $1.time })
        arrMSG = arrMSG.sorted(by: {$0.date < $1.date})
        
        if self.senderId == arrMSG[indexPath.row].senderId {
            if arrMSG[indexPath.row].picUrl != "no image found"{     // SENDER IMAGE CELL
                let sentImagecell = tableView.dequeueReusableCell(withIdentifier: "SenderImageCell", for: indexPath) as! SenderImageCell
                sentImagecell.lblTime.text = arrMSG[indexPath.row].time
                if let url = URL(string: arrMSG[indexPath.row].picUrl){
                    DispatchQueue.main.async {
                        sentImagecell.sentImage.sd_setImage(with: url)
                    }
                }
                if arrMSG[indexPath.row].receiverIsLogin == true{
                    sentImagecell.imgSent.isHidden = true
                    sentImagecell.imgDelievered.isHidden = false
                }
                else {
                    sentImagecell.imgSent.isHidden = false
                    sentImagecell.imgDelievered.isHidden = true
                }
                return sentImagecell
            }                                           // SENDER AUDIO CELL
            else if arrMSG[indexPath.row].audioUrl != "no audio found" {
                let senderAudioCell = tableView.dequeueReusableCell(withIdentifier: "SenderAudioCell", for: indexPath) as! SenderAudioCell
                senderAudioCell.audioUrl = arrMSG[indexPath.row].audioUrl
                senderAudioCell.lblTime.text = arrMSG[indexPath.row].time
                if arrMSG[indexPath.row].receiverIsLogin == true{
                    senderAudioCell.imgSent.isHidden = true
                    senderAudioCell.imgDelievered.isHidden = false
                }
                else {
                    senderAudioCell.imgSent.isHidden = false
                    senderAudioCell.imgDelievered.isHidden = true
                }
                return senderAudioCell
            }
            else if arrMSG[indexPath.row].videoURL != "no video URL"{  // SENDER VIDEO CELL
                let SenderVideoCell = tableView.dequeueReusableCell(withIdentifier: "SenderVideoCell", for: indexPath) as! SenderVideoCell
                SenderVideoCell.lblTime.text  = arrMSG[indexPath.row].time
                SenderVideoCell.imgVIdeo.sd_setImage(with: URL(string: arrMSG[indexPath.row].videoThumbnail))
                if arrMSG[indexPath.row].receiverIsLogin == true{
                    SenderVideoCell.imgSent.isHidden = true
                    SenderVideoCell.imgDeileverd.isHidden = false
                }
                else {
                    SenderVideoCell.imgSent.isHidden = false
                    SenderVideoCell.imgDeileverd.isHidden = true
                }
                return SenderVideoCell
            }
            
            else {                                                // SENDER MESSAGE CELL
                let Sendercell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! messageCell
                Sendercell.lblmessage.text = arrMSG[indexPath.row].message
                Sendercell.lblTime.text = arrMSG[indexPath.row].time
                if arrMSG[indexPath.row].receiverIsLogin == true && arrMSG[indexPath.row].seen == true{
                    Sendercell.imgRead.isHidden = false
                    Sendercell.imgDelivered.isHidden = true
                    Sendercell.imgSent.isHidden = true
                }
                else if arrMSG[indexPath.row].receiverIsLogin == true {
                    Sendercell.imgDelivered.isHidden = false
                    Sendercell.imgSent.isHidden = true
                    Sendercell.imgRead.isHidden = true
                }  else{
                    Sendercell.imgSent.isHidden = false
                    Sendercell.imgRead.isHidden = true
                    Sendercell.imgDelivered.isHidden = true
                }
                return Sendercell
            }
        }
        else {                          // RECEIVER AUDIO CELL
            if arrMSG[indexPath.row].audioUrl != "no audio found"{
                let receiverAudioCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverAudioCell", for: indexPath) as! ReceiverAudioCell
                receiverAudioCell.audioUrl = arrMSG[indexPath.row].audioUrl
                receiverAudioCell.lblTime.text = arrMSG[indexPath.row].time
                return receiverAudioCell
            }
            else if arrMSG[indexPath.row].videoURL != "no video URL"{   // RECEIVER VIDEO CELL
                let recieverVideoCell = tableView.dequeueReusableCell(withIdentifier: "RecieverVideoCell", for: indexPath) as! RecieverVideoCell
                recieverVideoCell.lblTime.text = arrMSG[indexPath.row].time
                recieverVideoCell.imgVideo.sd_setImage(with: URL(string: arrMSG[indexPath.row].videoThumbnail))
                return recieverVideoCell
            }
            else {                                        // RECEIVER IMAGE CELL
                if arrMSG[indexPath.row].picUrl != "no image found"{
                    let receivedImageCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverImageCell", for: indexPath) as! ReceiverImageCell
                    receivedImageCell.lblTime.text = arrMSG[indexPath.row].time
                    if let url = URL(string: arrMSG[indexPath.row].picUrl) {
                        DispatchQueue.main.async {
                            receivedImageCell.receivedImage.sd_setImage(with: url)
                        }
                    }
                    return receivedImageCell
                }
                else{                     // RECEIVER MESSAGE CELL
                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "receivedMessageCell", for: indexPath) as! receivedMessageCell
                    receiverCell.lblmessage.text = arrMSG[indexPath.row].message
                    receiverCell.lblTime.text = arrMSG[indexPath.row].time
                    return receiverCell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.senderId == arrMSG[indexPath.row].senderId {
            if arrMSG[indexPath.row].picUrl != "no image found"{
                if let url = URL(string: arrMSG[indexPath.row].picUrl) {
                    DispatchQueue.main.async {
                        let fullImageVC = self.storyboard?.instantiateViewController(withIdentifier: "Full_ImageVC") as! Full_ImageVC
                        fullImageVC.imageLink = "\(url)"
                        self.navigationController?.pushViewController(fullImageVC, animated: true)
                    }
                }
            }
            else if arrMSG[indexPath.row].videoURL != "no video URL" {   // SENDER VIDEO TAP
                let url = arrMSG[indexPath.row].videoURL
                if let url = URL(string: "\(url)"){
                    let player = AVPlayer(url: url)
                    let controller=AVPlayerViewController()
                    controller.player=player
                    self.present(controller, animated: true)
                    player.play()
                }
            }
        }
        else{
            if arrMSG[indexPath.row].picUrl != "no image found"{
                if let url = URL(string: arrMSG[indexPath.row].picUrl) {
                    DispatchQueue.main.async {
                        let fullImageVC = self.storyboard?.instantiateViewController(withIdentifier: "Receiver_Full_ImageVC") as! Receiver_Full_ImageVC
                        fullImageVC.fullImageLink = "\(url)"
                        self.navigationController?.pushViewController(fullImageVC, animated: true)
                    }
                }
            }
            else if arrMSG[indexPath.row].videoURL != "no video URL"{   // RECEIVER VIDEO TAP
                let url = arrMSG[indexPath.row].videoURL
                if let url = URL(string: "\(url)"){
                    let player = AVPlayer(url: url)
                    let controller=AVPlayerViewController()
                    controller.player=player
                    self.present(controller, animated: true)
                    player.play()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arrMSG[indexPath.row].picUrl != "no image found"{
            return 150
        }
        else if arrMSG[indexPath.row].audioUrl != "no audio found"{
            return 80
        }
        else if arrMSG[indexPath.row].videoURL != "no video URL"{
            return 200
        }
        return UITableView.automaticDimension
    }
    
    @IBAction func btnCancelIMage(_ sender: Any) {
        self.btnSend.isHidden = true
        self.btnRecorder.isHidden = false
        self.selectedImage.isHidden = true
        self.typedMessages.isHidden = false
        self.btnCancelImage.isHidden = true
    }
}

extension chatVC  : UITextFieldDelegate {
    func getDate()->String{   // FOR FETCHING DATE
        let time = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "dd.MM.yyyy"
        let stringDate = timeFormatter.string(from: time)
        return stringDate
    }
    
    func getTime()->String{   // FOR FETCHING TIME
        let time = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH.mm.ss"
        let stringDate = timeFormatter.string(from: time)
        return stringDate
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.typedMessages.resignFirstResponder()
        return true
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

extension chatVC{
    
    func fetchOnlinestatus(){
        let reference = self.database.collection("Users")
        messageListener = reference.addSnapshotListener({(snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in snapshot!.documents {
                    let documentId = document.documentID
                    let userId = document.get("userId") as! String
                    let Name = document.get("Name") as! String
                    let islogin = document.get("isLogin") as! Bool
                    guard let receiverId = self.receiverId else {
                        return
                    }
                    if userId == receiverId && islogin == true{
                        self.lblOnline?.isHidden = false
                        self.receiverIslogin = true
                        for i in self.arrMSG.indices{
                            if self.arrMSG[i].receiverIsLogin == false {
                                self.arrMSG[i].receiverIsLogin = true
                            }
                        }
                        self.tableView.reloadData()
                        //                        self.fetchMyMessages() NO NEED
                    }
                    else if userId == receiverId && islogin == false{
                        self.lblOnline?.isHidden = true
                    }
                }
            }
        })
    }
    
    func fetchReceivedMessages() {
        
    }
    
    func fetchMyMessages(){
        guard let senderId = senderId else {
            return
        }
        guard let receiverId = receiverId else {
            return
        }
        let reference = database.collection("userMessages/\(senderId)*\(receiverId)/chatRoom")
        messageListener = reference.addSnapshotListener({ [self] querySnapshot, error in
            if error == nil {
                if let snapShot = querySnapshot?.documents {
                    print("My Message count =",snapShot.count)
                    for i in snapShot {
                        if let mainDict = i.data() as? [String : AnyObject] {
                            let senderId = mainDict["senderId"] as? String
                            let receiverId = mainDict["receiverId"] as? String
                            let message = mainDict["message"] as? String
                            let date = mainDict["date"] as? String
                            let time = mainDict["time"] as? String
                            let seen = mainDict["seen"] as? Bool
                            let receiverIsLogin = mainDict["receiverIsLogin"] as? Bool
                            let picUrl = mainDict["picUrl"] as? String
                            let audioUrl = mainDict["audioUrl"] as? String
                            let videoUrl = mainDict["videoURL"] as? String
                            let videoThumbnail = mainDict["videoThumbnail"] as? String
                            
                            let documentId = i.documentID as? String
                            self.dismiss(animated: true)
                            if self.receiverIslogin == true && seen != true {
                                reference.document(documentId ?? "nil").updateData(["receiverIsLogin" : true])
                                for i in arrMSG.indices{
                                    if arrMSG[i].receiverIsLogin == false && senderId == self.arrMSG[i].senderId{
                                        arrMSG[i].receiverIsLogin = true
                                    }
                                }
                            }
                            
                            if self.senderId == senderId{
                                self.arrMSG.append(receivedData(message: message ?? "message not found", time: time ?? "time unavailable", picUrl: picUrl ?? "no image found", audioUrl: audioUrl ?? "no audio found", date: date ?? "date not found", senderId: senderId ?? "" ,receiverId: receiverId ?? "", seen: seen ?? false, receiverIsLogin: receiverIsLogin ?? false, videoURL: videoUrl ?? "no video URL", videoThumbnail: videoThumbnail ?? "no thumbnail"))
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        })
    }
    
    //    func setBlueTickToMessages() {
    //        guard let receiverId = receiverId else {
    //            return
    //        }
    //        guard let senderId = senderId else {
    //            return
    //        }
    //
    //        let reference = database.collection("userMessages/\(receiverId)*\(senderId)/chatRoom")
    //        let newReference = database.collection("userMessages/\(senderId)*\(receiverId)/chatRoom")
    //        messageListener = reference.addSnapshotListener({ querySnapshot, error in
    //            if error == nil {
    //                if let snapShot = querySnapshot?.documents {
    //                    print("Received Message Count =",snapShot.count)
    //                    for i in snapShot {
    //                        if let mainDict = i.data() as? [String : AnyObject] {
    //                            var senderId = mainDict["senderId"] as? String
    //                            let receiverId = mainDict["receiverId"] as? String
    //                            let message = mainDict["message"] as? String
    //                            let date = mainDict["date"] as? String
    //                            let time = mainDict["time"] as? String
    //                            let receiverIsLogin = mainDict["receiverIsLogin"] as? Bool
    //                            let picUrl = mainDict["picUrl"] as?  String
    //                            let seen = mainDict["seen"] as? Bool
    //                            let documentId = i.documentID as? String
    //
    //    //                             UPDATING seen VALUE
    //
    //                                if self.receiverIslogin == true  && self.online == 1 && self.senderId == receiverId{
    //                                    DispatchQueue.main.async {
    //                                        newReference.document(documentId ?? "nil").updateData(["seen" : true])
    //                                        for i in self.arrMSG.indices{
    //                                            if self.arrMSG[i].seen == false{
    //                                                self.arrMSG[i].seen = true
    //                                            }
    //                                        }
    //                                    }
    //                                }
    //                            self.arrMSG.append(receivedData(message: message ?? "message not found", time: time ?? "time unavailable", picUrl: picUrl ?? "no image found", date: date ?? "date not found", senderId: senderId ?? "" ,receiverId: receiverId ?? "", seen: seen ?? false, receiverIsLogin: receiverIsLogin ?? false))
    //                            self.tableView.reloadData()
    //                        }
    //                    }
    //                    self.online = 2
    //                }
    //            }
    //
    //        })
    //    }
}

extension chatVC : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    @IBAction func btnCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.selectedImage.isHidden = false
        self.selectedImage.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.btnSend.isHidden = false
        self.btnRecorder.isHidden = true
        self.typedMessages.isHidden = true
        self.btnCancelImage.isHidden = false
        self.dismiss(animated: true)
    }
}

extension chatVC {
    
    func uploadImage( _ image : UIImage , completion: @escaping (_ url: String?) -> ()) {
        let storageRef = Storage.storage().reference().child("SentImages/\(UUID().uuidString).png")
        let imgData = selectedImage.image?.pngData()
        storageRef.putData(imgData! , metadata: nil) { (_,error) in
            if error == nil {
                storageRef.downloadURL(completion: {(url,error) in
                    if let urlGet = url {
                        let sentImages = ["senderId" : self.senderId,"receiverId" : self.receiverId,"receiverName" : self.receiverName, "picUrl" : "\(urlGet)" , "date" : self.getDate() , "time" : self.getTime() , "seen" : false , "receiverIsLogin" : false] as [String : Any]
                        self.saveMessages(sentImages)
                    }
                    print("Image Upload successfull")
                })
            }
            else{
                print("Unable to upload image")
                completion(nil)
            }
        }
    }
    
    func uplaodThumbnail( _ image : UIImage , videoURL : URL) {
        let storageRef = Storage.storage().reference().child("Thumbnails/\(UUID().uuidString).png")
        let imgData = image.pngData()
        storageRef.putData(imgData! , metadata: nil) { (_,error) in
            if error == nil {
                storageRef.downloadURL(completion: {(url,error) in
                    if let urlGet = url {
                        let sendVideo = ["senderId" : self.senderId!,"receiverId" : self.receiverId,"receiverName" : self.receiverName, "videoURL" : "\(videoURL)","videoThumbnail" : "\(urlGet)" , "date" : self.getDate() , "time" : self.getTime() , "seen" : false , "receiverIsLogin" : false] as [String : Any]
                        self.saveMessages(sendVideo)
                    }
                    print("Thumbnail Upload successfull")
                })
            }
            else{
                print("Unable to upload Thumbnail")
            }
        }
    }
    
    func sendAudioToFirebase(){
        let audioFile = getDocumentsDirectory().appendingPathComponent(fileName)
        let storageRef = Storage.storage().reference().child("SentAudios/\(UUID().uuidString).m4a")
        do {
            let audioData = try Data(contentsOf: audioFile.standardizedFileURL)
            storageRef.putData(audioData, metadata: nil){ (data, error) in
                if error == nil{
                    storageRef.downloadURL {url, error in
                        guard let audioURL = url else { return }
                        print("Download URL" , audioURL)
                        print("Audio converted to url succesfully")
                        let sendAudio = ["senderId" : self.senderId,"receiverId" : self.receiverId,"receiverName" : self.receiverName, "audioUrl" : audioURL.absoluteString , "date" : self.getDate() , "time" : self.getTime() , "seen" : false , "receiverIsLogin" : false] as [String : Any]
                        self.saveMessages(sendAudio)
                    }
                }
                else {
                    print("Unable to convert to url",error?.localizedDescription)
                }
            }
        }
        catch {
            debugPrint(error.localizedDescription)
        }
    }
}

extension chatVC : AVAudioRecorderDelegate , AVAudioPlayerDelegate {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func setupRecorder() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(fileName)
        let recordSetting = [ AVFormatIDKey : kAudioFormatAppleLossless,
                   AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                        AVEncoderBitRateKey : 320000,
                      AVNumberOfChannelsKey : 2,
                            AVSampleRateKey : 44100.2] as [String : Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: recordSetting )
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {
            print(error)
        }
    }
    
    func showMessageSendingAlert(){
        let alert = UIAlertController(title: "Sending Message...........", message: "SENDING :)", preferredStyle: .alert)
        self.present(alert, animated: true)
    }
}

extension chatVC : takeDataBack {
    
    func takeVideoUrl(url: URL) {
        self.showMessageSendingAlert()
        downloadVideoTumbnail(videoURL: url)
    }
    
    func downloadVideoTumbnail(videoURL : URL?){
        if let url  = videoURL{
            let asset = AVAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            
            let time = CMTime(seconds: 2, preferredTimescale: 1)
            do {
                let image = try generator.copyCGImage(at: time, actualTime: nil)
                let newImage = UIImage(cgImage: image)
                self.uplaodThumbnail(newImage, videoURL: URL(string: "\(url)")!)
            } catch {
                print("error during thumbnail download")
            }
        }
    }
}
