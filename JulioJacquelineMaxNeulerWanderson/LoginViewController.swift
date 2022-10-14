//
//  ViewController.swift
//  ShoppingList
//
//  Created by Eric Alves Brito.
//  Copyright © 2020 FIAP. All rights reserved.
//

import UIKit
import Firebase

final class LoginViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var labelCopyright: UILabel!
    
    // MARK: - Properties
	private lazy var auth = Auth.auth()
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction func signIn(_ sender: Any) {
		auth.signIn(withEmail: textFieldEmail.text!, password: textFieldPassword.text!) { result, error in
			if let error = error {
				print(error)
			} else {
				guard let user = result?.user else { return }
				print("Usuário logado com sucesso!!")
				self.updateUserAndProceed(user: user)
			}
		}
    }
    
    @IBAction func signUp(_ sender: Any) {
		auth.createUser(withEmail: textFieldEmail.text!, password: textFieldPassword.text!) { result, error in
			if let error = error {
				print(error)
			} else {
				guard let user = result?.user else { return }
				print("Usuário criado com sucesso!!")
				self.updateUserAndProceed(user: user)
			}
		}
    }
    
    // MARK: - Methods
	private func updateUserAndProceed(user: User) {
		if textFieldName.text!.isEmpty {
			gotoMainScreen()
		} else {
			let request = user.createProfileChangeRequest()
			request.displayName = textFieldName.text!
			request.commitChanges { error in
				if let error = error {
					print(error)
				}
				self.gotoMainScreen()
			}
		}
	}
	
	private func gotoMainScreen() {
		if let listTableViewController = storyboard?.instantiateViewController(withIdentifier: "ListTableViewController") {
			show(listTableViewController, sender: nil)
		}
	}
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == textFieldEmail {

            //New String and components
            let newStr = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = (newStr as NSString).components(separatedBy: NSCharacterSet.decimalDigits.inverted)

            //Decimal string, length and leading
            let decimalString = components.joined(separator: "") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)

            //Checking the length
            if length == 0 || (length > 11 && !hasLeadingOne) || length > 13 {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int

                return (newLength > 11) ? false : true
            }

            //Index and formatted string
            var index = 0 as Int
            let formattedString = NSMutableString()

            //Check if it has leading
            if hasLeadingOne {
                formattedString.append("1 ")
                index += 1
            }

            //Area Code
            if (length - index) > 2 {
                let areaCode = decimalString.substring(with: NSMakeRange(index, 2))
                formattedString.appendFormat("%@ ", areaCode)
                index += 2
            }

            if length - index > 5 {
                let prefix = decimalString.substring(with: NSMakeRange(index, 5))
                formattedString.appendFormat("%@-", prefix)
                index += 5
            }

            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            return false

        } else {
            return true
        }

    }
    
}

