//
//  EnterCodeViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 9/18/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit

class EnterCodeViewController: UIViewController {

    @IBOutlet weak var codeBox: UITextField!
    @IBOutlet weak var codeSubmitButton: UIButton!
    
    var callbackClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        codeBox.autocorrectionType = .no
            
    }
    
    func closeAndLoadQuestionnaire() {
        
        callbackClosure?()
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func submitButtonTouchDown(_ sender: Any) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        let code = codeBox.text!
        if code.count == 0 {
            return
        }
        
        doCode(code: code)
        
    }
    
    @IBAction func cancelButtonTouchDown(_ sender: Any) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func doCode(code: String) {
        
        if !Reachability.isConnectedToNetwork() {
            let alertController = UIAlertController(title: NSLocalizedString("no_connection", comment: ""), message: NSLocalizedString("no_connection_text", comment: ""), preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                print("Ok button tapped");
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)
            return
        }
        
        codeSubmitButton.isEnabled = false
        
        URLCache.shared.removeAllCachedResponses()
        let api = "https://ourdataindigenous.ca/dashboard/pages/app?key=" + code + "&t=" + String(NSDate().timeIntervalSince1970)
        //let api = "https://craigdietrich.com/projects/proxies/covid19indigenous/app_proxy.php?key=" + code + "&t=" + String(NSDate().timeIntervalSince1970)
        if let url = URL(string: api) {
           let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("error=\(String(describing: error))")
                    DispatchQueue.main.async {
                        self.doShowGenericError(error: String(describing: error))
                    }
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                    DispatchQueue.main.async {
                        self.doShowGenericError(error: String(describing: response))
                    }
                }
                do {
                    if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        DispatchQueue.main.async {
                            self.parseJson(json: convertedJsonIntoDict, code: code)
                        }
                   }
                } catch let error as NSError {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        self.doShowGenericError(error: NSLocalizedString("could_not_parse_json", comment: ""))
                    }
                }
            }
            task.resume()
        }
        
    }
    
    func parseJson(json: NSDictionary, code: String) {
        
        codeSubmitButton.isEnabled = true
        
        if let error = json.value(forKey: "error") as? String {
            doShowExpressedError(error: error)
            return
        }
        
        UserDefaults.standard.set(code, forKey: "UserEnteredCode")
        
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
            if !FileManager.default.fileExists(atPath: contentUrl.path) {
                try FileManager.default.createDirectory(at: contentUrl, withIntermediateDirectories: true, attributes: nil)
            }
            
            _deleteQuestionnaires()
            
            try json.write(to: filePath, atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
        
        _printQuestionnaireDirectory()
        
        finishParseJson()
        
    }
    
    func finishParseJson() {
        
        dismiss(animated: true, completion: nil)
        
        callbackClosure?()
        
    }
    
    func doShowGenericError(error: String) {
        
        let alertController = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("error_send_code", comment: "") + " " + error + ". Please try again", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            print("Ok button tapped");
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
        
        codeSubmitButton.isEnabled = true
        
    }
    
    func doShowExpressedError(error: String) {
        
        let alertController = UIAlertController(title: NSLocalizedString("error", comment: ""), message: error + ". " + NSLocalizedString("please_try_again", comment: ""), preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            print("Ok button tapped");
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
        
        codeSubmitButton.isEnabled = true
        
    }
    
    func _deleteQuestionnaires() {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let contentFolderUrl = documentsUrl.appendingPathComponent("survey")
        do {
            if FileManager.default.fileExists(atPath: contentFolderUrl.path) {
                let contents = try FileManager.default.contentsOfDirectory(at: contentFolderUrl, includingPropertiesForKeys: nil)
                for file in contents {
                    print("Removing " + file.path)
                    try FileManager.default.removeItem(atPath: file.path)
                }
                print("Emptied questionnaire folder")
            } else {
                print("survey folder does not exists yet")
            }
        } catch {
            print(error)
        }
    }
    
    func _printQuestionnaireDirectory() {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let contentFolderUrl = documentsUrl.appendingPathComponent("survey")
        do {
            print("All files in questionnaire folder:")
            let contents = try FileManager.default.contentsOfDirectory(at: contentFolderUrl, includingPropertiesForKeys: nil)
            print(contents)
        } catch {
            print(error)
        }
    }
}
