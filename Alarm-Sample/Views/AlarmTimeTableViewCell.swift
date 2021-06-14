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
    
    func configure(alarmTime: AlarmTime) {
        timeLabel.text = TimeManager().toString(from: alarmTime.date)
        let repeatLabel = (alarmTime.repeatLabel == "Never") ? "" : "," + alarmTime.repeatLabel
        repeatingLabel.text = alarmTime.label + repeatLabel
        mySwitch.isOn = alarmTime.onOff
        editingAccessoryType = .disclosureIndicator
        accessoryView = mySwitch
    }
    
}
