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
        tableView.allowsSelection = true
        tableView.register(AlarmTimeTableViewCell.nib,
                           forCellReuseIdentifier: AlarmTimeTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
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
        tableView.setEditing(editing, animated: animated)
    }
    
    private func timeLoad() {
        if let timeData = UserDefaults.standard.object(forKey: timeArrayKey) as? Data,
           let getTimes = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(timeData) as? [AlarmTime] {
            alarmTimes = getTimes
        }
    }
    
    public func getAlarm(from uuid: String) {
        timeLoad()
        guard let alarm = alarmTimes.first(where: { $0.uuidString == uuid }) else { return }
        if alarm.weeks.isEmpty {
            alarm.onOff = false
        }
        saveDate()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    private func saveDate() {
        let alarmTimeData = try! NSKeyedArchiver.archivedData(withRootObject: alarmTimes,
                                                              requiringSecureCoding: false)
        UserDefaults.standard.set(alarmTimeData, forKey: timeArrayKey)
    }
    
    @IBAction private func addButtonDidTapped(_ sender: Any) {
        performSegue(withIdentifier: showAlarmAddSegueID, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAlarmAddSegueID {
            guard let alarmAddVC = segue.destination as? AlarmAddViewController else { return }
            alarmAddVC.delegate = self
            alarmAddVC.isEdit = tableView.isEditing
            if tableView.isEditing {
                alarmAddVC.alarmTime = alarmTimes[index]
            }
        }
    }
    
}

extension AlarmViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            index = indexPath.row
            // MARK: - ToDo 編集画面に遷移
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

extension AlarmViewController: AlarmAddVCDelegate {
    
    func alarmAddVC(alarmAdded: AlarmAddViewController, alarmTime: AlarmTime) {
        if tableView.isEditing {
            alarmTimes[index] = alarmTime
        } else {
            alarmTimes.append(alarmTime)
        }
        alarmTimes.sort { $0.date < $1.date }
        saveDate()
        setEditing(false, animated: false)
        tableView.reloadData()
    }
    
    func alarmAddVC(alarmDeleted: AlarmAddViewController, alarmTime: AlarmTime) {
        setEditing(false, animated: false)
        alarmTimes.remove(at: index)
        saveDate()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarmTimes[index].uuidString])
    }
    
    func alarmAddVC(alarmCanceled: AlarmAddViewController) {
        setEditing(false, animated: false)
    }
    
}
