//
//  MoreViewController.swift
//  covid19indigenous
//
//  Created by Jalpesh Rajani on 12/08/24.
//  Copyright © 2024 craigdietrich.com. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {
    
    @IBOutlet var conversations: UIButton!
    @IBOutlet var viewPastSubmission: UIButton!
    @IBOutlet var dontSendResultToServer: UIButton!
    @IBOutlet var deleteParticipationCode: UIButton!

    var resultToServer : Bool {
        get {
             UserDefaults.standard.bool(forKey: "resultToServer")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "resultToServer")
            UserDefaults.standard.synchronize()
        }
    }
    
    var dontsendresultToserver = false

   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dontsendresultToserver = resultToServer
        _updateButtonResultToServer()
        conversations.layer.cornerRadius = 5
        viewPastSubmission.layer.cornerRadius = 5
        dontSendResultToServer.layer.cornerRadius = 5
        deleteParticipationCode.layer.cornerRadius = 5
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    
    @IBAction func conversationBtn(_ sender: Any) {
        _navigateToConversationRoute()
        
    }
    
    func _navigateToConversationRoute() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConversationsViewController") as! ConversationsViewController
        self.definesPresentationContext = true
        vc.modalPresentationStyle = .currentContext
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func viewPastSubmissionBtn(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewPastSubmissionController") as! ViewPastSubmissionController
        self.definesPresentationContext = true
        vc.modalPresentationStyle = .currentContext
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func dontSendResultToSurverBtn(_ sender: Any) {
    
        dontsendresultToserver = !dontsendresultToserver
        resultToServer = dontsendresultToserver
        _updateButtonResultToServer()
    }
    
    func _updateButtonResultToServer() {
        if dontsendresultToserver {
            dontSendResultToServer.setTitle("Don't send results to server", for: .normal)
            dontSendResultToServer.backgroundColor = .red
            dontSendResultToServer.setTitleColor(.white, for: .normal)
        } else {
           
            dontSendResultToServer.setTitle("Don't send results to server", for: .normal)
            dontSendResultToServer.backgroundColor = .white
            dontSendResultToServer.setTitleColor(UIColor(named: "themeBlue"), for: .normal)
        }
    }
    
    @IBAction func deleteParticipationCodeBtn(_ sender: Any) {
        
        
        let alertController = UIAlertController(title: "Reset Data", message: "This will delete participant code,any saved questionnaires and past submissions.Are you sure you wish to reset data?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let contentFolderUrl = documentsUrl.appendingPathComponent("survey")
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: contentFolderUrl, includingPropertiesForKeys: nil)
                for file in contents {
                    print("Removing " + file.path)
                    try FileManager.default.removeItem(atPath: file.path)
                }
                print("Emptied questionnaire folder")
            } catch {
                print(error)
            }
            
            UserDefaults.standard.removeObject(forKey: "SurveyHasConsented")
            UserDefaults.standard.removeObject(forKey: "UserEnteredCode")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
}
