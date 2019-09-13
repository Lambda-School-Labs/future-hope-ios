//
//  Meeting.swift
//  Future-Hope
//
//  Created by SL Hector Villasano on 9/9/19.
//  Copyright © 2019 Hector Steven. All rights reserved.
//

import Foundation
import UIKit
import Firebase
class Meeting: Equatable {
    static func == (lhs: Meeting, rhs: Meeting) -> Bool {
        return lhs.start == rhs.start
    }
    
    
    let id: String
    let participantNames: [String]
    let participantUIDs: [String]
    let start: Date
    let title: String
    
    
    init(id: String, participantNames: [String], participantUIDs: [String], start: Date, title: String) {
        self.id = id
        self.participantNames = participantNames
        self.participantUIDs = participantUIDs
        self.start = start
        self.title = title
    }
    
    convenience init? (dictionary: [String: Any]) {
        let id = dictionary["id"] as? String ?? ""
        let title = dictionary["title"] as? String ?? ""
        
        guard let timestamp = dictionary["start"] as? Timestamp else { return nil }
        let date = timestamp.dateValue()
        
        print(date)

        let participantNames = dictionary["participantNames"] as? [String] ?? []
        let participantUIDs = dictionary["participantUIDs"] as? [String] ?? []
        
        
        //print("id: \(id) - title: \(title) - participantNames: \(participantNames[0]) - participantUIDs: \(participantUIDs[0])")
        self.init(id:id, participantNames: participantNames, participantUIDs: participantUIDs, start: date, title: title)
        
    }
}
