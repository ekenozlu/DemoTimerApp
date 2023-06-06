//
//  ViewController.swift
//  TimerApp
//
//  Created by Eken Özlü on 6.06.2023.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var resetLapButton: UIButton!
    
    @IBOutlet weak var lapsTableView: UITableView!
    
    var timerCounting: Bool = false
    var startTime: Date?
    var stopTime: Date?
    var lapList: [[Int]] = [[]]
    
    let userDefaults    = UserDefaults.standard
    let START_TIME_KEY  = "startTime"
    let STOP_TIME_KEY   = "stopTime"
    let COUNTING_KEY    = "countingKey"
    let LAP_LIST_KEY    = "lapList"
    
    var scheduledTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetLapButton.isEnabled = false
        resetLapButton.backgroundColor = UIColor(named: "blueButtonColor")
        startTime       = userDefaults.object(forKey: START_TIME_KEY) as? Date
        stopTime        = userDefaults.object(forKey: STOP_TIME_KEY) as? Date
        timerCounting   = userDefaults.bool(forKey: COUNTING_KEY)
        lapList         = userDefaults.array(forKey: LAP_LIST_KEY) as! [[Int]]
        
        setLapListAndReloadTable()
        
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
    
    @IBAction func resetLapTapped(_ sender: Any) {
        if timerCounting {
            //LAP
            if let start = startTime {
                let time = Date().timeIntervalSince(start)
                lapList.insert([Int(time),calculateLapTimeInSeconds()], at: 0)
                setLapListAndReloadTable()
            }
        }
        else {
            //RESET
            setStopTime(date: nil)
            setStartTime(date: nil)
            setTimeLabel(0)
            stopTimer()
            lapList.removeAll(keepingCapacity: false)
            setLapListAndReloadTable()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lapList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lapCell = tableView.dequeueReusableCell(withIdentifier: "lapCell") as! lapCell
        
        lapCell.lapCountLabel.text = "Lap " + String(lapList.count - indexPath.row)
        
        let laptime = countToTime(seconds: lapList[indexPath.row][1])
        let lapTimeString = makeTimeString(hours: laptime.0, minutes: laptime.1, seconds: laptime.2)
        lapCell.lapTimeLabel.text = lapTimeString
        
        return lapCell
    }
    
    func startTimer(){
        scheduledTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        setTimerCounting(true)
        
        startStopButton.setTitle("STOP", for: .normal)
        startStopButton.setTitleColor(UIColor.systemRed, for: .normal)
        startStopButton.backgroundColor = UIColor(named: "redButtonColor")
        resetLapButton.isEnabled = true
        resetLapButton.setTitle("LAP", for: .normal)
    }
    
    func stopTimer(){
        if scheduledTimer != nil {
            scheduledTimer.invalidate()
        }
        setTimerCounting(false)
        startStopButton.setTitle("START", for: .normal)
        startStopButton.setTitleColor(UIColor.systemGreen, for: .normal)
        startStopButton.backgroundColor = UIColor(named: "greenButtonColor")
        resetLapButton.setTitle("RESET", for: .normal)
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
    
    func calculateLapTimeInSeconds() -> Int {
        var lapTime = 0
        if let start = startTime {
            let diff = Date().timeIntervalSince(start)
            lapTime = Int(diff)
            if lapList.count > 0 {
                lapTime -= lapList.first![0]
            }
        }
        return lapTime
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
    
    func setLapListAndReloadTable(){
        lapsTableView.reloadData()
        userDefaults.set(lapList, forKey: LAP_LIST_KEY)
    }
}

