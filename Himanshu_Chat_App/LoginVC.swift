//
//  LoginVC.swift
//  Himanshu_Chat_App
//
//  Created by Ongraph Technologies on 30/09/22.
//

import UIKit
import Firebase
import FirebaseAuth


class LoginVC: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var loginView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.isHidden = true
        self.activityIndicator.color = .blue
    }
    
    let database = Firestore.firestore()
    var reference : CollectionReference?
    var messageListener : ListenerRegistration?
    
    var userArray = [FirebaseData]()
    
    @IBAction func btnLogin(_ sender: Any) {
        guard let email = txtEmail.text , let password = txtPassword.text  else {
            return
        }
        if email.isEmpty , password.isEmpty  {
            let alert = UIAlertController(title: "EMPTY MAIL OR PASSWORD", message: "Please fill login details", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true)
        }else{
            self.loginView.alpha = 0.5
            self.activityIndicator.style = .large
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            Auth.auth().signIn(withEmail: email, password: password) { (userData, error) in
                if error == nil{
                    self.fecthingFirebaseData(senderId: userData?.user.uid ?? "no value")
                    let alert = UIAlertController(title: "SAVE LOGIN CREDENTIALS", message: "Do you want to save your login details ?", preferredStyle: .alert)
                    let NO = UIAlertAction(title: "NO", style: .destructive) { _ in
                        let VC = self.storyboard?.instantiateViewController(withIdentifier: "UsersData") as! UsersData
                        VC.fireBaseUsers = self.userArray
                        VC.senderId = userData?.user.uid
                        VC.senderEmail = userData?.user.email
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidesWhenStopped = true
                        self.loginView.alpha = 1.0
                        self.navigationController?.pushViewController(VC, animated: true)
                    }
                    let YES = UIAlertAction(title: "YES", style: .cancel) { _ in
                        let VC = self.storyboard?.instantiateViewController(withIdentifier: "UsersData") as! UsersData
                        VC.fireBaseUsers = self.userArray
                        VC.senderId = userData?.user.uid
                        VC.senderEmail = userData?.user.email
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidesWhenStopped = true
                        self.loginView.alpha = 1.0
                        let loginDetails :[String:Any] = ["email" : email , "password":password , "userId":userData?.user.uid ]
                        if let encodedArrayData = try? JSONEncoder().encode(self.userArray) {
                            UserDefaults.standard.set(encodedArrayData, forKey: "userData")
                        }
                        UserDefaults.standard.set(loginDetails,forKey: "userDetails")
                        self.navigationController?.pushViewController(VC, animated: true)
                    }
                    alert.addAction(NO)
                    alert.addAction(YES)
                    self.present(alert, animated: true)
                }
                else{
                    let alert = UIAlertController(title: "NO USER FOUND", message: error?.localizedDescription , preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(action)
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.loginView.alpha = 1.0
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @IBAction func btnForgotPassword(_ sender: Any) {
        //
    }
    
    @IBAction func btnCreateAccount(_ sender: Any) {
        // let storyboard = UIStoryboard(name: "LoginVC", bundle: nil)
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(VC, animated: true)
    }
}

extension LoginVC {
    func fecthingFirebaseData(senderId : String){
        let reference = self.database.collection("Users")
        messageListener = reference.addSnapshotListener({ (snapshot, err) in
            self.userArray.removeAll()
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
                    if userId == senderId {     // UPDATING DOCUMENT
                        self.database.collection("Users").document(documentId).updateData(["isLogin" : true])
                    }
                    self.userArray.append(FirebaseData(name: Name ?? "name not found", email: email ?? "email not found", picUrl: picUrl ?? "no image found", userId: userId, isLogin: isLogin))
                }
            }
        })
    }
}
