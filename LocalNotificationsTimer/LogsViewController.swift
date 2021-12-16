//
//  LogsViewController.swift
//  LocalNotificationsTimer
//
//  Created by Shahad Nasser on 16/12/2021.
//

import UIKit

class LogsViewController: UIViewController {
    @IBOutlet weak var logsLabel: UILabel!
    var logs = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if logs.isEmpty {
            logsLabel.text = "no logs yet.."
        }else{
            logsLabel.text = logs
        }
    }
}
