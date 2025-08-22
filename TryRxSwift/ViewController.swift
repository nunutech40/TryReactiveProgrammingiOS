//
//  ViewController.swift
//  TryRxSwift
//
//  Created by Nunu Nugraha on 22/08/25.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupRX()
    }

    func setupView() {
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = .systemGray
        
        let texFields: [UITextField] = [nameTF, emailTF, passwordTF, confirmPasswordTF]
        for textField in texFields {
            setupTextFiels(for: textField)
        }
    }
    
    func setupRX() {
        let nameStream = nameTF.rx.text
            .orEmpty
            .skip(1)
            .map { !$0.isEmpty } // validation -> semua data yang dikembalikan (text) tidak kosong
        
        nameStream.subscribe(
            onNext: { value in
                self.nameTF.rightViewMode = value ? .never : .always
            }
        ).disposed(by: disposeBag)
        
        let emailStream = emailTF.rx.text
            .orEmpty
            .skip(1)
            .map { self.isValidEmail(from: $0) }
        
        emailStream.subscribe(
            onNext: { value in
                self.emailTF.rightViewMode = value ? .never : .always
            }
        ).disposed(by: disposeBag)
        
        let passwordStream = passwordTF.rx.text
            .orEmpty
            .skip(1)
            .map { $0.count > 5 }
        
        passwordStream.subscribe(
            onNext: { value in
                self.passwordTF.rightViewMode = value ? .never : .always
            }
        ).disposed(by: disposeBag)
        
        let confirmationPasswordStream = Observable.merge(
            confirmPasswordTF.rx.text
                .orEmpty
                .skip(1)
                .map { $0.elementsEqual(self.passwordTF.text ?? "") },
            
            passwordTF.rx.text
                .orEmpty
                .skip(1)
                .map {
                    $0.elementsEqual(self.confirmPasswordTF.text ?? "")
                }
        )
        
        confirmationPasswordStream.subscribe(
            onNext: { value in
                self.confirmPasswordTF.rightViewMode = value ? .never : .always
            }
        ).disposed(by: disposeBag)
        
        let invalidFieldStream = Observable.combineLatest(
            nameStream,
            emailStream,
            passwordStream,
            confirmationPasswordStream
        ) { name, email, password, confirPassword in
            name && email && password && confirPassword
        }
        
        invalidFieldStream.subscribe(
            onNext: { value in
                self.signUpButton.isEnabled = value ? true : false
                self.signUpButton.backgroundColor = value ? .systemGreen : .systemGray
            }
        ).disposed(by: disposeBag)
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

