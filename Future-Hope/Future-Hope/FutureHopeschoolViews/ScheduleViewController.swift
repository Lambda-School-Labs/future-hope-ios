//
//  ScheduleViewController.swift
//  Future-Hope
//
//  Created by HSV on 9/15/19.
//  Copyright © 2019 Hector Steven. All rights reserved.
//

import UIKit
import Firebase


class ScheduleViewController: UIViewController {
    var currentUser: CurrentUser?
    var user: CurrentUser?
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var aboutMeTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.minimumDate = Date()
        datePicker.minuteInterval = 15
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
    }
    
    
    private func setupViews() {
        guard let user = user else { return }
        nameLabel?.text = user.fullName
        aboutMeTextView?.text = user.aboutMe
        if let data = user.imageData {
            userImageView?.image = UIImage(data: data)
        }
        
        // Date
        let format = DateFormatter()
        format.calendar = .current
        format.dateStyle = .long
        format.timeStyle = .medium
        let str = format.string(from: Date())
        startDateLabel?.text = str
        
        
    }
    

    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        let date = sender.date
        let format = DateFormatter()
        format.calendar = .current
        format.dateStyle = .long
        format.timeStyle = .medium
        let str = format.string(from: date)
        startDateLabel?.text = str
    }
    
    @IBAction func scheduleMeetingButtonPressed(_ sender: Any) {
        guard let currentUser = currentUser else { return }
        let date = datePicker.date
        let meeting = Meeting(id: UUID().uuidString, participantNames: [currentUser.fullName], participantUIDs: [currentUser.uid], start: date, title: "")
        let dictioanry = meeting.toDictionary
        
        // check if meeting exist
        //if not send meeting to firebase
        // if exist grab meeting and update it
    }
    
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
