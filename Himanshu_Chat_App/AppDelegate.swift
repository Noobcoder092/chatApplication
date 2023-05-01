//  let string2 = string1.stringByReplacingOccurrencesOfString("\\", withString: "")
//  AppDelegate.swift
//  Himanshu_Chat_App
//
//  Created by Ongraph Technologies on 15/07/22.
//

import UIKit
import FirebaseCore
import Firebase
import FirebaseFirestore
import GoogleSignIn
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var firebaseUsers = [FirebaseData]()
    
    //     FOR GOOGLE SIGN IN : ADDED BY HIMANSHU BISHT
    func application(
        _ app: UIApplication,
        open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        var handled: Bool
        
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }
        return false
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #available(iOS 13.0, *) {  // Sets Light theme for app even in dark mode .
            window?.overrideUserInterfaceStyle = .light
        }
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                if let userDetails = UserDefaults.standard.value(forKey: "userDetails") {
                    if userDetails != nil{
                        print("Auto Login")
                        guard let userDetails = userDetails as? [String: Any] ,
                              let email = userDetails["email"] as? String , let password = userDetails["password"] as? String , let userId = userDetails["userId"] as? String else {
                            return
                        }
                        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let nav1 = UINavigationController()
                        let signInPage = storyboard.instantiateViewController(withIdentifier: "UsersData") as! UsersData
                        nav1.viewControllers = [signInPage]
                        signInPage.senderEmail = email
                        signInPage.senderId = userId
                        let appDelegate = UIApplication.shared.delegate
                        appDelegate?.window??.rootViewController = nav1
                    }
                    else{
                        print("Not saved login details")
                    }
                }
                print("Signed in successfully")
            } else {
                print("Unable to sign in")
            }
        }
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("Foreground")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("KIllED")
        //        AppDelegate.database.collection("Users").getDocuments {(snapshot, err) in
        //            if let err = err {
        //                print("Error getting documents: \(err)")
        //            } else {
        //                for document in snapshot!.documents {
        //                    let documentId = document.documentID
        //                    let userId = document.get("userId") as! String
        //                    if userId == "senderId" {                          // UPDATING DOCUMENT
        //                        AppDelegate.database.collection("Users").document(documentId).updateData(["isLogin" : false])
        //                    }
        //                }
        //            }
        //        }
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

