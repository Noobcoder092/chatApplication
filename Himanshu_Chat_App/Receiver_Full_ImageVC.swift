//
//  Receiver_Full_ImageVC.swift
//  Himanshu_Chat_App
//
//  Created by Ongraph Technologies on 18/10/22.
//

import UIKit
import SDWebImage

class Receiver_Full_ImageVC: UIViewController {

    @IBOutlet weak var selectedImage: UIImageView!
    
    var fullImageLink : String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let fullImageLink = fullImageLink else {
            return
        }
        DispatchQueue.main.async {
            self.selectedImage.sd_setImage(with: URL(string: "\(fullImageLink)"))
        }
    }
}
