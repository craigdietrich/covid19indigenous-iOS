//
//  FirstViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 8/27/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var iPhoneVerticalContainer: UIView!
    @IBOutlet weak var iPhoneHoriztonalContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doLayout()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }

    @objc func rotated() {
        
        doLayout()
        
    }
    
    func doLayout() {
        
        var _isIPhone: Bool = true
        var _isVertical: Bool = true
        if UIScreen.main.bounds.width > UIScreen.main.bounds.height {
            _isVertical = false
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            _isIPhone = false
        }
        
        if (_isIPhone) {
            if (_isVertical) {
                iPhoneVerticalContainer.isHidden = false
                iPhoneHoriztonalContainer.isHidden = true
            } else {
                iPhoneVerticalContainer.isHidden = true
                iPhoneHoriztonalContainer.isHidden = false
            }
        } else {
            if (_isVertical) {
                
            } else {
                
            }
        }
        
    }

}

