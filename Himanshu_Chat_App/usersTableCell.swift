//
//  usersTableCell.swift
//  Himanshu_Chat_App
//
//  Created by Ongraph Technologies on 19/07/22.
//

import UIKit

class usersTableCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var userEmail: UILabel!
  
    @IBOutlet weak var onlineView: UIView?
    
    static let sharedInstance = usersTableCell()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
