//
//  SearchDataSource.swift
//  GrandEntrance
//
//  Created by Alexander Simson on 2014-08-14.
//  Copyright (c) 2014 Simson Creative Solutions. All rights reserved.
//

import UIKit

protocol SearchDataSourceDelegate {
    func dataSource(dataSource: SearchDataSource, didLoadDataWithError: NSError?)
}

class SearchDataSource: NSObject {
   
    var delegate: SearchDataSourceDelegate?
    var objects: Array<SearchItem>
    var searchString: String? {
        didSet {
            self.loadSearchResults()
        }
    }
    
    override init()
    {
        self.objects = Array()
        super.init()
    }
    
    func objectAtIndex(index: NSInteger!) -> SearchItem
    {
        return self.objects[index] as SearchItem
    }
    
    func numberOfObjects() -> Int
    {
        return self.objects.count
    }
    
    func loadSearchResults()
    {
        if let searchString = self.searchString?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet()) {
            let url = NSURL(string: NSString(format: "http://ws.spotify.com/search/1/track.json?q=%@", searchString))
            let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
                if error != nil {
                    println(error)
                    UIAlertView(title: "Failed!", message: "Failed to load search results from spotify", delegate: nil, cancelButtonTitle: "Roger that!")
                    self.delegate?.dataSource(self, didLoadDataWithError: error)
                    return
                }
                
                var JSON : AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: nil)!
                var items = Array<SearchItem>()
                
                if let data = JSON as? NSDictionary {
                    if let tracks = data["tracks"] as? NSArray {
                        for track in tracks {
                            let artists = track["artists"] as? NSArray
                            let href = track["href"] as String;
                            let name = track["name"] as String;
                            
                            let searchItem = SearchItem()
                            searchItem.title = name
                            searchItem.url = href
                            
                            items.append(searchItem)
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.objects = items
                    self.delegate?.dataSource(self, didLoadDataWithError: nil)
                }
            })
            
            task.resume()
        } else {
            println("No search string...")
        }
    }
}
