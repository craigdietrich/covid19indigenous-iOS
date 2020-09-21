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

    }
    
    func closeAndLoadQuestionnaire() {
        
        callbackClosure?()
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func submitButtonTouchDown(_ sender: Any) {
        
        let code = codeBox.text!
        if code.count == 0 {
            return
        }
        
        doCode(code: code)
        
    }
    
    func doCode(code: String) {
        
        if !Reachability.isConnectedToNetwork() {
            let alertController = UIAlertController(title: "No Connection", message: "Your device does not appear to have an Internet connection. Please establish a connection and try again.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                print("Ok button tapped");
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)
            return
        }
        
        codeSubmitButton.isEnabled = false
        
        URLCache.shared.removeAllCachedResponses()
        let api = "https://covid19indigenous.ca/dashboard/pages/app?key=" + code
        if let url = URL(string: api) {
           let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("error=\(String(describing: error))")
                    DispatchQueue.main.async {
                        self.doShowGenericError()
                    }
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                    DispatchQueue.main.async {
                        self.doShowGenericError()
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
                        self.doShowGenericError()
                    }
                }
            }
            task.resume()
        }
        
    }
    
    func parseJson(json: NSDictionary) {
        
        codeSubmitButton.isEnabled = true
        
        if let error = json.value(forKey: "error") as? String {
            doShowExpressedError(error: error)
            return
        }
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        saveJsonString(json: jsonString!)
        
    }
    
    func saveJsonString(json: String) {
        
        let jsonFilename = "questionnaires.json"
        
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let contentUrl = URL(fileURLWithPath: documentPath + "/questionnaire")
        let filePath = contentUrl.appendingPathComponent(jsonFilename)
        
        do {
            if !FileManager.default.fileExists(atPath: filePath.path) {
                try FileManager.default.createDirectory(at: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            _deleteQuestionnaires()
            try json.write(to: filePath, atomically: true, encoding: .utf8)
            //let contents = try String(contentsOfFile: filePath.path)
            //print(contents)
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
    
    func doShowGenericError() {
        
        let alertController = UIAlertController(title: "Error", message: "There was a problem attemting to send the code to the server. Please try again", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            print("Ok button tapped");
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
        
        codeSubmitButton.isEnabled = true
        
    }
    
    func doShowExpressedError(error: String) {
        
        let alertController = UIAlertController(title: "Error", message: error + ". Please try again.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            print("Ok button tapped");
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
        
        codeSubmitButton.isEnabled = true
        
    }
    
    func _deleteQuestionnaires() {
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let contentFolderUrl = documentsUrl.appendingPathComponent("questionnaire")
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: contentFolderUrl, includingPropertiesForKeys: nil)
            let jsonFiles = contents.filter{ $0.pathExtension == "json" }
            for file in jsonFiles {
                try FileManager.default.removeItem(atPath: file.path)
            }
            print("Removed existing questionnaires file")
        } catch {
            print(error)
        }
        
    }
    
    func _printQuestionnaireDirectory() {
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let contentFolderUrl = documentsUrl.appendingPathComponent("questionnaire")
        do {
            print("All files in questionnaire folder:")
            let contents = try FileManager.default.contentsOfDirectory(at: contentFolderUrl, includingPropertiesForKeys: nil)
            print(contents)
        } catch {
            print(error)
        }
        
    }
    
}
