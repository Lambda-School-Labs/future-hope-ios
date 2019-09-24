//
//  ApplicationController.swift
//  Future-Hope
//
//  Created by Hector Steven on 8/20/19.
//  Copyright © 2019 Hector Steven. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import GoogleSignIn

class ApplicationController {
    private let fireStoreController = FireStoreController()
    
    private (set) var currentUser: CurrentUser? {
        didSet { self.fetchAllTeachers { _ in } }
    }
    
    private (set) var meetings: [Meeting] = []
    
    private (set) var teachers: [CurrentUser] = []
    
    init(currentUser: CurrentUser? = nil) {
        self.currentUser = currentUser
    }
    
    
    // MARK: Fetch methods
    
    /// fetch meetings from firebase from Firestorecontroller
    func fetchMyMeetings(completion: @escaping (Error?) -> ()) {
        guard let user = currentUser else { return }
        fireStoreController.fetchMyMeetings(with: user.uid) { myMeetings, error in
            if let error = error {
                completion(error)
            }
            
            guard let myMeetings = myMeetings else { return }
            DispatchQueue.main.async {
                self.meetings = myMeetings
                completion(nil)
            }
        }
    }
    
    /// fetch all teachers that have been approved from firebase
    func fetchAllTeachers(completion: @escaping (Error?) -> ()){
        fireStoreController.fetchAllTeachers { teachers, error in
            if let error = error {
                completion(error)
                return
            }
            guard let teachers = teachers else { return }
            self.teachers = teachers
        }
    }
    
    
    
    
    /// Add meeting and set
    
    func addMeetingToFirebase(with meeting: Meeting, completion: @escaping (Error?) -> ()) {
        fireStoreController.addMeeting(with: meeting) { error in
            if let error = error {
                NSLog("Error adding to firestore: \(error)")
                completion(error)
                return
            }
            
            self.meetings.append(meeting)
            completion(nil)
        }
    }
    
    
}


// MARK: Dates
extension ApplicationController {
    var format: DateFormatter {
        let format = DateFormatter()
        format.calendar = .current
        format.dateStyle = .long
        format.timeStyle = .short
        return format
    }
    
    private var meetingsSorted: [Meeting] {
        return self.meetings.sorted(by: {
            $1.start.timeIntervalSinceReferenceDate > $0.start.timeIntervalSinceReferenceDate
        })
    }

    var meetingsAfterToday: [Meeting] {
        return meetingsSorted.filter{ $0.start > Date(timeIntervalSinceNow: 86400) }
    }

    var upcomingSchedule: [Meeting] {
        return meetingsSorted.filter{ $0.start > Date() && $0.start < Date(timeIntervalSinceNow: 86400) }
    }
}


// MARK: AlertControllers
extension ApplicationController {
    func simpleActionSheetAllert(with title: String, message: String?) -> UIAlertController{
        let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
        return ac
    }
}

// MARK: CurrentUser Setup
extension ApplicationController {

    
    
	// set current user and fetch image
	func setCurrentlyLogedInUser(with user: CurrentUser) {
		currentUser = user
		if let url = user.photoUrl {
			fetchUserImage(with: url) { data, error in
                
				if let error = error {
					print(error)
				}
                
				guard let data  =  data,
                    let currentlyLogedInUser = self.currentUser else { return }
                
                self.fetchMyMeetings { _ in
                    
                    NotificationCenter.default.post(name: NSNotification.Name.init("MeetingsDownLoaded"), object: nil)
                }
                DispatchQueue.main.async {
                    currentlyLogedInUser.imageData = data
                    
                }
			}
		}
	}
    
	// fetch image with url
	func fetchUserImage(with url: URL, completion: @escaping (Data?, Error?) ->()) {
		URLSession.shared.dataTask(with: url) { data, _, error in
			if let error = error{
				NSLog("Error fetching image: \(error)")
				completion(nil, error)
				return
			}
            
			guard let data = data else { return }
			completion(data, nil)
		}.resume()
	}
}


// MARK: Fireabse Auth
extension ApplicationController {

	
	/// Signout with Google credentials
	func signOut(completion: @escaping (Error?) -> Void) {
		let fireAuth = Auth.auth()
		do{
			try fireAuth.signOut()
			completion(nil)
		}catch {
			completion(error)
		}
	}
	
	/// SignIn With Google credentials
	func signInWithCredentials(credentail: AuthCredential, completion: @escaping (Error?) -> Void) {
		Auth.auth().signIn(with: credentail) { authResult, error in
			if let error = error {
				completion(error)
				return
			}
            
			completion(nil)
		}
	}
	
	/// Will fetch current user that was signed in with email/gmail/Facebook
	func fetchCurrentFireAuthenticatedUser() -> User? {
		guard let currentUser = Auth.auth().currentUser else { return nil }
		return currentUser
	}
}

// MARK: Unit test Helpers

extension ApplicationController {
    func fetchUser(with uid: String, completion: @escaping (CurrentUser?) -> ()) {
        
        let docRef = fireStoreController.meetingsCollectionRef.document(uid)
        docRef.getDocument { documentSnapshot, _ in
            
            guard let data = documentSnapshot?.data() else { return }
            let user = CurrentUser(dictionary: data)
            completion(user)
        }
        
    }
}
