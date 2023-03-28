//
//  SignUpViewController.swift
//  Be_Real_Clone
//
//  Created by Jonathan Velez on 3/27/23.
//
import UIKit
import ParseSwift


// TODO: Pt 1 - Import Parse Swift
import ParseSwift

class SignUpViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var emailaddress: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        
    }
        @IBAction func onSignUpTapped(_ sender: Any) {
            
            // Make sure all fields are non-nil and non-empty.
            guard let username = username.text,
                  let email = emailaddress.text,
                  let password = password.text,
                  !username.isEmpty,
                  !email.isEmpty,
                  !password.isEmpty else {
                
                showMissingFieldsAlert()
                return
            }
            
            // TODO: Pt 1 - Parse user sign up
            
            var newUser = User()
            newUser.username = username
            newUser.email = email
            newUser.password = password
            
            newUser.signup { [weak self] result in
                
                switch result {
                case .success(let user):
                    
                    print("✅ Successfully signed up user \(user)")
                    
                    NotificationCenter.default.post(name: Notification.Name("login"), object: nil)
                    
                case .failure(let error):
                    
                    self?.showAlert(description: error.localizedDescription)
                }
            }
    }
    
    private func showAlert(description: String?) {
        let alertController = UIAlertController(title: "Unable to Sign Up", message: description ?? "Unknown error", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }

    private func showMissingFieldsAlert() {
        let alertController = UIAlertController(title: "Opps...", message: "We need all fields filled out in order to sign you up.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}
