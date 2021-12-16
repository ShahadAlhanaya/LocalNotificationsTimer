//
//  ViewController.swift
//  LocalNotificationsTimer
//
//  Created by Shahad Nasser on 16/12/2021.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  
    
    @IBOutlet weak var timePicker: UIPickerView!
    let pickerData = ["1","5", "10", "15", "30"]
    
    @IBOutlet weak var timerSetLabel: UILabel!
    @IBOutlet weak var timerEndsLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var startTimerButton: UIButton!
    
    var selectedPicker = 0
    var totalTime = 0
    var setTimer = 1
    var endTime = ""
    var log = ""
    
    var timer : Timer = Timer()
    var timerStarted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        startTimerButton.setTitle("Start Timer", for: .normal)
//        startTimerButton.backgroundColor = UIColor.systemBlue
//        timerSetLabel.isHidden = true
//        timerEndsLabel.isHidden = true
//        endTimeLabel.isHidden = true
//
//        totalTimeLabel.text = "Total Time: 0 minutes"
        startNewDay()
        
        self.timePicker.delegate = self
        self.timePicker.dataSource = self
        
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerData[row]) minutes"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPicker = row
    }
    
    @IBAction func newDayButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Start a new day?", message: "this action will delete your previous log", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "New Day", style: UIAlertAction.Style.default, handler: {action in
            self.startNewDay()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil ))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func startTimerButtonPressed(_ sender: UIButton) {
        if timerStarted {
            //timer has started
            let alert = UIAlertController(title: "Stop Timer?", message: "Are you sure you want to stop the timer?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Stop", style: UIAlertAction.Style.default, handler: {action in
                self.stopTimer()
                self.log += "Canceled: \(self.setTimer) minutes timer canceld\n"
                print(self.log)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil ))
            self.present(alert, animated: true, completion: nil)
        
        }else{
                     
            let alert = UIAlertController(title: "Start Timer", message: "You will be notified when timer ends", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Start", style: UIAlertAction.Style.default, handler: {action in self.startTimer() }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil ))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func stopTimer(){
        timerStarted = false
        timer.invalidate()
        startTimerButton.setTitle("Start Timer", for: .normal)
        startTimerButton.backgroundColor = UIColor.systemBlue
        timerSetLabel.isHidden = true
        timerEndsLabel.isHidden = true
        endTimeLabel.isHidden = true
    }
    
    func startTimer(){
        timerStarted = true
        startTimerButton.setTitle("Stop Timer", for: .normal)
        startTimerButton.backgroundColor = UIColor.systemRed
        timerSetLabel.isHidden = false
        timerEndsLabel.isHidden = false
        endTimeLabel.isHidden = false
        
        switch selectedPicker {
        case 0: setTimer = 1
        case 1: setTimer = 5
        case 2: setTimer = 10
        case 3: setTimer = 15
        case 4: setTimer = 30
        default: setTimer = 1
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        endTime = formatter.string(from: Date().addingTimeInterval(Double(setTimer) * 60.0))
        timerSetLabel.text = "\(setTimer) minutes timer set"
        endTimeLabel.text = "\(endTime)"
        totalTime += setTimer
        totalTimeLabel.text = "Total Time: \(totalTime) minutes"
        
        var timerInSeconds = 5
        //setTimer * 60
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (Timer) in
               if timerInSeconds > 0 {
                   timerInSeconds -= 1
               } else {
                   self.stopTimer()
                   self.log += "Finished: \(self.setTimer) minutes timer ended at \(self.endTime)\n"
                   self.showNotification()
                   print(self.log)
               }
           }
    }
    
    func showNotification(){
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Time's up"
        content.body = "Time is up! take a break"
        content.sound = .default
        content.userInfo = ["timer": "local notification for timer"]
        let fireDate = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second], from: Date().addingTimeInterval(1))
        let trigger = UNCalendarNotificationTrigger(dateMatching: fireDate, repeats: false)
        let request = UNNotificationRequest(identifier: "reminder", content: content, trigger: trigger)
        center.add(request) { (error) in
        if error != nil {
        print("Error = \(error?.localizedDescription ?? "error local notification")")
            }
        }
    }
    
    func startNewDay(){
        selectedPicker = 0
        totalTime = 0
        setTimer = 1
        endTime = ""
        log = ""
        timePicker.selectRow(0, inComponent: 0, animated: true)
        timer.invalidate()
        timerStarted = false
        
        startTimerButton.setTitle("Start Timer", for: .normal)
        startTimerButton.backgroundColor = UIColor.systemBlue
        timerSetLabel.isHidden = true
        timerEndsLabel.isHidden = true
        endTimeLabel.isHidden = true
        
        totalTimeLabel.text = "Total Time: 0 minutes"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let logsViewController = navigationController.topViewController as! LogsViewController
        logsViewController.logs = log
    }


}


