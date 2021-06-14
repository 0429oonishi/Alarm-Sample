//
//  AlarmSnoozeTableViewCell.swift
//  Alarm-Sample
//
//  Created by 大西玲音 on 2021/06/14.
//

import UIKit

protocol AlarmSnoozeTableViewCellDelegate: AnyObject {
    func alarmSnoozeCell(switchOn: AlarmSnoozeTableViewCell, isOn: Bool)
}

final class AlarmSnoozeTableViewCell: UITableViewCell {

    @IBOutlet private weak var mySwitch: UISwitch!
    @IBOutlet private weak var titleLabel: UILabel!
    
    weak var delegate: AlarmSnoozeTableViewCellDelegate?
    
    func configure(text: String, isOn: Bool) {
        titleLabel.text = text
        mySwitch.isOn = isOn
    }
    
    @IBAction private func snoozeSwitchDidChanged(_ sender: UISwitch) {
        delegate?.alarmSnoozeCell(switchOn: self, isOn: sender.isOn)
    }
    
}
