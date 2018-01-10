//
//  LoginViewController.swift
//  SharedCredentials
//
//  Created by Mark Struzinski on 12/19/17.
//  Copyright © 2017 Razeware. All rights reserved.
//

import UIKit

struct User {
  let userName: String
  let firstName: String
  let lastName: String
}

class LoginViewController: UIViewController {
  typealias LoginCompletionHandler = (User) -> Void

  @IBOutlet weak var userNameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var firstNameLabel: UILabel!
  @IBOutlet weak var lastNameLabel: UILabel!
  @IBOutlet weak var containerView: UIView!
    
  let websiteURLString = "<YOUR HEROKU URL HERE>"
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    containerView.clipsToBounds = true
    containerView.layer.cornerRadius = 10
    loginButton.clipsToBounds = true
    loginButton.layer.cornerRadius = 10
  }

  @IBAction func loginButtonTapped(_ sender: UIButton) {

  }
    
  @IBAction func requestSharedCredentialsTapped(_ sender: UIButton) {

  }
    
  @IBAction func openWebsiteButtonTapped(_ sender: UIBarButtonItem) {

  }
    
  private func unsafeValue(from dictionary: CFDictionary, for key: CFString) -> UnsafeRawPointer? {
    let rawPointer = Unmanaged.passRetained(key).toOpaque()
    let unsafeBits = CFDictionaryGetValue(dictionary, rawPointer)
    return unsafeBits
  }
  
  private func unsafeBitcastToString(from pointer: UnsafeRawPointer) -> String {
    let result = unsafeBitCast(pointer, to: CFString.self)
    return result as String
  }
  
  private func fillCredentialsAndLogin(withUserName userName: String, password: String) {
    DispatchQueue.main.async {
      self.userNameTextField.text = userName
      self.passwordTextField.text = password
      
      self.login(withUserName: userName, password: password, completion: { user in
        self.updateUserUI(with: user)

      })
    }
  }
  
  private func login(withUserName userName: String, password: String, completion: @escaping LoginCompletionHandler) {
    let delay = DispatchTime.now() + 2
    DispatchQueue.global().asyncAfter(deadline: delay) {
      let user = User(userName: userName,
                      firstName: "Test",
                      lastName: "User")
      self.updateUIForNetworkCall(inProgress: false)
      completion(user)
    }
  }
  
  private func updateUserUI(with user: User) {
    DispatchQueue.main.async {
      self.userNameLabel.text = "Username: \(user.userName)"
      self.firstNameLabel.text = "First Name: \(user.firstName)"
      self.lastNameLabel.text = "Last Name: \(user.lastName)"

      UIView.animate(withDuration: 0.3, animations: {
          self.containerView.alpha = 1.0
      })
    }
  }
  
  private func updateUIForNetworkCall(inProgress: Bool) {
    DispatchQueue.main.async {
      if inProgress {
        self.loginButton.isEnabled = false
        self.loginButton.backgroundColor = .lightGray
        self.activityIndicator.startAnimating()
      } else {
        self.loginButton.isEnabled = true
        self.activityIndicator.stopAnimating()
        self.loginButton.backgroundColor = UIColor(red: 0 / 255.0,
                                                   green: 122 / 255.0,
                                                   blue: 255 / 255.0,
                                                   alpha: 1)
      }
    }
  }
}
