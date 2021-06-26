//
//  AlarmTimeTableViewCell.swift
//  Alarm-Sample
//
//  Created by 大西玲音 on 2021/06/14.
//

import UIKit

final class AlarmTimeTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var repeatingLabel: UILabel!
    @IBOutlet private weak var mySwitch: UISwitch!
    
    var mySwitchDidTapped: ((Bool) -> Void)?

    func configure(alarmTime: AlarmTime,
                   mySwitchDidTapped: @escaping (Bool) -> Void) {
        self.mySwitchDidTapped = mySwitchDidTapped
        timeLabel.text = TimeManager().toString(from: alarmTime.date)
        let repeatLabel = (alarmTime.repeatLabel == "Never") ? "" : "," + alarmTime.repeatLabel
        repeatingLabel.text = alarmTime.label + repeatLabel
        mySwitch.isOn = alarmTime.isOn
        editingAccessoryType = .disclosureIndicator
        accessoryView = mySwitch
    }
    
    @IBAction private func mySwitchDidTapped(_ sender: UISwitch) {
        mySwitchDidTapped?(sender.isOn)
    }
    
}
