//
//  SearchViewController.swift
//  NisNews
//
//  Created by Артём Кулаков on 29.03.2020.
//  Copyright © 2020 KK. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var searchBar: UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 20))
    
    private var selectedItem: Article?
    private var selectedImage: UIImage?
    
    private let containerManager = ContainerManager()
    
    private let refreshControl = UIRefreshControl()
    private var currentTag = 0
    private var updatedTag = true
    private var loaded = false
    private var updated = true
    
    private var news = NewsResponse(articles: [])

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.placeholder = "News tag"
        searchBar.delegate = self
        tableView.refreshControl = refreshControl
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBar)
    }
    
    func refreshTableView(byTag tag: String) {
        if !refreshControl.isRefreshing {
            refreshControl.beginRefreshing()
        }
        
        self.news = NewsResponse(articles: [])
        self.tableView.reloadData()
        
        self.updated = true
        AllServices.newsService.getArticlesByTag(tag) { r in
            if let response = r {
                self.containerManager.saveArticles(response.articles, byTag: tag)
                
                DispatchQueue.main.async {
                    self.news = response
                    
                    self.refreshControl.endRefreshing()
                    self.updatedTag = true
                    self.tableView.reloadData()
                }
            } else {
                self.news.articles = self.containerManager.loadSavedArticlesByTag(tag)
                
                if self.news.articles.isEmpty {
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
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

    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        refreshTableView(byTag: searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }
    
    // MARK: TabeView
    
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
        
        if let controller = segue.destination as? DetailsViewController {
            controller.item = selectedItem
            controller.newsImage = selectedImage
            controller.offsetOn = false
        }
    }

}
