//
//  EnterCodeViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 9/18/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit

class EnterCodeViewController: UIViewController {

    @IBOutlet weak var codeBox: UITextField!
    
    var callbackClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func codeBoxDidChange(_ sender: Any) {
        
    }
    
    @IBAction func submitButtonTouchDown(_ sender: Any) {
        
        let code = codeBox.text!
        if code.count == 0 {
            return
        }
        
        callbackClosure?()
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancelButtonTouchDown(_ sender: Any) {
        
        callbackClosure?()
        dismiss(animated: true, completion: nil)
        
    }
    
}
