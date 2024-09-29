//
//  SaveAnswersViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 10/17/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit

class SaveAnswersViewController: UIViewController {

    @IBOutlet weak var listOfItemsLabel: UILabel!
    @IBOutlet weak var uploadingLabel: UILabel!
    
    var callbackClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        _printQuestionnaireDirectory()
        
        uploadingLabel.text = NSLocalizedString("checking_internet_connection", comment: "")
        
        let seconds = 3.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.go()
        }
        
    }
    
    func go() {
        
        if (Reachability.isConnectedToNetwork()) {
            uploadingLabel.text = NSLocalizedString("uploading_answers", comment: "")
            _doSendAnswers()
        } else {
            uploadingLabel.text = NSLocalizedString("no_internet_connection", comment: "")
            dismiss(animated: true, completion: nil)
            callbackClosure?()
        }
        
    }
    
    func _doSendAnswers() {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let contentFolderUrl = documentsUrl.appendingPathComponent("survey")
        do {
            listOfItemsLabel.text = ""
            if FileManager.default.fileExists(atPath: contentFolderUrl.path) {
                let contents = try FileManager.default.contentsOfDirectory(at: contentFolderUrl, includingPropertiesForKeys: nil)
                if(contents.contains { $0.hasDirectoryPath }) {
                    let answers = try FileManager.default.contentsOfDirectory(at: contentFolderUrl.appendingPathComponent("submissions"), includingPropertiesForKeys: nil)
                    for file in answers {
                        if (file.path.contains("answers_")) {
                            let filename = file.lastPathComponent.replacingOccurrences(of: "answers_", with: "").replacingOccurrences(of: ".json", with: "  ")
                            listOfItemsLabel.text = listOfItemsLabel.text! + NSLocalizedString("past_answers", comment: "") + "\n" + filename + "\n\n"
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
       
            do {
                if FileManager.default.fileExists(atPath: contentFolderUrl.path) {
                    let contents = try FileManager.default.contentsOfDirectory(at: contentFolderUrl, includingPropertiesForKeys: nil)
                    if(contents.contains { $0.hasDirectoryPath }) {
                        let answers = try FileManager.default.contentsOfDirectory(at: contentFolderUrl.appendingPathComponent("submissions"), includingPropertiesForKeys: nil)
                        for file in answers {
                            if (file.path.contains("answers_")) {
                                let data = try Data(contentsOf: URL(fileURLWithPath: file.path), options: .mappedIfSafe)
                                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                                
                                _doSendAnswer(jsonResult: jsonResult, filePath: file.path)
                                
                                uploadingLabel.text = NSLocalizedString("uploading_answers", comment: "")
                            }
                        }
                    }
                }
            } catch {
                print("Error:")
                print(error)
            }

        let seconds = 3.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.dismiss(animated: true, completion: nil)
            self.callbackClosure?()
        }
        
    }
    
    func _doSendAnswer(jsonResult: Any, filePath: String) {
        
        let url = URL(string: "https://ourdataindigenous.ca/dashboard/pages/handler")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("https://ourdataindigenous.ca/", forHTTPHeaderField: "Referer")
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonResult, options: [])
        request.httpBody = jsonData
        print("Sending request...")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                } catch {
                    print("Could not delete file " + filePath)
                }
                return
            }
        }

        task.resume()
        
    }
    
    func _printQuestionnaireDirectory() {
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let contentFolderUrl = documentsUrl.appendingPathComponent("survey")
//        questionnaire
        do {
            print("All files in questionnaire folder:")
            let contents = try FileManager.default.contentsOfDirectory(at: contentFolderUrl, includingPropertiesForKeys: nil)
            print(contents)
        } catch {
            print(error)
        }
        
    }

}
