//
//  EmailSignUpViewController.swift
//  Future-Hope
//
//  Created by Hector Steven on 8/20/19.
//  Copyright © 2019 Hector Steven. All rights reserved.
//

import UIKit
import Firebase
import MaterialComponents.MaterialTextFields
import MaterialComponents.MaterialButtons

class GmailFacebookSignUpViewController: UIViewController {

	var currentAuthUser: CurrentUser?
	
	@IBOutlet var fullNameTextField: MDCTextField!
	@IBOutlet var emailTextFields: MDCTextField!
	@IBOutlet var citiTextField: MDCTextField!
	@IBOutlet var stateOrProvinceTextField: MDCTextField!
	@IBOutlet var countryTextField: MDCTextField!
	@IBOutlet var phoneNumberTextField: MDCTextField!
	@IBOutlet var aboutmeTextView: UITextView!
	@IBOutlet var userTypeSegmented: UISegmentedControl!
	@IBOutlet var passwordTextField: MDCTextField!
	@IBOutlet var confirmPasswordTextView: MDCTextField!
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupViews()
	}
	
	private func setupViews() {
		 guard let currentAuthUser = currentAuthUser else { return }
		fullNameTextField?.text = currentAuthUser.fullName
		emailTextFields?.text = currentAuthUser.email
		citiTextField?.text = currentAuthUser.city
		stateOrProvinceTextField?.text = currentAuthUser.stateProvince
		countryTextField?.text = currentAuthUser.country
		aboutmeTextView?.text = currentAuthUser.aboutMe
		userTypeSegmented.selectedSegmentIndex = currentAuthUser.userType! == .mentor ? 0 :  1
		phoneNumberTextField?.text = currentAuthUser.phoneNumber
	}
	
	// User is trying to update their user information on firestore
	@IBAction func submitButtonPressed(_ sender: MDCButton) {
		guard let fullName = fullNameTextField.text,
			let email = emailTextFields.text,
			let citi = citiTextField.text,
			let stateOrProvince = stateOrProvinceTextField.text,
			let country = countryTextField.text,
			let phoneNumber = phoneNumberTextField.text,
			let aboutme = aboutmeTextView.text else {
				// found nothing
				let ac = ApplicationController().simpleActionSheetAllert(with: "Please feel in all areas", message: nil)
				present(ac, animated: true)
				return
		}
		
		// get user Type
		let usertype: UserType = userTypeSegmented.selectedSegmentIndex == 0 ? .mentor : .teacher
		
		// FIXME: This!!!
		
		
		// check if signed in with gmail
		if let	uid = currentAuthUser?.uid, let url = currentAuthUser?.photoUrl {
			if checkTextIsEmpty(fullName: fullName, email: email, citi: citi, stateOrProvince: stateOrProvince, country: country, phoneNumber: phoneNumber, aboutMe: aboutme){
				let ac = ApplicationController().simpleActionSheetAllert(with: "Your Text field is empty", message: nil)
				present(ac, animated: true)
				return
			}
			print("submit button!")
			
			let signedInUser = CurrentUser(aboutMe: aboutme, awaitingApproval: true, city: citi, country: country, email: email, fullName: fullName, phoneNumber: phoneNumber, photoUrl: url, stateProvince: stateOrProvince, uid: uid, userType: usertype)
			addUserToFireBase(with: signedInUser)
			//pass controller for update ore create delegate
			navigationController?.popViewController(animated: true)
			
		}else {
			let signedInUser = CurrentUser(aboutMe: aboutme, awaitingApproval: true, city: citi, country: country, email: email, fullName: fullName, phoneNumber: phoneNumber, photoUrl: nil, stateProvince: stateOrProvince, uid: UUID().uuidString, userType: usertype)
			self.firebaseEmailSignUp(with: signedInUser)
		}
	}
	
	private func addUserToFireBase(with user: CurrentUser) {
		FireStoreController().addUserToFireStore(with: user) { error in
			if let error = error {
				let ac = ApplicationController().simpleActionSheetAllert(with: "Network Error", message: "Please Try Again 🧐")
				self.present(ac, animated: true)
				NSLog("Error adding user to firestore: \(error)")
				return
			}
			self.dismiss(animated: true)
		}
	}
		
	private func firebaseEmailSignUp(with user: CurrentUser) {
		guard let password = passwordTextField.text,
			let confirmPassword = confirmPasswordTextView.text else {
				
				let ac = ApplicationController().simpleActionSheetAllert(with: "Your passwords do not match!", message: nil)
				present(ac, animated: true)
				
				passwordTextField.text = nil
				confirmPasswordTextView.text = nil
				return
		}
		
		if password == confirmPassword {
			Auth.auth().createUser(withEmail: user.email,password: password) { authResult, error in
				if let error = error {
					NSLog("Error creating user with password: \(error)")
					let ac = ApplicationController().simpleActionSheetAllert(with: "Netowrk Error", message: "Please Try again!")
					self.present(ac, animated: true)
					return
				}
				
//				guard let authResult = authResult else { return }
				
				guard let thisUser = ApplicationController().fetchCurrentFireAuthenticatedUser() else { return }
				
				let uid = thisUser.uid
				let newUser  = CurrentUser(aboutMe: user.aboutMe, awaitingApproval: user.awaitingApproval, city: user.city, country: user.country, email: user.email, fullName: user.fullName, phoneNumber: user.phoneNumber, photoUrl: user.photoUrl, stateProvince: user.stateProvince, uid: uid, userType: user.userType!, imageData: nil)
				print(thisUser.uid)
				DispatchQueue.main.async {
					self.addUserToFireBase(with: newUser)
					self.gooToMainView()
				}
				
			}
		}
		
	}
	
	@IBAction func cancelButtonPressed(_ sender: UIButton) {
		if let nav = navigationController {
			nav.popViewController(animated: true)
		} else {
			dismiss(animated: true)
		}
	}
}


// MARK : Check TextViews for errors

extension GmailFacebookSignUpViewController {
	
	private func checkTextIsEmpty(fullName: String, email: String, citi: String, stateOrProvince: String, country: String, phoneNumber: String, aboutMe: String) -> Bool{
		return fullName.isEmpty || email.isEmpty || citi.isEmpty || stateOrProvince.isEmpty || country.isEmpty || phoneNumber.isEmpty || aboutMe.isEmpty
	}
	
	private func passwordIsSafe(with password: String) -> Bool {
		// Mark: Check for valid passwor
		if password.count < 6 {
			return  false
		}
		return true
	}
	
	private func gooToMainView() {
		guard let homeVC = storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController else {
			print("homeVC was not found!")
			return
		}
		
		view.window?.rootViewController = homeVC
		view.window?.makeKeyAndVisible()
	}
}
