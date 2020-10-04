//
//  SurveyViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 9/18/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit
import WebKit

class SurveyViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var webViewWrapper: UIView!
    @IBOutlet weak var containerView: UIView!
    var webView: WKWebView!
    
    var questionnaireHasLaunched: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let textAttribNormal = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        let textAttribSelected = [NSAttributedString.Key.foregroundColor: UIColor(red: 45.0/255, green: 162.0/255, blue: 208.0/255, alpha: 1.0)]
        segmentedControl.setTitleTextAttributes(textAttribNormal, for: .normal)
        segmentedControl.setTitleTextAttributes(textAttribSelected, for: .selected)
        
        let contentController = WKUserContentController();
        contentController.add(self, name: "buttonAction")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        webView = WKWebView(frame: webViewWrapper.bounds, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webViewWrapper.addSubview(webView)
         
        webView.leadingAnchor.constraint(equalTo: webViewWrapper.leadingAnchor, constant: 0).isActive = true
        webView.trailingAnchor.constraint(equalTo: webViewWrapper.trailingAnchor, constant: 0).isActive = true
        webView.topAnchor.constraint(equalTo: webViewWrapper.topAnchor, constant: 0).isActive = true
        webView.bottomAnchor.constraint(equalTo: webViewWrapper.bottomAnchor, constant: 0).isActive = true
        webView.isOpaque = false
        webView.backgroundColor = UIColor.darkGray
        webView.navigationDelegate = self
        
        containerView.isHidden = false
 
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        guard let response = message.body as? String else { return }
        switch (response) {
            default:
                print("Do something")
        }
        
    }
    
    @IBAction func segmentedControlDidChange(_ sender: Any) {

        let category = returnCategoryFromSegmentedControl()
        if (category == "about-survey") {
            containerView.isHidden = false
        } else {
            containerView.isHidden = true
            doLoadQuestionnaire()
        }
        
    }
    
    func returnCategoryFromSegmentedControl() -> String {
        
        var str:String = ""
        switch segmentedControl.selectedSegmentIndex {
          case 0:
              str = "about-survey"
          case 1:
              str = "take-survey"
          default:
              break
        }
        return str
        
    }
    
    func doLoadQuestionnaire() {
        
        if (!checkIfQuestionnairesExist()) {
        
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterCodeVC") as! EnterCodeViewController
            vc.callbackClosure = { [weak self] in
                self?.callMeFromPresentedVC()
            }
            self.definesPresentationContext = true
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
            
        } else if (!questionnaireHasLaunched) {
            
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
    
    public func switchSegmentedControl(to: Int) {
        
        segmentedControl.selectedSegmentIndex = to
        
        let category = returnCategoryFromSegmentedControl()
        if (category == "about-survey") {
            containerView.isHidden = false
        } else {
            containerView.isHidden = true
            doLoadQuestionnaire()
        }
        
    }
    
    private func callMeFromPresentedVC() {
         
        doLoadQuestionnaire()
        
    }
    
    private func launchQuestionnaire() {
        
        questionnaireHasLaunched = true
        
        let htmlFile = Bundle.main.path(forResource: "index", ofType: "html")
        let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        webView.loadHTMLString(html!, baseURL: Bundle.main.bundleURL)
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let contentUrl = URL(fileURLWithPath: documentPath + "/questionnaire")
        let filePath = contentUrl.appendingPathComponent("questionnaires.json")
        do {
            var jsonString = try String(contentsOfFile: filePath.path)
            jsonString = jsonString.replacingOccurrences(of: "'", with: "\\'")
            webView.evaluateJavaScript("getJsonFromSystem('\(jsonString)')", completionHandler: nil)
        } catch {
            print(error)
        }
        
    }

}
