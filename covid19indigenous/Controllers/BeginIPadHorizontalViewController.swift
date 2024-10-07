//
//  BeginIPadHorizontalViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 8/31/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit

class BeginIPadHorizontalViewController: UIViewController {

    @IBOutlet weak var aboutTheSurveyButton: UIButton!
    @IBOutlet weak var takeTheSurveyButton: UIButton!
    @IBOutlet weak var conversationsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        aboutTheSurveyButton.layer.cornerRadius = 15;
        aboutTheSurveyButton.layer.masksToBounds = true;
        takeTheSurveyButton.layer.cornerRadius = 15;
        takeTheSurveyButton.layer.masksToBounds = true;
        conversationsButton.layer.cornerRadius = 15;
        conversationsButton.layer.masksToBounds = true;
        
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
