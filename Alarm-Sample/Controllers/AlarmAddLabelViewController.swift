//
//  AlarmAddLabelViewController.swift
//  Alarm-Sample
//
//  Created by 大西玲音 on 2021/06/14.
//

import UIKit

protocol AlarmAddLabelVCDelegate: AnyObject {
    func alarmAddLabel(labelText: AlarmAddLabelViewController, text: String)
}

final class AlarmAddLabelViewController: UIViewController {
    
    @IBOutlet private weak var textField: UITextField!
    
    weak var delegate: AlarmAddLabelVCDelegate?
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.clearButtonMode = .always
        textField.returnKeyType = .done
        textField.delegate = self
        textField.becomeFirstResponder()
        textField.text = text ?? ""
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let text = textField.text, !text.isEmpty {
            delegate?.alarmAddLabel(labelText: self, text: text)
        }
        
    }
    
}

extension AlarmAddLabelViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            delegate?.alarmAddLabel(labelText: self, text: text)
            self.navigationController?.popViewController(animated: true)
        }
        return true
    }
    
}
