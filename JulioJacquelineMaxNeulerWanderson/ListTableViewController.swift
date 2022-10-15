//
//  TableViewController.swift
//  JulioJacquelineMaxNeulerWanderson
//
//  Created by ulioJacquelineMaxNeulerWanderson
//  Copyright © 2020 1MOBRBB-2022. All rights reserved.
//

import UIKit
import Firebase

final class ListTableViewController: UITableViewController {

	// MARK: - Properties
	private let collection = "donationList"
	private var donationList: [DonationItem] = []
	private lazy var firestore: Firestore = {
		let settings = FirestoreSettings()
		settings.isPersistenceEnabled = true
		
		let firestore = Firestore.firestore()
		firestore.settings = settings
		return firestore
	}()
	var firestoreListener: ListenerRegistration!
	
	//TOC: Trabalhar a Organização Código
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
		
        title = "Lista de Doações"
        
//		if let user = Auth.auth().currentUser, let displayName = user.displayName {
//			title = "Compras do \(displayName)"
//		}
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sair",
														   style: .plain,
														   target: self,
														   action: #selector(logout))
		
		loadShoppingList()
    }
	
	// MARK: - Methods
	@objc private func logout() {
		do {
			try Auth.auth().signOut()
			guard let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") else {
				return
			}
			navigationController?.viewControllers = [loginViewController]
		} catch {
			print(error)
		}
	}
	
	private func loadShoppingList() {
		firestoreListener = firestore
							.collection(collection)
							.order(by: "name", descending: false)
//								.limit(to: 20)
							.addSnapshotListener(includeMetadataChanges: true, listener: { snapshot, error in
								if let error = error {
									print(error)
								} else {
									guard let snapshot = snapshot else { return }
									print("Total de documentos alterados:", snapshot.documentChanges.count)
									if snapshot.metadata.isFromCache || snapshot.documentChanges.count > 0 {
										self.showItemsFrom(snapshot: snapshot)
									}
								}
							})
	}
	
	private func showItemsFrom(snapshot: QuerySnapshot) {
		donationList.removeAll()
		for document in snapshot.documents {
			let id = document.documentID
			let data = document.data()
			let name = data["name"] as? String ?? "---"
			let telefone = data["telefone"] as? Int ?? 0
			let donationItem = DonationItem(id: id, name: name, telefone: telefone)
			donationList.append(donationItem)
		}
		tableView.reloadData()
	}
	
	private func showAlertForItem(_ item: DonationItem?) {
		let alert = UIAlertController(title: "Brinquedo", message: "Entre com as informações do brinquedo abaixo", preferredStyle: .alert)
		
		alert.addTextField { textField in
			textField.placeholder = "Nome do Brinquedo"
			textField.text = item?.name
		}
		alert.addTextField { textField in
			textField.placeholder = "Telefone do doador"
			textField.keyboardType = .numberPad
			textField.text = item?.telefone.description
		}
		
		let okAction = UIAlertAction(title: "OK", style: .default) { _ in
			guard let name = alert.textFields?.first?.text,
				  let telefoneText = alert.textFields?.last?.text,
				  let telefone = Int(telefoneText) else {return}
			
			let data: [String: Any] = [
				"name": name,
				"telefone": telefone
			]
			
			if let item = item {
				//Edição
				self.firestore.collection(self.collection).document(item.id).updateData(data)
			} else {
				//Criação
				self.firestore.collection(self.collection).addDocument(data: data)
			}
		}
		
		let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
		
		alert.addAction(okAction)
		alert.addAction(cancelAction)
		
		present(alert, animated: true, completion: nil)
	}

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return donationList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let donationItem = donationList[indexPath.row]
		cell.textLabel?.text = donationItem.name
		cell.detailTextLabel?.text = "\(donationItem.telefone)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let donationItem = donationList[indexPath.row]
		showAlertForItem(donationItem)
    }
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let donationItem = donationList[indexPath.row]
			firestore.collection(collection).document(donationItem.id).delete()
		}
	}
    
    // MARK: - IBActions
    @IBAction func addItem(_ sender: Any) {
		showAlertForItem(nil)
    }
}


