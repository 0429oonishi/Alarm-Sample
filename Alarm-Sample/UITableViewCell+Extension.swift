//
//  UITableViewCell+Extension.swift
//  Alarm-Sample
//
//  Created by 大西玲音 on 2021/06/14.
//

import UIKit

extension UITableViewCell {
    
    static var identifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: nil) }
    
}
