//
//  VideoRecorderVC.swift
//  Himanshu_Chat_App
//
//  Created by Ongraph Technologies on 28/12/22.
//

import UIKit
import AVFoundation
import AVKit
import FirebaseFirestore
import FirebaseStorage

protocol takeDataBack{
    func takeVideoUrl(url:URL)
}

class VideoRecorderVC: UIViewController {
    
    @IBOutlet weak var camPreview: UIView!
    @IBOutlet weak var btnRecordVideo: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var imgRecordVideo: UIImageView!
    @IBOutlet weak var btnFlipCamera: UIButton!
    @IBOutlet weak var imgFlipCamera: UIImageView!
    
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    
    var dataBase = Firestore.firestore()
    var collectionReference : CollectionReference?
    var delegate : takeDataBack?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnSend.isHidden = true
        self.btnCancel.isHidden = true
        if setupSession() {
            setupPreview()
            startSession()
        }
    }
    
    func setupPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
            self.previewLayer.frame = self.camPreview.bounds
            self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.camPreview.layer.addSublayer(self.previewLayer)
        })
    }
    
    func setupSession() -> Bool {
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        // Setup Camera
        let camera = AVCaptureDevice.default(for: AVMediaType.video)!
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        // Setup Microphone
        let microphone = AVCaptureDevice.default(for: AVMediaType.audio)!
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
        
        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        return true
    }
    
    func startSession() {
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    //    func stopSession() {
    //        if captureSession.isRunning {
    //            videoQueue().async {
    //                self.captureSession.stopRunning()
    //            }
    //        }
    //    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    func startRecording() {
        
        if movieOutput.isRecording == false {
            
            let connection = movieOutput.connection(with: AVMediaType.video)
            
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            let device = activeInput.device
            
            if (device.isSmoothAutoFocusSupported) {
                
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
                
            }
            
            //EDIT2: And I forgot this
            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            
        }
        else {
            stopRecording()
        }
    }
    
    func stopRecording() {
        
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
        }
    }
    
    
    @IBAction func btnCancelAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnRecordVideo(_ sender: UIButton) {
        if !sender.isSelected {
            self.startRecording()
            self.imgRecordVideo.image = UIImage(named: "btnStop")
            self.imgFlipCamera.isHidden = true
            self.btnFlipCamera.isUserInteractionEnabled = false
            self.btnSend.isHidden = true
            self.btnCancel.isHidden = true
            sender.isSelected = true
        }
        else{
            self.stopRecording()
            self.imgRecordVideo.image = UIImage(named: "btnRecord")
            self.btnSend.isHidden = false
            self.btnCancel.isHidden = false
            self.btnRecordVideo.isHidden = true
            self.imgRecordVideo.isHidden = true
            sender.isSelected = false
        }
    }
    
    @IBAction func btnFlipCameraAction(_ sender: UIButton) {

        if !sender.isSelected{
            print("Front")
            if let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput {
                let currentPosition = currentInput.device.position
                let newPosition: AVCaptureDevice.Position = currentPosition == .front ? .back : .front

                let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition)

                do {
                    let newInput = try AVCaptureDeviceInput(device: newDevice!)
                    captureSession.beginConfiguration()
                    captureSession.removeInput(currentInput)
                    captureSession.addInput(newInput)
                    captureSession.commitConfiguration()
                } catch {
                    print("Error changing camera: \(error)")
                }
            }
            sender.isSelected = true
        }
        else{
            print("BACK")
            if let currentInput = captureSession.inputs.last as? AVCaptureDeviceInput {
                let currentPosition = currentInput.device.position
                let newPosition: AVCaptureDevice.Position = currentPosition == .front ? .back : .front

                let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition)

                do {
                    let newInput = try AVCaptureDeviceInput(device: newDevice!)
                    captureSession.beginConfiguration()
                    captureSession.removeInput(currentInput)
                    captureSession.addInput(newInput)
                    captureSession.commitConfiguration()
                } catch {
                    print("Error changing camera: \(error)")
                }
            }
            sender.isSelected = true
        }
    }
    
    @IBAction func btnSendAction(_ sender: Any) {
        self.uploadVideoTOFireBase(url: outputURL)
        self.navigationController?.popViewController(animated: true)
    }
}

extension VideoRecorderVC : AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        }
        else {
            if let videoRecorded = outputURL {
                self.playRecordedVideo(filePath: videoRecorded)
            }
        }
    }
    
    func playRecordedVideo(filePath : URL){
        let player = AVPlayer(url: URL(fileURLWithPath: "\(filePath)"))
        let vc = AVPlayerViewController()
        vc.player = player
        present(vc, animated: true)
    }
}

extension  VideoRecorderVC{
    
    func uploadVideoTOFireBase(url: URL) {
        
        let name = "\(Int(Date().timeIntervalSince1970)).mp4"
        let path = NSTemporaryDirectory() + name
        
        let dispatchgroup = DispatchGroup()
        
        dispatchgroup.enter()
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputurl = documentsURL.appendingPathComponent(name)
        var ur = outputurl
        self.convertVideo(toMPEG4FormatForVideo: url as URL, outputURL: outputurl) { (session) in
            
            ur = session.outputURL!
            dispatchgroup.leave()
        }
        dispatchgroup.wait()
        
        let data = NSData(contentsOf: ur as URL)
        
        do {
            try data?.write(to: URL(fileURLWithPath: path), options: .atomic)
        } catch {
            
            print(error)
        }
        
        let storageRef = Storage.storage().reference().child("sentVideos").child(name)
        if let uploadData = data as Data? {
            storageRef.putData(uploadData, metadata: nil
                               , completion: { (metadata, error) in
                if let error = error {
                    print("Error while sending video to firebase",error.localizedDescription)
                }else{
                    storageRef.downloadURL { url, error in
                        print("video URL",url)
                        self.delegate?.takeVideoUrl(url: url!)
                    }
                }
            })
        }
    }
    
    func convertVideo(toMPEG4FormatForVideo inputURL: URL, outputURL: URL, handler: @escaping (AVAssetExportSession) -> Void) {
        let asset = AVURLAsset(url: inputURL as URL, options: nil)
        
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously(completionHandler: {
            handler(exportSession)
        })
    }
}
