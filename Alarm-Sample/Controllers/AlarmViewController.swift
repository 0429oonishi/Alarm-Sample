//
//  AlarmViewController.swift
//  Alarm-Sample
//
//  Created by 大西玲音 on 2021/06/14.
//

import UIKit
import UserNotifications

final class AlarmViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    static let shared = AlarmViewController()
    private var appDelegate = UIApplication.shared
    private var userDefaults = UserDefaults.standard
    private var index: Int!
    private var alarmTimes = [AlarmTime]()
    private let showAlarmAddSegueID = "ShowAlarmAddSegueID"
    // MARK: - ToDo UserDefaultを使いやすく
    private let timeArrayKey = "timeArray"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        timeLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationDidReceived),
                                               name: .notificationIdentifier,
                                               object: nil)
        
    }
    
    private func setupTableView() {
        tableView.allowsSelectionDuringEditing = true
        tableView.allowsSelection = false
        tableView.register(AlarmTimeTableViewCell.nib,
                           forCellReuseIdentifier: AlarmTimeTableViewCell.identifier)
        tableView.tableFooterView = UIView()
        tableView.reloadData()
    }
    
    @objc private func notificationDidReceived() {
        timeLoad()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    private func timeLoad() {
        if let timeData = userDefaults.object(forKey: timeArrayKey) as? Data,
           let getTimes = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(timeData) as? [AlarmTime] {
            alarmTimes = getTimes
        }
    }
    
    private func getAlarm(from uuid: String) {
        timeLoad()
        guard let alarm = alarmTimes.first(where: { $0.uuidString == uuid }) else { return }
        if alarm.week.isEmpty {
            alarm.onOff = false
        }
        saveDate()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    private func saveDate() {
        let alarmTimeData = try! NSKeyedArchiver.archivedData(withRootObject: alarmTimes,
                                                              requiringSecureCoding: false)
        userDefaults.set(alarmTimeData, forKey: timeArrayKey)
        userDefaults.synchronize()
    }
    
    @IBAction private func addButtonDidTapped(_ sender: Any) {
        performSegue(withIdentifier: showAlarmAddSegueID, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAlarmAddSegueID{
            guard let nvc = segue.destination as? UINavigationController,
                  let alarmAddVC = nvc.topViewController as? AlarmAddViewController else { return }
            // MARK: - ToDo コメントアウト解除
            //            alarmAddVC.delegate = self
            //            alarmAddVC.isEdit = tableView.isEditing
            //            if tableView.isEditing {
            //                alarmAddVC.alarmTime = alarmTimes[index]
            //            }
        }
    }
    
}

extension AlarmViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            index = indexPath.row
            performSegue(withIdentifier: showAlarmAddSegueID, sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}

extension AlarmViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return alarmTimes.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: AlarmTimeTableViewCell.identifier,
            for: indexPath
        ) as! AlarmTimeTableViewCell
        let alarmTime = alarmTimes[indexPath.row]
        cell.configure(alarmTime: alarmTime)
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            UNUserNotificationCenter.current().removePendingNotificationRequests(
                withIdentifiers: [alarmTimes[indexPath.row].uuidString]
            )
            alarmTimes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveDate()
        }
    }
    
}

// MARK: - ToDo AlarmAddVCDelegate実装
