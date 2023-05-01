//
//  receivedMessageCell.swift
//  Himanshu_Chat_App
//
//  Created by Ongraph Technologies on 20/07/22.
//

import UIKit

class receivedMessageCell: UITableViewCell {

    @IBOutlet weak var lblmessage: UILabel!
    @IBOutlet weak var receiverMessageView : UIView!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        receiverMessageView.layer.cornerRadius = 10
    }
}
