//
//  SenderImageCell.swift
//  Himanshu_Chat_App
//
//  Created by Ongraph Technologies on 27/09/22.
//

import UIKit

class SenderImageCell: UITableViewCell {

    
    @IBOutlet weak var sentImage: UIImageView!
    
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var imgSent: UIImageView!
    
    @IBOutlet weak var imgDelievered: UIImageView!
    
    @IBOutlet weak var imgRead: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgDelievered.isHidden = true
        self.imgRead.isHidden = true
    }
    
}
