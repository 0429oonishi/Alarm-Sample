//
//  AlarmDeleteTableViewCell.swift
//  Alarm-Sample
//
//  Created by 大西玲音 on 2021/06/14.
//

import UIKit

protocol AlarmDeleteTableViewCellDelegate: AnyObject {
    
}

final class AlarmDeleteTableViewCell: UITableViewCell {
    
    weak var delegate: AlarmDeleteTableViewCellDelegate?
    
}
