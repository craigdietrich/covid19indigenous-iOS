//
//  ConversationsViewController.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 8/31/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit

class ConversationsViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let apiUrl = URL(string : "https://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey="+ApiDetails.apiKey);
    var articles: Array<Dictionary<String,Any>> = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ConversationsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "conversationsCell")
        
        loadData()
        
    }
    
    func loadData() {  // https://atomengine.co.uk/app-development-news/collectionview-swift/
        
        let session = URLSession.shared.dataTask(with: URLRequest(url : apiUrl!)) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if(httpResponse.statusCode != 200) {
                    //DIE AND SHOW ERROR MESSAGE
                }
            }
            if let myData = data {
                if let json = try? JSONSerialization.jsonObject(with: myData, options: []) as! Dictionary<String,Any> {
                    print(json)
                    if let statusCode = json["status"] as? String {
                        if(statusCode == "ok") {
                            if let articles = json["articles"] as? Array<Dictionary<String,Any>> {
                                self.articles = articles;
                                DispatchQueue.main.async {
                                    self.collectionView.reloadData()
                                }
                            } else {
                                //ERROR WITH API REQUEST NOT OK
                            }
                        }
                    } else {
                        //ERROR WITH API REQUEST NOT OK
                    }
                } else {
                    print("Error");
                }
            }
        }
        session.resume();
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var _isIPhone: Bool = true
        if UIDevice.current.userInterfaceIdiom == .pad {
            _isIPhone = false
        }
        
        var cellWidth: CGFloat = 0.0
        if (_isIPhone) {
            cellWidth = collectionView.frame.size.width
        } else {
            cellWidth = collectionView.frame.size.width / 3.1
        }
        let height = ((cellWidth * 9) / 16) * 2
        return CGSize(width: cellWidth, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.articles.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = articles[indexPath.row];
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "conversationsCell", for: indexPath) as! ConversationsCollectionViewCell;
        
        if let title = row["title"] as? String{
            cell.titleLabel.text = title;
        }
        
        if let urlToImage = row["urlToImage"] as? String {
            let url = URL(string: urlToImage)!
            let data = try? Data(contentsOf: url)
            cell.imageView.image = UIImage(data:data!)
        }

        if let description = row["description"] as? String{
            cell.descriptionLabel.text = description
        }
         
        /*
         if let publishedDate = row["publishedAt"] as? String{
             let dbDateFormatter = DateFormatter()
             dbDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
             if let date = dbDateFormatter.date(from: publishedDate){
                 let dateFormatter = DateFormatter()
                 dateFormatter.dateFormat = "MMM dd, yyyy"
                 let todaysDate = dateFormatter.string(from: date)
                 cell.labelPublished.text = "Published : " + todaysDate
             }
             
             print(publishedDate);
             
         }
        */
         return cell;
    }
    
}
