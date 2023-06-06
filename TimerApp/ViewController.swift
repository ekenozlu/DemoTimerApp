//
//  ViewController.swift
//  TimerApp
//
//  Created by Eken Özlü on 6.06.2023.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    
    var timerCounting: Bool = false
    var startTime: Date?
    var stopTime: Date?
    
    let userDefaults   = UserDefaults.standard
    let START_TIME_KEY = "startTime"
    let STOP_TIME_KEY  = "stopTime"
    let COUNTING_KEY   = "countingKey"
    
    var scheduledTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetButton.isEnabled = false
        
        startTime     = userDefaults.object(forKey: START_TIME_KEY) as? Date
        stopTime      = userDefaults.object(forKey: STOP_TIME_KEY) as? Date
        timerCounting = userDefaults.bool(forKey: COUNTING_KEY)
        
        if timerCounting{
            startTimer()
        }
        else{
            stopTimer()
            if let start = startTime, let stop = stopTime {
                let time = calculateRestartTime(start: start, stop: stop)
                let diff = Date().timeIntervalSince(time)
                setTimeLabel(Int(diff))
            }
        }
    }

    @IBAction func startStopTapped(_ sender: Any) {
        if timerCounting {
            setStopTime(date: Date())
            stopTimer()
        }
        else {
            if let stop = stopTime {
                let restartTime = calculateRestartTime(start: startTime!, stop: stop)
                setStopTime(date: nil)
                setStartTime(date: restartTime)
            }
            else{
                setStartTime(date: Date())
            }
            startTimer()
        }
    }
    
    @IBAction func resetTapped(_ sender: Any) {
        setStopTime(date: nil)
        setStartTime(date: nil)
        setTimeLabel(0)
        stopTimer()
    }
    
    func startTimer(){
        scheduledTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        setTimerCounting(true)
        
        startStopButton.setTitle("STOP", for: .normal)
        startStopButton.setTitleColor(UIColor.systemRed, for: .normal)
        startStopButton.backgroundColor = UIColor(named: "redButtonColor")
        resetButton.isEnabled = true
    }
    
    func stopTimer(){
        if scheduledTimer != nil {
            scheduledTimer.invalidate()
        }
        setTimerCounting(false)
        startStopButton.setTitle("START", for: .normal)
        startStopButton.setTitleColor(UIColor.systemGreen, for: .normal)
        startStopButton.backgroundColor = UIColor(named: "greenButtonColor")
        resetButton.isEnabled = false
    }
    
    @objc func timerCounter() -> Void {
        if let start = startTime {
            let diff = Date().timeIntervalSince(start)
            setTimeLabel(Int(diff))
        }
        else {
            stopTimer()
            setTimeLabel(0)
        }
    }
    
    func countToTime(seconds: Int) -> (Int,Int,Int){
        let hour = seconds / 3600
        let min = (seconds % 3600) / 60
        let sec = (seconds % 3600) % 60
        return (hour, min, sec)
    }
    
    func makeTimeString(hours:Int, minutes:Int, seconds:Int) -> String {
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += ":"
        timeString += String(format: "%02d", minutes)
        timeString += ":"
        timeString += String(format: "%02d", seconds)
        return timeString
    }
    
    func setTimeLabel(_ val: Int){
        let time = countToTime(seconds: val)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        timeLabel.text = timeString
    }
    
    func calculateRestartTime(start: Date, stop:Date) -> Date {
        let diff = start.timeIntervalSince(stop)
        return Date().addingTimeInterval(diff)
    }
    
    func setStartTime(date: Date?){
        startTime = date
        userDefaults.set(startTime, forKey: START_TIME_KEY)
    }
    
    func setStopTime(date: Date?){
        stopTime = date
        userDefaults.set(stopTime, forKey: STOP_TIME_KEY)
    }
    
    func setTimerCounting(_ val: Bool){
        timerCounting = val
        userDefaults.set(timerCounting, forKey: COUNTING_KEY)
    }
}

