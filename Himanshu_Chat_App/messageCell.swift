//
//  messageCell.swift
//  Himanshu_Chat_App
//
//  Created by Ongraph Technologies on 20/07/22.
//

import UIKit

class messageCell: UITableViewCell {
    
    @IBOutlet weak var lblmessage: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var imgSent: UIImageView!
    @IBOutlet weak var imgRead: UIImageView!
    @IBOutlet weak var imgDelivered: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgDelivered.isHidden = true
        self.imgRead.isHidden = true 
        messageView.layer.cornerRadius = 10
    }
}
