//
//  BeginIPhoneVerticalViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 8/29/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit

class BeginIPhoneVerticalViewController: UIViewController {

    @IBOutlet weak var aboutTheSurveyButton: UIButton!
    @IBOutlet weak var takeSurveyButton: UIButton!
    @IBOutlet weak var viewConversationsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        aboutTheSurveyButton.layer.cornerRadius = 5;
        aboutTheSurveyButton.layer.masksToBounds = true;
        takeSurveyButton.layer.cornerRadius = 5;
        takeSurveyButton.layer.masksToBounds = true;
        viewConversationsButton.layer.cornerRadius = 5;
        viewConversationsButton.layer.masksToBounds = true;
        
    }
    
    @IBAction func aboutTouchDown(_ sender: Any) {
        
        let parentVC = self.parent as! FirstViewController
        parentVC.switchTabBar(to: 1)
        
    }
    
    @IBAction func takeSurveyTouchDown(_ sender: Any) {
        
        let parentVC = self.parent as! FirstViewController
        parentVC.switchTabBar(to: 2)
        
    }
    
    @IBAction func conversationsTouchDown(_ sender: Any) {
        
        let parentVC = self.parent as! FirstViewController
        parentVC.switchTabBar(to: 3)
        
    }

}
