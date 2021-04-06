//
//  ViewController.swift
//  HelloMessage
//
//  Created by Wesley Osborne on 4/2/21.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    validateAuth()
  }

  private func validateAuth() {
    if FirebaseAuth.Auth.auth().currentUser == nil {
      let vc = LoginViewController()
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = .fullScreen
      present(nav, animated: false)
    }
  }

}

