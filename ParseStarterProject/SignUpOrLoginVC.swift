/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class SignUpOrLoginVC: UIViewController {
    
    // TextFields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Buttons
    @IBOutlet weak var logInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    // Labels
    @IBOutlet weak var descriptionLbl: UILabel!
    
    var activityIndicator: UIActivityIndicatorView!
    var signUpMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signUpModeIs(active: signUpMode)
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func signUpModeIs(active: Bool) {
        if active == true {
            descriptionLbl.text = "Already have an account?"
            logInBtn.setTitle("Sign Up", for: .normal)
            signUpBtn.setTitle("Login", for: .normal)
        } else {
            descriptionLbl.text = "Don't have an account yet?"
            logInBtn.setTitle("Log In", for: .normal)
            signUpBtn.setTitle("Sign Up", for: .normal)
        }
    }
    
    func createAlertWith(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
            print("OK button pressed")
            self.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func logInBtnPressed(_ sender: Any) {
        if emailTextField.text == "" || passwordTextField.text == "" {
            createAlertWith(title: "Error in form", message: "Please enter an email and password")
        } else {
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            if signUpMode == true {
                let user = PFUser()
                user.username = emailTextField.text
                user.email = emailTextField.text
                user.password = passwordTextField.text
                
                user.signUpInBackground(block: { (success, error) in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if error != nil {
                        var displayErrorMessage = "Please try again later"
                        
                        if let errorMessage = error?.localizedDescription {
                            displayErrorMessage = errorMessage
                        }
                    
                        self.createAlertWith(title: "Sign Up Error", message: displayErrorMessage)
                    } else {
                        print("User has successfully been signed up through Parse")
                    }
                })
            } else {
                PFUser.logInWithUsername(inBackground: emailTextField.text!, password: passwordTextField.text!, block: { (user, error) in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    if error != nil {
                        var displayErrorMessage = "Please try again later"
                        
                        if let errorMessage = error?.localizedDescription {
                            displayErrorMessage = errorMessage
                        }
                        
                        self.createAlertWith(title: "Log In Error", message: displayErrorMessage)
                    } else {
                        print("User successfully logged in")
                    }
                })
            }
        }
    }
    
    @IBAction func signUpBtnPressed(_ sender: Any) {
        signUpMode = !signUpMode
        signUpModeIs(active: signUpMode)
    }
    
}
