/// Copyright (c) 2017 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

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
    
  let websiteURLString = "https://serene-ravine-45208.herokuapp.com"
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    containerView.clipsToBounds = true
    containerView.layer.cornerRadius = 10
    loginButton.clipsToBounds = true
    loginButton.layer.cornerRadius = 10
  }

  @IBAction func loginButtonTapped(_ sender: UIButton) {
    updateUIForNetworkCall(inProgress: true)
  }
    
  @IBAction func requestSharedCredentialsTapped(_ sender: UIButton) {
    attemptLoginFromSharedCredentials()
  }
    
  @IBAction func openWebsiteButtonTapped(_ sender: UIBarButtonItem) {
    openWebsite()
  }
  
  private func openWebsite() {
    guard let url = URL(string: websiteURLString) else {
      print("Unable to generate URL")
      return
    }
    
    UIApplication.shared.open(url,
                              options: [:],
                              completionHandler: nil)
  }
  
  private func attemptLoginFromSharedCredentials() {
    updateUIForNetworkCall(inProgress: true)
    
    SecRequestSharedWebCredential(nil, nil) { [weak self] (results, error) in
      guard error == nil,
        let strongSelf = self else {
        print("Error encountered: \(error!)")
        return
      }
      
      guard let credentials = results,
        CFArrayGetCount(credentials) > 0 else {
        return
      }

      let unsafeCredentials = CFArrayGetValueAtIndex(credentials, 0)
      let credentialsDict = unsafeBitCast(unsafeCredentials, to: CFDictionary.self)
      
      let unsafeLoginValue = strongSelf.unsafeValue(from: credentialsDict, for: kSecAttrAccount)
      let unsafePasswordValue = strongSelf.unsafeValue(from: credentialsDict, for: kSecSharedPassword)
      
      guard let unsafeLogin = unsafeLoginValue,
        let unsafePassword = unsafePasswordValue else {
        return
      }

      let username = strongSelf.unsafeBitcastToString(from: unsafeLogin)
      let password = strongSelf.unsafeBitcastToString(from: unsafePassword)
      
      strongSelf.fillCredentialsAndLogin(withUserName: username,
                                         password: password)
    }
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
