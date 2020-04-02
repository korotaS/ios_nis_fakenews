//
//  IpViewController.swift
//  NisNews
//
//  Created by Артём Кулаков on 01.04.2020.
//  Copyright © 2020 KKK. All rights reserved.
//

import UIKit

class IpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.text = AllServices.newsService.basePart
        textField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        AllServices.newsService.basePart = textField.text ?? ""
        self.dismiss(animated: true)
        return true
    }
}
