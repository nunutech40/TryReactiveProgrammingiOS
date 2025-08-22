//
//  ViewController.swift
//  TryRxSwift
//
//  Created by Nunu Nugraha on 22/08/25.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    private var isNameValid = false
    private var isEmailValid = false
    private var isPasswordValid = false
    private var isConfirmPasswordValid = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = .systemGray
        
        let texFields: [UITextField] = [nameTF, emailTF, passwordTF, confirmPasswordTF]
        for textField in texFields {
            setupTextFiels(for: textField)
        }
    }
    
    func setupTextFiels(for texField: UITextField) {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "exclamationmark.circle"), for: .normal)
        if #available(iOS 15.0, *) {
          button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -16, bottom: 0, trailing: 0)
        } else {
          button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        }
        button.frame = CGRect(
            x: CGFloat(nameTF.frame.size.width - 25),
            y: CGFloat(5),
            width: CGFloat(25),
            height: CGFloat(25)
        )
        
        switch texField {
        case nameTF:
            button.addTarget(self, action: #selector(self.showNameExistAlert(_:)), for: .touchUpInside)
            texField.addTarget(self, action: #selector(self.nameTextFieldDidChange(_:)), for: .editingChanged)
        case emailTF:
            button.addTarget(self, action: #selector(self.showEmailExistAlert(_:)), for: .touchUpInside)
            texField.addTarget(self, action: #selector(self.emailTextFieldDidChange(_:)), for: .editingChanged)
        case passwordTF:
            button.addTarget(self, action: #selector(self.showPasswordExistAlert(_:)), for: .touchUpInside)
            texField.addTarget(self, action: #selector(self.passwordTextFieldDidChange(_:)), for: .editingChanged)
        case confirmPasswordTF:
            button.addTarget(self, action: #selector(self.showConfirmPasswordExistAlert(_:)), for: .touchUpInside)
            texField.addTarget(self, action: #selector(self.confirmPasswordTextFieldDidChange(_:)), for: .editingChanged)
        default:
            print("Text Not Found")
        }
        
        texField.rightView = button
    }
    
    @objc func nameTextFieldDidChange(_ textField: UITextField) {
        if let input = textField.text {
            if input.isEmpty {
                isNameValid = false
                textField.rightViewMode = .always
            } else {
                isNameValid = true
                textField.rightViewMode = .never
            }
            validateButton()
        }
    }
    
    @objc func emailTextFieldDidChange(_ textField: UITextField) {
        if let input = textField.text {
            if isValidEmail(from: input) {
                isEmailValid = true
                textField.rightViewMode = .never
            } else {
                isEmailValid = false
                textField.rightViewMode = .always
            }
            validateButton()
        }
    }
    
    @objc func passwordTextFieldDidChange(_ textField: UITextField) {
        if let input = textField.text {
            if input.count < 6 {
                isPasswordValid = false
                textField.rightViewMode = .always
            } else {
                isPasswordValid = true
                textField.rightViewMode = .never
            }
            validateButton()
        }
    }
    
    @objc func confirmPasswordTextFieldDidChange(_ textField: UITextField) {
        if let input = textField.text, let password = passwordTF.text {
            if input != password {
                isConfirmPasswordValid = false
                textField.rightViewMode = .always
            } else {
                isConfirmPasswordValid = true
                textField.rightViewMode = .never
            }
            validateButton()
        }
    }
    
    @IBAction func showNameExistAlert(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Your name is invalid",
            message: "Please double check your name, for example Nunu Nugraha.",
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .destructive))
        self.present(alertController, animated: true)
    }
    
    @IBAction func showEmailExistAlert(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Your email is invalid.",
            message: "Please double check your email format, for example like nunu@gmail.com",
            preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
    
    @IBAction func showPasswordExistAlert(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Your password is invalid.",
            message: "Please double check the character length of your password.",
            preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
    
    @IBAction func showConfirmPasswordExistAlert(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Confirmation passwords do not match.",
            message: "Please check your password confirmation again.",
            preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
    
    private func isValidEmail(from email: String) -> Bool {
      let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

      let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
      return emailPred.evaluate(with: email)
    }
    
    func validateButton() {
        if isNameValid && isEmailValid && isPasswordValid && isConfirmPasswordValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.systemGreen
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = .systemGray
        }
    }

}

