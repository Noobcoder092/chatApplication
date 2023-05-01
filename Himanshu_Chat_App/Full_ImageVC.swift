//
//  Full_ImageVC.swift
//  Himanshu_Chat_App
//
//  Created by Ongraph Technologies on 18/10/22.
//

import UIKit
import SDWebImage

class Full_ImageVC: UIViewController {

    @IBOutlet weak var selectedImage: UIImageView!
    
    var imageLink : String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedImage.isUserInteractionEnabled = true
        guard let imageLink = imageLink else {
            return
        }
        DispatchQueue.main.async {
            self.selectedImage.sd_setImage(with: URL(string: "\(imageLink)"))
        }
        let zoomImage = UIPinchGestureRecognizer(target: self, action: #selector(self.zoomImage(sender:)))
        selectedImage.addGestureRecognizer(zoomImage)
    }
    
    @objc func zoomImage(sender : UIPinchGestureRecognizer){
        if sender.state == .began || sender.state == .changed {
            sender.view?.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!
                   sender.scale = 1
        }
//        if sender.scale > 150 {
//            sender.scale = 150
//        } else if sender.scale < 100 {
//            sender.scale = 100
//        }
    }
}
