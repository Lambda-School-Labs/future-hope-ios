//
//  ExploreTableViewController.swift
//  Future-Hope
//
//  Created by SL Hector Villasano on 9/11/19.
//  Copyright © 2019 Hector Steven. All rights reserved.
//

import UIKit

extension ExploreTableViewController: FutureHopSchoolControllerProtocol{}

class ExploreTableViewController: UITableViewController {
    var futureHopSchoolController: ApplicationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        futureHopSchoolController!.fetchAllTeachers { error in
            if let error = error {
                NSLog("Error fetching teacher: \(error)")
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return futureHopSchoolController?.teachers.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreTableViewCell", for: indexPath)
        guard let exlporeCell = cell as? ExploreTableViewCell,
            let user = futureHopSchoolController?.teachers[indexPath.row] else { return cell }
        
        exlporeCell.currentUser = user
//        loadImage(with: exlporeCell, with: user)
        return exlporeCell
    }
    
    private func loadImage(with cell: ExploreTableViewCell, with user: CurrentUser){
        
        guard let url = user.photoUrl else { return }
        ApplicationController().fetchUserImage(with: url) { data, error in
            if let error = error {
                NSLog("Error wiht applicationcontroller: \(error)")
                return
            }
            guard let data = data else { return }
            let image = UIImage(data: data)
            
            DispatchQueue.main.async {
                cell.userImageView?.image = image
                self.tableView.reloadData()
            }
            
        }
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        print("\(indexPath.row)")
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SchedualMeetingSegue" {
            guard let vc = segue.destination as? ScheduleViewController,
                  let indexPath = tableView.indexPathForSelectedRow,
                  let user = futureHopSchoolController?.teachers[indexPath.row]  else { return }
            vc.user = user
        }
    }
    
}
