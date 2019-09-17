//
//  MyScdualTableViewCell.swift
//  Future-Hope
//
//  Created by Hector Steven on 9/5/19.
//  Copyright © 2019 Hector Steven. All rights reserved.
//

import UIKit

class MyScdualTableViewCell: UITableViewCell {
	
	var meeting: Meeting? {
		didSet { setupViews() }
	}
	
	@IBOutlet var userImageView: UIImageView!
	@IBOutlet var timeLabel: UILabel!
	@IBOutlet var meetingTitle: UILabel!
	
    @IBOutlet weak var withLabel: UILabel!
    private func setupViews() {
        
        guard let meeting = meeting else { return }
        meetingTitle?.text = meeting.title
        timeLabel?.text = ApplicationController().format.string(from: meeting.start)
        
        var names = ""
        for i in 0..<meeting.participantNames.count - 1 {
            names += meeting.participantNames[i] + ", "
        }
         names += meeting.participantNames[meeting.participantNames.count - 1]
        
        withLabel?.text = " with: \(names)"
        
        // get first user image
        
	}
    
    

    
}
