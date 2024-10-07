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
    @IBOutlet weak var updatingQuestionnairesLabel: UILabel!
    var webView: WKWebView!
    
    var hasGrabbedQuestionnaire: Bool = false
    var questionnaireHasLaunched: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updatingQuestionnairesLabel.isHidden = true
        
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
        webView.navigationDelegate = self
        
        containerView.isHidden = false
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
 
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        guard let jsonStr = message.body as? String else { return }
        
        webView.load(URLRequest(url: URL(string:"about:blank")!))
        hasGrabbedQuestionnaire = false
        questionnaireHasLaunched = false
        
        let isSendResults = UserDefaults.standard.bool(forKey: "resultToServer")
        
        _saveJsonStr(jsonStr: jsonStr, isSendResults: isSendResults)
        
        if(!isSendResults) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SaveAnswersVC") as! SaveAnswersViewController
            vc.callbackClosure = { [weak self] in
                self?.callMeFromSaveAnswersVC()
            }
            self.definesPresentationContext = true
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        } else {
            self.callMeFromSaveAnswersVC()
        }
    }
    
    func _saveJsonStr(jsonStr: String, isSendResults: Bool) {
        
        print("Writing jsonStr...")
        let filename = String(NSDate().timeIntervalSince1970)
        
        let jsonFilename: String
        if(isSendResults) {
            jsonFilename = "local_" + filename + ".json"
        } else {
            jsonFilename = "answers_" + filename + ".json"
        }
        
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let contentUrl = URL(fileURLWithPath: documentPath + "/survey/submissions")
        
        let filePath = contentUrl.appendingPathComponent(jsonFilename)
        
        do {
            if !FileManager.default.fileExists(atPath: contentUrl.path) {
                try FileManager.default.createDirectory(at: contentUrl, withIntermediateDirectories: true, attributes: nil)
            }
            
            try jsonStr.write(to: filePath, atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func rotated() {
        
        var _isIPhone: Bool = true
        var _isVertical: Bool = true
        switch UIDevice.current.orientation {
            case .landscapeLeft, .landscapeRight:
                _isVertical = false
            case .portrait, .portraitUpsideDown:
                _isVertical = true
            default:
                _isVertical = true
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            _isIPhone = false
        }
        
        if (_isIPhone && !_isVertical) {
            webViewWrapper.superview?.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        } else {
            webViewWrapper.superview?.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9529411765, alpha: 1)
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
        
        updatingQuestionnairesLabel.isHidden = true
        
        if (!checkIfQuestionnairesExist()) {
            
            hasGrabbedQuestionnaire = true  // TODO: doesn't get reset if the user dumps all data
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterCodeVC") as! EnterCodeViewController
            vc.callbackClosure = { [weak self] in
                self?.callMeFromEnterCodeVC()
            }
            self.definesPresentationContext = true
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
            
        } else if (!hasGrabbedQuestionnaire) {
            
            hasGrabbedQuestionnaire = true  // TODO: doesn't get reset if the user dumps all data
            
            updatingQuestionnairesLabel.isHidden = false
            let code = UserDefaults.standard.string(forKey: "UserEnteredCode")!
            print("Going out and getting the questionnaires for code: " + code)
            doCode(code: code)
            
        } else if (!checkIfConsentHasPassed()) {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConsentVC") as! ConsentViewController
            vc.callbackClosure = { [weak self] in
                self?.callMeFromConsentVC()
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
        let contentUrl = URL(fileURLWithPath: documentPath + "/survey")
        let filePath = contentUrl.appendingPathComponent("questionnaires.json")
        
        if FileManager.default.fileExists(atPath: filePath.path) {
            return true
        }
        return false
        
    }
    
    func checkIfConsentHasPassed() -> Bool {
        
        let hasConsented = UserDefaults.standard.bool(forKey: "SurveyHasConsented")
        return hasConsented
        
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
    
    private func callMeFromEnterCodeVC() {
         
        doLoadQuestionnaire()
        
    }
    
    private func callMeFromConsentVC() {
         
        let hasConsented = UserDefaults.standard.bool(forKey: "SurveyHasConsented")
        
        if (hasConsented) {
            doLoadQuestionnaire()
        } else {
            switchSegmentedControl(to: 0)
        }
        
    }
    
    private func callMeFromSaveAnswersVC() {
        
        switchSegmentedControl(to: 0)
        
    }
    
    private func launchQuestionnaire() {

        webView.load(URLRequest(url: URL(string:"about:blank")!))
        
        questionnaireHasLaunched = true
        
        let fileExtension = getHtmlPageExtension()
        let htmlFile = Bundle.main.path(forResource: "index" + fileExtension, ofType: "html")
        let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        webView.loadHTMLString(html!, baseURL: Bundle.main.bundleURL)
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let contentUrl = URL(fileURLWithPath: documentPath + "/survey")
        let filePath = contentUrl.appendingPathComponent("questionnaires.json")
        do {
            var jsonString = try String(contentsOfFile: filePath.path)
            jsonString = jsonString.replacingOccurrences(of: "'", with: "\\'")
            jsonString = jsonString.replacingOccurrences(of: "\"", with: #"\""#)
            webView.evaluateJavaScript("getJsonFromSystem('\(jsonString)')", completionHandler: nil)
        } catch {
            print(error)
        }
        
    }
    
    func doCode(code: String) {
        
        if !Reachability.isConnectedToNetwork() {
            print("Not on internet, so continuing")
            doLoadQuestionnaire()
            return
        }
        
        URLCache.shared.removeAllCachedResponses()
        let api = "https://ourdataindigenous.ca/dashboard/pages/app?key=" + code + "&t=" + String(NSDate().timeIntervalSince1970)
        if let url = URL(string: api) {
           let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("error=\(String(describing: error))")
                    DispatchQueue.main.async {
                        self.doLoadQuestionnaire()
                    }
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                    DispatchQueue.main.async {
                        self.doLoadQuestionnaire()
                    }
                }
                do {
                    if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        DispatchQueue.main.async {
                            self.parseJson(json: convertedJsonIntoDict)
                        }
                   }
                } catch let error as NSError {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        self.doLoadQuestionnaire()
                    }
                }
            }
            task.resume()
        }
        
    }
    
    func parseJson(json: NSDictionary) {
        
        if let error = json.value(forKey: "error") as? String {
            print(error)
            doLoadQuestionnaire()
            return
        }
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        saveJsonString(json: jsonString!)
        
    }
    
    func saveJsonString(json: String) {
        
        let jsonFilename = "questionnaires.json"
        
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let contentUrl = URL(fileURLWithPath: documentPath + "/survey")
        let filePath = contentUrl.appendingPathComponent(jsonFilename)
        
        do {
            if !FileManager.default.fileExists(atPath: filePath.path) {
                try FileManager.default.createDirectory(at: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            try json.write(to: filePath, atomically: true, encoding: .utf8)
            print("Wrote new JSON to file")
        } catch {
            print(error.localizedDescription)
        }
        
        doLoadQuestionnaire()
        
    }
}
