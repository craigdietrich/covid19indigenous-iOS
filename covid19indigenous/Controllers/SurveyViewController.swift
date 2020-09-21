//
//  SurveyViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 9/18/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit
import WebKit

class SurveyViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.isOpaque = false
        webView.backgroundColor = UIColor.darkGray
        webView.navigationDelegate = self
 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (!checkIfQuestionnairesExist()) {
        
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterCodeVC") as! EnterCodeViewController
            vc.callbackClosure = { [weak self] in
                self?.callMeFromPresentedVC()
            }
            self.definesPresentationContext = true
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
            
        } else {
            
            launchQuestionnaire()
            
        }
        
    }
    
    func checkIfQuestionnairesExist() -> Bool {
        
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let contentUrl = URL(fileURLWithPath: documentPath + "/questionnaire")
        let filePath = contentUrl.appendingPathComponent("questionnaires.json")
        
        if FileManager.default.fileExists(atPath: filePath.path) {
            return true
        }
        return false
        
    }
    
    private func callMeFromPresentedVC() {
         
        if (!checkIfQuestionnairesExist()) {
        
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterCodeVC") as! EnterCodeViewController
            vc.callbackClosure = { [weak self] in
                self?.callMeFromPresentedVC()
            }
            self.definesPresentationContext = true
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
            
        } else {
            
            launchQuestionnaire()
            
        }
        
    }
    
    private func launchQuestionnaire() {
        
        let htmlFile = Bundle.main.path(forResource: "index", ofType: "html")
        let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        webView.loadHTMLString(html!, baseURL: Bundle.main.bundleURL)
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let contentUrl = URL(fileURLWithPath: documentPath + "/questionnaire")
        let filePath = contentUrl.appendingPathComponent("questionnaires.json")
        do {
            let jsonString = try String(contentsOfFile: filePath.path)
            webView.evaluateJavaScript("getJsonFromSystem('\(jsonString)')", completionHandler: nil)
        } catch {
            print(error)
        }
        
    }

}
