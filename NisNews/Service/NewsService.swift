//
//  NewsService.swift
//  NisNews
//
//  Created by К&К on 07.03.2020.
//  Copyright © 2020 KK. All rights reserved.
//

import UIKit

class ImageDownload {
    var task: URLSessionDownloadTask?
    var isDownloading = false
    var resumeDate: Data?
    var progress: Float = 0
}

class AllServices {
    static let newsService = NewsService()
}

class NewsService: NSObject, URLSessionDelegate {
    
    var basePart = "http://2831373b.ngrok.io" {
        didSet {
            UserDefaults.standard.set(basePart, forKey: "basePartIp")
        }
    }
    private let jsonDecoder = JSONDecoder()
    private let imageDataCache = NSCache<NSString, UIImage>()
    private var activeDownloads: [URL: ImageDownload] = [:]
    
    lazy var session: URLSession = {
        URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }()
    
    func getNewsTags(completionHandler: @escaping ([Tag]?) -> Void) {
        let request = createRequestWith(url: "getTags")
        
        let task = session.dataTask(with: request) { d, r, e in
            if e != nil {
                completionHandler(nil)
                return
            }
            
            guard (r as? HTTPURLResponse) != nil else {
                completionHandler(nil)
                return
            }
            
            guard let data = d else {
                completionHandler(nil)
                return
            }
            
            completionHandler(try? self.jsonDecoder.decode([Tag].self, from: data))
        }
        
        task.resume()
    }

    
    func getArticlesByTag(_ tag: String, completionHandler: @escaping (NewsResponse?) -> Void) {
        let request = createRequestWith(url: "getNewsByTag/\(tag)")
        
        let task = session.dataTask(with: request) { d, r, e in
            if e != nil {
                completionHandler(nil)
                return
            }
            
            guard (r as? HTTPURLResponse) != nil else {
                completionHandler(nil)
                return
            }
            
            guard let data = d else {
                completionHandler(nil)
                return
            }
            
            completionHandler(try? self.jsonDecoder.decode(NewsResponse.self, from: data))
        }
        
        task.resume()
    }
    
    
    func getFullDescription(_ description: String, completionHandler: @escaping (String?) -> Void) {
        // let requestString = description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let request = createRequestWith(url: "genText/\(description)", withTimout: 20)
        
        let task = session.dataTask(with: request) { d, r, e in
            if e != nil {
                completionHandler(nil)
                return
            }
            
            guard (r as? HTTPURLResponse) != nil else {
                completionHandler(nil)
                return
            }
            
            guard let data = d else {
                completionHandler(nil)
                return
            }
            
            completionHandler(try? self.jsonDecoder.decode(String.self, from: data))
        }
        
        task.resume()
    }
    
    func loadImageWithUrl(_ url: String, completionHandler: @escaping (UIImage?) -> Void) {
        
        guard let imageUrl = URL(string: url) else {
            completionHandler(nil)
            return
        }
        
        
        if let image = imageDataCache.object(forKey: NSString(string: url)) {
            completionHandler(image)
            return
        }
        
        let download = ImageDownload()
        
        let task = self.session.downloadTask(with: imageUrl) { urlTask, urlResponse, error in
            if error != nil {
                completionHandler(nil)
                return
            }
            
            if let location = urlTask {
                let image = UIImage(data: (try! Data(contentsOf: location)))
                if let image = image {
                    self.imageDataCache.setObject(image, forKey: NSString(string: url))
                }
                
                completionHandler(image)
            }
        }
        
        
        if let activeDownload = activeDownloads[imageUrl] {
            activeDownload.task?.cancel()
            activeDownload.isDownloading = false
        }
        
        download.task = task
        
        task.resume()
        
        download.isDownloading = true
        
        activeDownloads[imageUrl] = download
    }
    
    private func createRequestWith(url: String, withTimout timeout: TimeInterval = 10) -> URLRequest {
        return URLRequest(url: URL(string: "\(basePart)/\(url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)
    }
}
