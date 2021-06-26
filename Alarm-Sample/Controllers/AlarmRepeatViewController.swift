//
//  AlarmRepeatViewController.swift
//  Alarm-Sample
//
//  Created by 大西玲音 on 2021/06/14.
//

import UIKit

enum Week: String, CaseIterable {
    case sunday = "日曜日"
    case monday = "月曜日"
    case tuesday = "火曜日"
    case wednesday = "水曜日"
    case thursday = "木曜日"
    case friday = "金曜日"
    case saturday = "土曜日"
}

protocol AlarmRepeatVCDelegate: AnyObject {
    func alarmRepeatVC(addRepeat: AlarmRepeatViewController, weeks: [String])
}

final class AlarmRepeatViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    weak var delegate: AlarmRepeatVCDelegate?
    private var weeks = Week.allCases.map { $0.rawValue }
    var selectedDays = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        delegate?.alarmRepeatVC(addRepeat: self, weeks: sort(selectedDays))
        
    }
    
    private func sort(_ selectDays: [String]) -> [String] {
        var dayDictionary = [String: Int]()
        for i in 0..<weeks.count {
            dayDictionary[weeks[i]] = i
        }
        var daysOfWeek = selectDays
        daysOfWeek.sort { (dayDictionary[$0] ?? 7) < (dayDictionary[$1] ?? 7) }
        return daysOfWeek
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        tableView.tableFooterView = UIView()
    }
    
}

extension AlarmRepeatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        if !selectedDays.contains(weeks[indexPath.row]) {
            selectedDays.append(weeks[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
        selectedDays = selectedDays.filter { $0 != weeks[indexPath.row] }
    }
    
}

extension AlarmRepeatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weeks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmRepeatVCCellID", for: indexPath)
        cell.textLabel!.text = "毎" + weeks[indexPath.row]
        cell.selectionStyle = .none
        selectedDays.forEach {
            if weeks[indexPath.row] == $0 {
                cell.accessoryType = .checkmark
            }
        }
        return cell
    }
    
}

