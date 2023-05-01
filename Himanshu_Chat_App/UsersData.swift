//
//  FirebaseUserData.swift
//  Himanshu_Chat_App
//
//  Created by Ongraph Technologies on 19/07/22.
//

import UIKit
import SDWebImage
import FirebaseAuth
import Firebase


class UsersData: UIViewController , UITableViewDataSource,UITableViewDelegate {
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userEmail: UILabel!
    
    var database = Firestore.firestore()
    var messageListener : ListenerRegistration?
    
    var fireBaseUsers = [FirebaseData]()
    var senderId : String? = nil
    var senderEmail : String? = nil
    var userID : String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        printViewControllerHierarchy(viewController: self)
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "LOG OUT", style: .done, target: self, action: #selector(UsersData.btnLogOut(_:)))
        guard let senderId = senderId else {
            return
        }
        guard let senderEmail = senderEmail else {
            return
        }
        self.fecthingFirebaseData(senderId: senderId)
        self.userEmail.text = senderEmail
        let reference = self.database.collection("Users")
        messageListener = reference.addSnapshotListener({(snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in snapshot!.documents {
                    let documentId = document.documentID
                    let userId = document.get("userId") as! String
                    let Name = document.get("Name") as! String
                    let email = document.get("email") as! String
                    let picUrl = document.get("picUrl") as! String
                    guard let isLogin = document.get("isLogin") as? Bool else {
                        return
                    }
                    self.userID = userId
                    if isLogin == true && userId != self.senderId{
                        for i in self.fireBaseUsers.indices{
                            if self.fireBaseUsers[i].isLogin == false && userId == self.fireBaseUsers[i].userId{
                                self.fireBaseUsers[i].isLogin = true
                            }
                        }
                        self.tableView.reloadData()
                    }
                    else{
                        for i in self.fireBaseUsers.indices{
                            if self.fireBaseUsers[i].isLogin == true && userId == self.fireBaseUsers[i].userId {
                                self.fireBaseUsers[i].isLogin = false
                            }
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    @IBAction func btnLogOut(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fireBaseUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersTableCell", for: indexPath) as! usersTableCell
        let imageUrl = URL(string: fireBaseUsers[indexPath.row].picUrl)
        if let url = imageUrl {
            cell.userImage.setImageWithURL(url, placeholderImage: UIImage())
        }
        cell.userName.text = fireBaseUsers[indexPath.row].Name
        cell.userEmail.text = fireBaseUsers[indexPath.row].email
        if fireBaseUsers[indexPath.row].isLogin == true && self.senderId != fireBaseUsers[indexPath.row].userId{
            cell.onlineView?.backgroundColor = .green
        }
        else {
            cell.onlineView?.backgroundColor = .red
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let VC = storyboard?.instantiateViewController(withIdentifier: "chatVC") as! chatVC
        VC.receiverName = fireBaseUsers[indexPath.row].Name
        VC.receiverId = fireBaseUsers[indexPath.row].userId
        VC.receiverIslogin = fireBaseUsers[indexPath.row].isLogin
        VC.senderId = senderId
        self.navigationController?.pushViewController(VC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let senderId = senderId {
            if senderId == fireBaseUsers[indexPath.row].userId{
                return 0
            }
        }
        return 100
    }
}

extension UIImageView {
    func setImageWithURL(_ url:URL, placeholderImage: UIImage){
        self.sd_setImage(with: url, placeholderImage: placeholderImage, options: .highPriority, context: nil)
    }
}

extension UsersData {
    func fecthingFirebaseData(senderId : String){
        let reference = self.database.collection("Users")
        messageListener = reference.addSnapshotListener({ (snapshot, err) in
            self.fireBaseUsers.removeAll()
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in snapshot!.documents {
                    let documentId = document.documentID
                    let userId = document.get("userId") as! String
                    let Name = document.get("Name") as! String
                    let email = document.get("email") as! String
                    let picUrl = document.get("picUrl") as! String
                    guard let isLogin = document.get("isLogin") as? Bool else {
                        return
                    }
                    if userId == senderId {                          // UPDATING DOCUMENT
                        self.database.collection("Users").document(documentId).updateData(["isLogin" : true])
                    }
                    self.fireBaseUsers.append(FirebaseData(name: Name ?? "name not found", email: email ?? "email not found", picUrl: picUrl ?? "no image found", userId: userId, isLogin: isLogin))
                    print(FirebaseData(name: Name, email: email, picUrl: picUrl, userId: userId, isLogin: isLogin))
                    print(self.fireBaseUsers.count)
                }
            }
        })
    }
    
    func printViewControllerHierarchy(viewController: UIViewController) {
        print(viewController.className)
        for child in viewController.children {
            printViewControllerHierarchy(viewController: child)
        }
    }
}

extension UIViewController {
    var className: String {
        return String(describing: type(of: self))
    }
}

