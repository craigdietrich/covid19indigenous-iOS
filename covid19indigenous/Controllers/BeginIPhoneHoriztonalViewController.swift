//
//  BeginIPhoneHoriztonalViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 8/29/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit

class BeginIPhoneHoriztonalViewController: UIViewController {

    @IBOutlet weak var aboutTheSurveyButton: UIButton!
    @IBOutlet weak var takeTheSurveyButton: UIButton!
    @IBOutlet weak var ViewConversationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        aboutTheSurveyButton.layer.cornerRadius = 5;
        aboutTheSurveyButton.layer.masksToBounds = true;
        takeTheSurveyButton.layer.cornerRadius = 5;
        takeTheSurveyButton.layer.masksToBounds = true;
        ViewConversationButton.layer.cornerRadius = 5;
        ViewConversationButton.layer.masksToBounds = true;
        
    }
    
    @IBAction func aboutTouchDown(_ sender: Any) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        let parentVC = self.parent as! FirstViewController
        parentVC.switchTabBar(to: 1)
        
    }
    
    @IBAction func takeSurveyTouchDown(_ sender: Any) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        let parentVC = self.parent as! FirstViewController
        parentVC.switchTabBar(to: 2)
        
    }
    
    @IBAction func conversationsTouchDown(_ sender: Any) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        let parentVC = self.parent as! FirstViewController
        parentVC.switchTabBar(to: 3)
        
    }
    
}
