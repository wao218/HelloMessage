//
//  AppDelegate.swift
//  HelloMessage
//
//  Created by Wesley Osborne on 4/2/21.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    FirebaseApp.configure()
    
    ApplicationDelegate.shared.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
    
    GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
    GIDSignIn.sharedInstance()?.delegate = self
    return true
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    
    ApplicationDelegate.shared.application(
      app,
      open: url,
      sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
      annotation: options[UIApplication.OpenURLOptionsKey.annotation]
    )
    
    return GIDSignIn.sharedInstance().handle(url)
    
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

  
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    guard error == nil else {
      if let error = error {
        print("Faild to sign in with Google: \(error)")
      }
      return
    }
    guard let user = user else {
      return
    }
    
    print("Did sign in with Google: \(user)")
    
    guard let email = user.profile.email, let firstName = user.profile.givenName, let lastName = user.profile.familyName else {
      return
    }
    
    DatabaseManager.shared.userExists(with: email) { (exists) in
      if !exists {
        // insert to database
        let chatUser = ChatAppUser(firstName: firstName,
                                   lastName: lastName,
                                   emailAddress: email)
        
        DatabaseManager.shared.insertUser(with: chatUser) { (success) in
          if success {
            // upload image
            if user.profile.hasImage {
              guard let url = user.profile.imageURL(withDimension: 200) else {
                return
              }
              
              URLSession.shared.dataTask(with: url) { (data, _, _) in
                guard let data = data else {
                  return
                }
                
                let fileName = chatUser.profilePictureFileName
                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { (result) in
                  switch result {
                  case .success(let downloadUrl):
                    UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                    print(downloadUrl)
                  case .failure(let error):
                    print("Storage manager error: \(error)")
                  }
                }
              }.resume()
            }
          }
        }
      }
    }
    
    guard let authentication = user.authentication else {
      print("Missing auth object off of google user")
      return
    }
    let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
    
    FirebaseAuth.Auth.auth().signIn(with: credential) { (authResult, error) in
      guard authResult != nil, error == nil else {
        print("Failed to log in with google credential")
        return
      }
      
      print("Successfully sign in with Google cred.")
      NotificationCenter.default.post(name: .didLogInNotification, object: nil)
    }
  }
  
  func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
    print("Google user was disconnected")
  }

}

