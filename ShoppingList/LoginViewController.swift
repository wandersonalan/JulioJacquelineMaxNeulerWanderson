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
}

