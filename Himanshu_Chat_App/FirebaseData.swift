//
//  FirebaseData.swift
//  Himanshu_Chat_App
//
//  Created by Ongraph Technologies on 19/07/22.
//

import Foundation
import UIKit

struct FirebaseData : Hashable , Codable{
    var Name : String
    var email : String
    var picUrl : String
    var userId : String 
    var isLogin : Bool
    
    init(name: String, email: String , picUrl : String , userId : String , isLogin : Bool) {
        self.Name = name
        self.email = email
        self.picUrl = picUrl
        self.userId = userId
        self.isLogin = isLogin
      }
}

struct receivedData : Hashable {
    var message  : String
    var time : String
    var picUrl : String
    var audioUrl : String
    var date : String
    var senderId : String
    var receiverId : String
    var seen : Bool
    var receiverIsLogin : Bool
    var videoURL : String
    var videoThumbnail : String
}
