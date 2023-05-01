//
//  ViewController.swift
//  Himanshu_Chat_App
//
//  Created by Ongraph Technologies on 15/07/22.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import Firebase
import FirebaseCore
import FirebaseDatabase


let googleClientId  = GIDConfiguration(clientID: "1041873176388-frbe1qnigrrd343nrjaqq9dbeqqdegpr.apps.googleusercontent.com")

class ViewController: UIViewController{
    
    @IBOutlet weak var googleLoginView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet var signUpView: UIView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    var imagePicker = UIImagePickerController()
    
    let database = Firestore.firestore() // ADDED
    var reference : CollectionReference?
    var messageListener : ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        googleLoginView.layer.cornerRadius = 12
        signUpView.layer.cornerRadius = 12
        self.activityLoader.isHidden = true
        self.activityLoader.color = .blue
        self.activityLoader.style = .large
    }
    
    var chatArray = [FirebaseData]() // ARRAY TO SAVE THE FIREBASE DATA
    //  let ref = Database.database().reference().root // REFRENCE OF FIREBASE
    
    @IBAction func btnGoogleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(with: googleClientId, presenting: self) { (userData, error) in
            if error == nil {
                let imageUrl = userData?.profile?.imageURL(withDimension: 200)
                self.sendUserDataToFirebase(email: userData?.profile?.email ?? "email not found", password: nil, userImage: imageUrl, userName: userData?.profile?.name ?? "name not found", isLogin: false)
                self.fetchFirebaseData(senderId: userData?.userID ?? "no value")
                print(self.chatArray)
                let VC = self.storyboard?.instantiateViewController(withIdentifier: "UsersData") as! UsersData
                VC.fireBaseUsers = self.chatArray
                self.navigationController?.pushViewController(VC, animated: true)
            }
            else{
                let alert = UIAlertController(title: "ERROR", message: error?.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true)
            }
        }
    }
    
//    @IBAction func btnLogin(_ sender: Any) {
//        guard let email = userEmail.text , let password = userPassword.text  else {
//            return
//        }
//        if email.isEmpty , password.isEmpty  {
//            let alert = UIAlertController(title: "EMPTY MAIL OR PASSWORD", message: "Please fill login details", preferredStyle: .alert)
//            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//            alert.addAction(action)
//            self.present(alert, animated: true)
//        }else{
//            Auth.auth().signIn(withEmail: email, password: password) { (userData, error) in
//                if error == nil{
//                    self.fetchFirebaseData(senderId: userData?.user.uid ?? "no value")
//                    let alert = UIAlertController(title: "LOG IN SUCCESSFULL", message: "User has been logged in successfully", preferredStyle: .alert)
//                    let action = UIAlertAction(title: "OK", style: .cancel) { _ in
//                        let VC = self.storyboard?.instantiateViewController(withIdentifier: "UsersData") as! UsersData
//                        VC.fireBaseUsers = self.chatArray
//                        VC.senderId = userData?.user.uid
//                        VC.senderEmail = userData?.user.email
//                        self.navigationController?.pushViewController(VC, animated: true)
//                    }
//                    alert.addAction(action)
//                    self.present(alert, animated: true)
//                }
//                else{
//                    let alert = UIAlertController(title: "NO USER FOUND", message: error?.localizedDescription , preferredStyle: .alert)
//                    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                    alert.addAction(action)
//                    self.present(alert, animated: true)
//                }
//            }
//        }
//    }
    
    @IBAction func btnSignUp(_ sender: Any) {
        guard let email = userEmail.text , !email.isEmpty else {
            let alert = UIAlertController(title: "EMPTY EMAIL", message: "Email cannot be empty", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true)
            return
        }
        guard let password = userPassword.text , !password.isEmpty else{
            let alert = UIAlertController(title: "EMPTY PASSWORD", message: "Password cannot be empty", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true)
            return
        }
        guard let name = userName.text , !name.isEmpty else{
            let alert = UIAlertController(title: "EMPTY NAME", message: "Name cannot be empty", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true)
            return
        }
        self.signUpView.alpha = 0.5
        self.activityLoader.isHidden = false
        self.activityLoader.startAnimating()
        
        self.uploadImage(userImage.image ?? UIImage()) { url in

        }
    }
}

// SENDING DATA TO FIREBASE

extension ViewController {
    func sendUserDataToFirebase(email:String , password:String? , userImage:URL?, userName : String , isLogin : Bool){
        
        if email != "" && password != "" && userName != ""{

            Auth.auth().createUser(withEmail: email, password: password ?? "password not found" ) { [self] (userData, error) in
                if error == nil{
                    let userDict = ["email" : email ,"password" : password , "picUrl" : userImage?.absoluteString ,"Name" : userName , "userId" : userData?.user.uid , "isLogin" : isLogin] as [String : Any]
                    //  self.ref.child("Users").childByAutoId().setValue(userDict)   FOR REAL TIME DATABASE
                    self.reference = self.database.collection("Users")    // FOR FIRESTORE DATABASE
                    self.reference?.addDocument(data: userDict, completion: nil)
                    self.activityLoader.isHidden = true
                    self.activityLoader.stopAnimating()
                    self.signUpView.alpha = 1.0
                    let alert = UIAlertController(title: "USER ADDED", message: "User has been added successfully", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                }
                else {
                    let alert = UIAlertController(title: "TRY AGAIN", message: error?.localizedDescription , preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel) { _ in
                        self.signUpView.alpha = 1.0
                        self.activityLoader.stopAnimating()
                        self.activityLoader.isHidden = true
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true)
                }
            }
        }
    }
    // FETCHING DATA FROM FIREBASE
    
    func fetchFirebaseData(senderId : String){
        // FOR FIRESTORE DATABASE
        let reference = self.database.collection("Users")
        messageListener = reference.addSnapshotListener({ (snapshot, err) in
            self.chatArray.removeAll()
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
                    self.chatArray.append(FirebaseData(name: Name ?? "name not found", email: email ?? "email not found", picUrl: picUrl ?? "no image found", userId: userId, isLogin: isLogin))
                }
            }
        })
        
//        self.database.collection("Users").getDocuments { (snapshot, err) in
//            self.chatArray.removeAll()
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                for document in snapshot!.documents {
//                    let documentId = document.documentID
//                    let userId = document.get("userId") as! String
//                    let Name = document.get("Name") as! String
//                    let email = document.get("email") as! String
//                    let picUrl = document.get("picUrl") as! String
//                    let isLogin = document.get("isLogin") as! Bool
//                    if userId == senderId {                          // UPDATING DOCUMENT
//                        self.database.collection("Users").document(documentId).updateData(["isLogin" : true])
//                    }
//                    self.chatArray.append(FirebaseData(name: Name ?? "name not found", email: email ?? "email not found", picUrl: picUrl ?? "no image found", userId: userId, isLogin: isLogin))
//                }
//            }
//        }
        
        // FOR REALTIME DATABASE
        
        //        ref.child("Users").queryOrderedByKey().observe(.value) { (snapshot) in
        //            self.chatArray.removeAll()
        //            if let snapShot = snapshot.children.allObjects as? [DataSnapshot]{
        //                for i in snapShot {
        //                    if let mainDict = i.value as? [String : AnyObject]{
        //                        print(mainDict)
        //                        let name = mainDict["Name"] as? String
        //                        let email = mainDict["email"] as? String
        //                        let picUrl = mainDict["picUrl"] as? String
        //                                self.chatArray.append(FirebaseData(name: name ?? "name not found", email: email ?? "email not found", picUrl: picUrl ?? "no image found"))
        //                    }
        //                }
        //            }
        //        }
    }
}

// IMAGE PICKER
extension ViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    @IBAction func btnImage(_ sender: Any) {
        let imagecontroller = UIImagePickerController()
        imagecontroller.delegate = self
        imagecontroller.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagecontroller, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        userImage.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        userImage.contentMode = .scaleToFill
        self.dismiss(animated: true, completion: nil)
    }
}

// SENDING IMAGE TO FIREBASE IN THE FROM OF URL

extension ViewController {
    
    func uploadImage( _ image : UIImage , completion: @escaping (_ url: String?) -> ()) {
        let storageRef = Storage.storage().reference().child("UserImages/\(UUID().uuidString).png")
        let imgData = userImage.image?.pngData()
        storageRef.putData(imgData! , metadata: nil) { (_,error) in
            if error == nil {
                storageRef.downloadURL(completion: {(url,error) in
                    if let urlGet = url {
                        completion("\(urlGet)")
                        self.sendUserDataToFirebase(email: self.userEmail.text!, password: self.userPassword.text!, userImage: urlGet as URL?, userName: self.userName.text!, isLogin: false)
                    }
                    print("Image Upload successful")
                })
            }
            else{
                print("Unable to upload image",error!.localizedDescription)
                completion(nil)
            }
        }
    }
}

extension Array {
    func filtered(using predicate: NSPredicate) -> Array {
        return (self as NSArray).filtered(using: predicate) as! Array
    }
}

extension ViewController {
    
    func showLoader() -> UIAlertController{
        let alert = UIAlertController(title: "Loading....", message: "Fetching firebase users", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.large
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        return alert
    }
    
    func hideLoader(loader : UIAlertController){
        DispatchQueue.main.async {
            loader.dismiss(animated: true, completion: nil)
        }
    }
}
