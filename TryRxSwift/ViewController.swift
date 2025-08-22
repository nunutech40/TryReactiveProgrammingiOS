//
//  ViewController.swift
//  TryRxSwift
//
//  Created by Nunu Nugraha on 22/08/25.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCombine()
    }

    func setupView() {
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = .systemGray
        
        let texFields: [UITextField] = [nameTF, emailTF, passwordTF, confirmPasswordTF]
        for textField in texFields {
            setupTextFiels(for: textField)
        }
    }
    
    func setupCombine() {
        let namePublisher = NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: nameTF)
            .map { ($0.object as? UITextField)?.text }
            .replaceNil(with: "")
            .map { !$0.isEmpty }
        
        namePublisher.sink(receiveValue: { value in
            self.nameTF.rightViewMode = value ? .never : .always
        }).store(in: &cancellables)
        
        let emailPublisher = NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: emailTF)
            .map { ($0.object as? UITextField)?.text }
            .replaceNil(with: "")
            .map {
                self.isValidEmail(from: $0)
            }
        
        emailPublisher.sink(receiveValue: { value in
            self.emailTF.rightViewMode = value ? .never : .always
        }).store(in: &cancellables)
        
        let passwordPublisher = NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: passwordTF)
            .map { ($0.object as? UITextField)?.text }
            .replaceNil(with: "")
            .map { $0.count >= 6 }
        
        emailPublisher.sink(receiveValue: { value in
            self.emailTF.rightViewMode = value ? .never : .always
        }).store(in: &cancellables)
        
        let confirmationPasswordPublisher = Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UITextField.textDidChangeNotification, object: confirmPasswordTF)
                .map { ($0.object as? UITextField)?.text }
                .replaceNil(with: "")
                .map { $0.elementsEqual(self.passwordTF.text ?? "") },
            NotificationCenter.default
                .publisher(for: UITextField.textDidChangeNotification, object: passwordTF)
                .map { ($0.object as? UITextField)?.text }
                .replaceNil(with: "")
                .map { $0.elementsEqual(self.confirmPasswordTF.text ?? "") }
        )
        
        confirmationPasswordPublisher.sink(receiveValue: { value in
            self.confirmPasswordTF.rightViewMode = value ? .never : .always
        }).store(in: &cancellables)
        
        let invaliedFieldPublisher = Publishers.CombineLatest4(namePublisher, emailPublisher, passwordPublisher, confirmationPasswordPublisher).map { name, email, password, confirmPassword in
            name && email && password && confirmPassword
        }
        
        invaliedFieldPublisher.sink(receiveValue: { isValid in
            if isValid {
                self.signUpButton.isEnabled = true
                self.signUpButton.backgroundColor = UIColor.systemGreen
            } else {
                self.signUpButton.isEnabled = false
                self.signUpButton.backgroundColor = UIColor.systemGray
            }
        }).store(in: &cancellables)
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
        case emailTF:
            button.addTarget(self, action: #selector(self.showEmailExistAlert(_:)), for: .touchUpInside)
        case passwordTF:
            button.addTarget(self, action: #selector(self.showPasswordExistAlert(_:)), for: .touchUpInside)
        case confirmPasswordTF:
            button.addTarget(self, action: #selector(self.showConfirmPasswordExistAlert(_:)), for: .touchUpInside)
        default:
            print("Text Not Found")
        }
        
        texField.rightView = button
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

}

