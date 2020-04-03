//
//  IpViewController.swift
//  NisNews
//
//  Created by K&K on 01.04.2020.
//  Copyright © 2020 KK. All rights reserved.
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
    let addres = textField.text ?? ""

    guard URL(string: addres) != nil else {
        showAlert()
        return false
    }

    AllServices.newsService.basePart = addres
        self.dismiss(animated: true)
        return true
    }

    func showAlert() {
        let alertController = UIAlertController(title: "Что-то пошло не так", message: "Неверный адрес", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))

        self.present(alertController, animated: true)
    }
}
