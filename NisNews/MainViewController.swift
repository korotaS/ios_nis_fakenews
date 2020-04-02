//
//  ViewController.swift
//  NisNews
//
//  Created by К&К on 07.03.2020.
//  Copyright © 2020 KK. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var tags: [Tag] = []
    
    private var selectedItem: Article?
    private var selectedImage: UIImage?
    
    private let containerManager = ContainerManager()
    
    private let refreshControl = UIRefreshControl()
    private var currentTag = 0
    private var updatedTag = true
    private var loaded = false
    private var updated = true
    
    private var news = NewsResponse(articles: [])
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action:
            #selector(handleRefreshControl),
                                 for: .valueChanged)
        
        handleRefreshControl()
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            performSegue(withIdentifier: "ipSegue", sender: self)
        }
    }
    
    @objc func handleRefreshControl() {
        self.refreshControl.beginRefreshing()
        self.updated = true
        AllServices.newsService.getNewsTags { r in
            self.tags.removeAll()
            self.tags.append(Tag(title: "Популярное", tag: "Top"))
            
            if let response = r {
                self.tags.append(contentsOf: response)
                self.containerManager.saveTags(response)
                
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.collectionView.reloadData()
                }
                
                self.refreshTableView()
                
            } else {
                self.tags.append(contentsOf: self.containerManager.loadSavedTags())
                if self.tags.isEmpty {
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                        self.showAlert()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                        self.collectionView.reloadData()
                    }
                    self.refreshTableView()
                }
            }
            
            self.updated = false
        }
    }
    
    func refreshTableView() {
        if !refreshControl.isRefreshing {
            refreshControl.beginRefreshing()
        }
        
        self.news = NewsResponse(articles: [])
        self.tableView.reloadData()
        
        
        let currentTag = self.tags[self.currentTag].tag
        self.updated = true
        AllServices.newsService.getArticlesByTag(currentTag) { r in
            if let response = r {
                self.containerManager.saveArticles(response.articles, byTag: currentTag)

                DispatchQueue.main.async {
                    self.news = response

                    self.refreshControl.endRefreshing()
                    self.updatedTag = true
                    self.tableView.reloadData()
                }
            } else {
                self.news.articles = self.containerManager.loadSavedArticlesByTag(currentTag)
                
                if self.news.articles.isEmpty {
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                        self.showAlert()
                    }
                } else {
                    self.refreshControl.endRefreshing()
                    self.updatedTag = true
                    self.tableView.reloadData()
                }
            }
            
            self.updated = false
        }
    }
    
    func convertDay(_ dateStr: String, withDateFormat dateFormat: String) -> String? {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = dateFormat
        
        if let date = dateFormatterGet.date(from: dateStr) {
            return dateFormatterPrint.string(from: date)
        } else {
            return nil
        }
    }
    
    func showAlert() {
        if !loaded {
            loaded = true
            let alertController = UIAlertController(title: "Что-то пошло не так", message: "Попробуйте воспользоваться приложением попозже", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
            
            self.present(alertController, animated: true)
            loaded = false
        }
    }
    
    // MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        news.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! NewsCell
        
        let item =  news.articles[indexPath.row]
        
        cell.selectionStyle = .none
        
        cell.newsImageView.image = nil
        
        AllServices.newsService.loadImageWithUrl(item.image) { im in
            if let image = im {
                DispatchQueue.main.async {
                    cell.newsImageView.image = image
                }
            }
        }
        
        cell.descriptionLabel.text = item.description
        cell.titleLabel.text = item.title
        cell.dateLabel.text = convertDay(item.date, withDateFormat: "d MMM yyyy")
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !updated {
            selectedItem = news.articles[indexPath.row]
            selectedImage = (tableView.cellForRow(at: indexPath) as? NewsCell)?.newsImageView.image
            self.performSegue(withIdentifier: "detailsSegue", sender: self)
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    
        if segue.identifier == "detailsSegue", let controller = segue.destination as? DetailsViewController {
            controller.item = selectedItem
            controller.newsImage = selectedImage
        } else if segue.identifier == "detailsSegue", let controller = segue.destination as? IpViewController{
            
        }
    }
    
    // MARK: CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! TagCell
        cell.tagLabel.text = tags[indexPath.row].title
        cell.layer.borderColor = UIColor.systemGray.cgColor
        cell.alpha = 0.6
        
        if indexPath.row == currentTag {
            cell.backgroundColor = .systemGray
        } else {
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = 30
        let width = (tags[indexPath.row].title.count) * 5 + 30
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == currentTag {
            return
        }
        
        let currentPath = IndexPath(row: currentTag, section: 0)
        
        if let cell = collectionView.cellForItem(at: currentPath) as? TagCell {
            cell.backgroundColor = .clear
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCell {
            cell.backgroundColor = .systemGray
        }

        currentTag = indexPath.row
        
        refreshTableView()
    }
    
}
