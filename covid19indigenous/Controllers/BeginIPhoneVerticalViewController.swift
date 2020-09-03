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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
