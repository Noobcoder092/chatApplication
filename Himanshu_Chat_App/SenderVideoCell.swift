//
//  SenderVideoCell.swift
//  Himanshu_Chat_App
//
//  Created by Ongraph Technologies on 29/12/22.
//

import UIKit

class SenderVideoCell: UITableViewCell {
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgVIdeo: UIImageView!
    
    @IBOutlet weak var imgSent: UIImageView!
    @IBOutlet weak var imgDeileverd: UIImageView!
    @IBOutlet weak var imgRead: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgRead.isHidden = true
    }

}
