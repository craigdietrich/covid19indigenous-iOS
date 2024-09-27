//
//  ViewPastSubmissionController.swift
//  covid19indigenous
//
//  Created by Jalpesh Rajani on 12/08/24.
//  Copyright © 2024 craigdietrich.com. All rights reserved.
//

import UIKit

class ViewPastSubmissionController: UIViewController {
    
    @IBOutlet var listTblView: UITableView!
    
    var pastAnswers: [(url: URL, date: String)] = []
    var selectedRows: Set<IndexPath> = []
   
    
    var longPressed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "View past submission"
        navigationController?.isNavigationBarHidden = false
        
        _getAnswer()
                
        // Add long press gesture recognizer to the table view
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        listTblView.addGestureRecognizer(longPressGesture)
      
        
    }
    
    
    @IBAction func viewBtn(_ sender: Any) {
        let index = (sender as! UIView).tag
        let file = pastAnswers[index]
        
        readJsonFileToObject(path: file.url) { json in
            if let jsonData = json {
                if let titleData = jsonData["created"] as? String {
                    if let answersData = jsonData["answers"] as? [[String: Any]] {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AnswerViewController") as! AnswerViewController
                        vc.answer = answersData
                        vc.titleHeader = titleData
                        vc.date = file.date
                        vc.file = file.url
                        self.definesPresentationContext = true
                        vc.modalPresentationStyle = .currentContext
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    
    
    @IBAction func shareFile(_ sender: Any) {
        let index = (sender as! UIView).tag
        let fileURL = pastAnswers[index].url
        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    
    
    func readJsonFileToObject(path: URL, completionHandler:@escaping(([String:Any]?)->Void)) {
        do {
            let jsonData = try Data(contentsOf: path) // Try to decode it into a Swift Dictionary (if it's structured as key-value pairs)
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                // Now you can access your JSON data in the jsonObject dictionary
                completionHandler(jsonObject)
            }
        } catch(let error) {
            print(error)
            completionHandler(nil)
        }
    }
    
    func _getAnswer(){
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let questionnaireFolderUrl = documentPath.appendingPathComponent("survey")
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: questionnaireFolderUrl, includingPropertiesForKeys: [.creationDateKey], options: [])
            if(files.contains{ $0.hasDirectoryPath }) {
                let answers = try FileManager.default.contentsOfDirectory(at: questionnaireFolderUrl.appendingPathComponent("submissions"), includingPropertiesForKeys: nil)
                let jsonFiles = answers.filter{ $0.lastPathComponent.hasPrefix("local_") && $0.pathExtension == "json" }
                for file in jsonFiles {
                    if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path),
                       let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
                        let formattedDate = _formatDate(creationDate)
                        pastAnswers.append((url: file, date: formattedDate))
                    }
                }
                pastAnswers.sort(by: { $0.date < $1.date })
                listTblView.reloadData()
            }
        } catch {
            print("Error loading files: \(error.localizedDescription)")
        }
    }

    func _formatDate(_ date: Date) -> String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                return dateFormatter.string(from: date)

    }

    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
           let location = gestureRecognizer.location(in: listTblView)
           if let indexPath = listTblView.indexPathForRow(at: location) {
               if gestureRecognizer.state == .began {
                   longPressed = true
                   toggleCellSelection(at: indexPath)
                   updateNavigationBarBtn()
               }
           }
       }

       func toggleCellSelection(at indexPath: IndexPath) {
           if selectedRows.contains(indexPath) {
               selectedRows.remove(indexPath)
               listTblView.cellForRow(at: indexPath)?.contentView.backgroundColor = UIColor(named: "lightBlue")
           } else {
               selectedRows.insert(indexPath)
               listTblView.cellForRow(at: indexPath)?.contentView.backgroundColor = UIColor(named: "themeGray")
           }
           
           if selectedRows.isEmpty {
               longPressed = false
               self.navigationItem.rightBarButtonItem = nil // Hide delete button
               self.navigationItem.rightBarButtonItem = nil
              
           } else {
               updateNavigationBarBtn()
           }
       }

       // Show delete button in navigation bar
    func updateNavigationBarBtn() {
        let image = UIImage(systemName: "arrowshape.turn.up.forward")?.withRenderingMode(.alwaysOriginal)
        let shareButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(shareBtn(_:)))
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSubmission(_:)))
        self.navigationItem.rightBarButtonItems = [shareButton, deleteButton]
    }
    
    @objc func shareBtn(_ sender: UIBarButtonItem) {
        
        var shareFile = [URL] ()
        
        for indexPath in selectedRows{
            let file = pastAnswers[indexPath.row].url
            shareFile.append(file)
        }
        
        if !shareFile.isEmpty {
            let activityVC = UIActivityViewController(activityItems: shareFile, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = view
            self.present(activityVC, animated: true)
        }else{
            print("No file to share")
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc func deleteSubmission(_ sender: UIBarButtonItem) {
        let selectedIndexPaths = Array(selectedRows)
        selectedIndexPaths.sorted(by: { $0.row > $1.row }).forEach { indexPath in
            let file = pastAnswers[indexPath.row]
            do {
                try FileManager.default.removeItem(at: file.url)
            } catch {
                print("Error deleting file: \(error.localizedDescription)")
            }
            pastAnswers.remove(at: indexPath.row)
        }
        selectedRows.removeAll()
        listTblView.deleteRows(at: selectedIndexPaths, with: .fade)
        // Hide delete button after deletion
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
    }
}

extension ViewPastSubmissionController : UITableViewDelegate , UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pastAnswers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listTblView.dequeueReusableCell(withIdentifier: "ListTableCell", for: indexPath) as! ListTableCell
        
        let file = pastAnswers[indexPath.row]
        cell.listLbl.text = "Saved on \(file.date)"
        cell.viewBtn.tag = indexPath.row
        cell.shareBtn.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if longPressed {
            toggleCellSelection(at: indexPath)
        }
    }
}

