//
//  SignInViewController.swift
//  Future-Hope
//
//  Created by Hector Steven on 8/19/19.
//  Copyright © 2019 Hector Steven. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FacebookCore
import FacebookLogin
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn
import MaterialComponents.MaterialTextFields

class SignInViewController: UIViewController {

	@IBOutlet var emailTextField: MDCTextField!
	@IBOutlet var passwordTextField: MDCTextField!
	
	var handle: AuthStateDidChangeListenerHandle?
	
	deinit {
		if let handle = handle {
			Auth.auth().removeStateDidChangeListener(handle)
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupViews()
    }
	
	
	private func gooToMainView() {
		guard let homeVC = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? UINavigationController else {
			print("homeVC was not found!")
			return
		}
		
		
		view.window?.rootViewController = homeVC
		view.window?.makeKeyAndVisible()
	}
	
	
	private func setupViews() {
		emailTextField.delegate = self
		passwordTextField.delegate = self
		GIDSignIn.sharedInstance()?.presentingViewController = self
		handleAuthStateDidChange()
		
	
		
	}
	
	/// if user exist segue to app
	private func checkIfuserExistAndLogin(with uid: String) {
		FireStoreController().fetchUser(uuid: uid) { user, error in
			if let error = error {
				print("\(error)")
				return
			}
			
			DispatchQueue.main.async {
				self.gooToMainView()
			}
		}
	}
	
	
	private func handleAuthStateDidChange() {
		handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
			if let user = user {
				self.checkIfuserExistAndLogin(with: user.uid)
			} else {
				self.performSegue(withIdentifier: "GMailFacebookSegue", sender: nil)
				self.segueToApp()
			}
		})
	}
	
	
	@IBAction func facebookLogInButtonPressed(_ sender: FBLoginButton) {
//		LoginManager().logIn(permissions: [.publicProfile], viewController: self) { result in
//			switch result {
//			case .success(granted: _, declined: _, token: _):
//				self.firebaseFacebookLogIn()
//			case .failed(let err):
//				print("Failed with: \(err)")
//			case .cancelled:
//				print("Canceled! ")
//			}
//		}
	}
	
	private func firebaseFacebookLogIn() {
		let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
		
		Auth.auth().signIn(with: credential) { (authResult, error) in
			if let error = error {
				NSLog("Error with facebook Auth: \(error) \n authResult: \(authResult.debugDescription)")
				let ac = ApplicationController().simpleActionSheetAllert(with: "Error With FaceBool LogIn", message: "Please try Again!")
				self.present(ac, animated: true)
				return
			}
			
			self.segueToApp()
			print("FaceBook loggedIn with authResult: \(authResult.debugDescription)")
			
			if let user = Auth.auth().currentUser {
				print("Logged in as: ", user.displayName!)
			}
		}
	}
	
	@IBAction func logInButtonPressed(_ sender: UIButton) {
		guard let email = emailTextField.text,
			let password = passwordTextField.text else { return }
		
		if email.isEmpty || password.isEmpty {
				let ac = ApplicationController().simpleActionSheetAllert(with: "Error With email/password", message: "Password/email is empty")
				self.present(ac, animated: true)
				return
		}
		
		Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
			if let error = error {
				NSLog("Error with Auth Sign In email/password: \(error)\n With authResult: \(authResult.debugDescription)")
				let ac = ApplicationController().simpleActionSheetAllert(with: "Error With email/password", message: "Please try Again!")
				self.present(ac, animated: true)
				return
			}
			
			self.segueToApp()
			print("signed in with  \(email)")
		}
	}
	
	private func segueToApp() {
		// // MARK: segue to app
		
		/////
		
		///
		
		/////
	}
}



extension SignInViewController: UITextFieldDelegate {
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		view.endEditing(true)
	}
}
