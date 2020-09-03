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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
