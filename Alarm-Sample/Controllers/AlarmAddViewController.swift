//
//  AlarmAddViewController.swift
//  Alarm-Sample
//
//  Created by 大西玲音 on 2021/06/14.
//

import UIKit
import UserNotifications

protocol AlarmAddVCDelegate: AnyObject {
    func alarmAddVC(alarmAdded: AlarmAddViewController, alarmTime: AlarmTime)
    func alarmAddVC(alarmDeleted: AlarmAddViewController, alarmTime: AlarmTime)
    func alarmAddVC(alarmCanceled: AlarmAddViewController)
}

final class AlarmAddViewController: UIViewController {
    
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var tableView: UITableView!
    
    weak var delegate: AlarmAddVCDelegate?
    var alarmTime = AlarmTime()
    var isEdit = false
    private let showAlarmRepeatSegueID = "ShowAlarmRepeatSegueID"
    private let showAlarmLabelSegueID = "ShowAlarmLabelSegueID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.date = alarmTime.date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .time
        setupTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
        
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AlarmSnoozeTableViewCell.nib,
                           forCellReuseIdentifier: AlarmSnoozeTableViewCell.identifier)
        tableView.register(AlarmAddTableViewCell.nib,
                           forCellReuseIdentifier: AlarmAddTableViewCell.identifier)
        tableView.register(AlarmDeleteTableViewCell.nib,
                           forCellReuseIdentifier: AlarmDeleteTableViewCell.identifier)
        tableView.tableFooterView = UIView()
    }
    
    @IBAction private func saveButtonDidTapped(_ sender: Any) {
        setAlarm()
        delegate?.alarmAddVC(alarmAdded: self, alarmTime: alarmTime)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func cancelButtonDidTapped(_ sender: Any) {
        delegate?.alarmAddVC(alarmCanceled: self)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case showAlarmRepeatSegueID:
                if let alarmRepeatVC = segue.destination as? AlarmRepeatViewController {
                    alarmRepeatVC.delegate = self
                    alarmRepeatVC.selectedDays = alarmTime.weeks
                }
            case showAlarmLabelSegueID:
                if let alarmLabelVC = segue.destination as? AlarmAddLabelViewController {
                    alarmLabelVC.delegate = self
                    alarmLabelVC.text = alarmTime.label
                }
            default:
                break
        }
    }
    
    private func setAlarm() {
        removeAlarm(identifiers: alarmTime.uuidString)
        let weekDays = DateFormatter().shortWeekdaySymbols!
        for weekDay in weekDays {
            removeAlarm(identifiers: alarmTime.uuidString + weekDay)
        }
        if alarmTime.weeks.isEmpty {
            setCategories()
            setNotificationContent(day: "", repeats: false)
        } else {
            alarmTime.weeks.forEach { day in
                setCategories()
                setNotificationContent(day: day, repeats: true)
            }
        }
    }
    
    private func removeAlarm(identifiers: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifiers]
        )
    }
    
    private func setCategories() {
        let snoozeAction = UNNotificationAction(
            identifier: "snooze",
            title: "Snooze 5 Minutes",
            options: []
        )
        let noAction = UNNotificationAction(
            identifier: "stop",
            title: "stop",
            options: []
        )
        let actions = alarmTime.snooze ? [snoozeAction, noAction] : []
        let alarmCategory = UNNotificationCategory(
            identifier: "alarmCategory",
            actions: actions,
            intentIdentifiers: [],
            options: [])
        UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
    }
    
    private func setNotificationContent(day:String, repeats:Bool){
        let content = UNMutableNotificationContent()
        content.title = alarmTime.label
        content.sound = .default
        content.categoryIdentifier = "alarmCategory"
        var dateComponents = DateComponents()
        if !day.isEmpty {
            dateComponents.weekday = weekDay(day: day)
        }
        dateComponents.hour = Calendar.current.component(.hour, from: datePicker.date)
        dateComponents.minute = Calendar.current.component(.minute, from: datePicker.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        let request = UNNotificationRequest(identifier: alarmTime.uuidString + day,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        alarmTime.date = datePicker.date
    }
    
    private func weekDay(day: String) -> Int {
        let week = DateFormatter().weekdaySymbols!
        switch day {
            case week[0]: return 1
            case week[1]: return 2
            case week[2]: return 3
            case week[3]: return 4
            case week[4]: return 5
            case week[5]: return 6
            case week[6]: return 7
            default: return 0
        }
    }
    
}

extension AlarmAddViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
            case (0, 0):
                performSegue(withIdentifier: showAlarmRepeatSegueID, sender: nil)
            case (0, 1):
                performSegue(withIdentifier: showAlarmLabelSegueID, sender: nil)
            default:
                break
        }
    }
    
}

extension AlarmAddViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return 4
            case 1: return 1
            default: return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isEdit ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
            case (0, 0...2):
                let cell = tableView.dequeueReusableCell(withIdentifier: AlarmAddTableViewCell.identifier,
                                                         for: indexPath) as! AlarmAddTableViewCell
                let titles = ["Repeat", "Label", "Sound"]
                let subTitles = [alarmTime.repeatLabel, alarmTime.label, "Default"]
                cell.configure(title: titles[indexPath.row], subTitle: subTitles[indexPath.row])
                if indexPath.row == 2 { cell.selectionStyle = .none }
                return cell
            case (0, 3):
                let cell = tableView.dequeueReusableCell(withIdentifier: AlarmSnoozeTableViewCell.identifier,
                                                         for: indexPath) as! AlarmSnoozeTableViewCell
                cell.delegate = self
                cell.configure(text: "Snooze", isOn: alarmTime.snooze)
                return cell
            case (1, _):
                let cell = tableView.dequeueReusableCell(withIdentifier: AlarmDeleteTableViewCell.identifier,
                                                         for: indexPath) as! AlarmDeleteTableViewCell
//                cell.delegate = self
                return cell
            default:
                return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 1) ? 50 : 0
    }
    
}

extension AlarmAddViewController: AlarmRepeatVCDelegate {
    
    func alarmRepeatVC(addRepeat: AlarmRepeatViewController, weeks: [String]) {
        alarmTime.weeks = []
        alarmTime.repeatLabel = ""
        alarmTime.weeks += weeks
        if alarmTime.weeks.count == 1 {
            alarmTime.repeatLabel = "Every" + alarmTime.weeks[0]
        } else if alarmTime.weeks.isEmpty {
            alarmTime.repeatLabel = "Never"
        } else if alarmTime.weeks.count == 7 {
            alarmTime.repeatLabel = "Every day"
        } else {
            for week in alarmTime.weeks {
                if alarmTime.repeatLabel != "" {
                    alarmTime.repeatLabel += ", "
                }
                alarmTime.repeatLabel += week
            }
        }
        tableView.reloadData()
    }
    
}

extension AlarmAddViewController: AlarmSnoozeTableViewCellDelegate {
    
    func alarmSnoozeCell(switchOn: AlarmSnoozeTableViewCell, isOn: Bool) {
        alarmTime.snooze = isOn
    }
    
}

//extension AlarmAddViewController: AlarmDeleteTableViewCellDelegate {
//
//}

extension AlarmAddViewController: AlarmAddLabelVCDelegate {
    
    func alarmAddLabel(labelText: AlarmAddLabelViewController, text: String) {
        alarmTime.label = text
        tableView.reloadData()
    }
    
}
