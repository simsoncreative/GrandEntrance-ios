//
//  SearchViewController.swift
//  GrandEntrance
//
//  Created by Alexander Simson on 2014-08-14.
//  Copyright (c) 2014 Simson Creative Solutions. All rights reserved.
//

import UIKit

protocol SearchViewControllerDelegate {
    func searchController(searchController: SearchViewController, didSelectTrack: SearchItem)
}

class SearchViewController: UITableViewController, UISearchBarDelegate, SearchDataSourceDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var cancelButton: UIBarButtonItem!
    var activityIndicator: UIActivityIndicatorView!
    var dataSource: SearchDataSource!
    var delegate: SearchViewControllerDelegate?
    
    // #pragma mark - UIViewController
    
    override init(style: UITableViewStyle)
    {
        self.dataSource = SearchDataSource()
        super.init(style: style)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        self.dataSource = SearchDataSource()
        super.init(coder: aDecoder)
        
        self.dataSource.delegate = self
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        self.searchBar.endEditing(true)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
    }
    
    // #pragma mark - Actions
    
    @IBAction func cancel(sender : AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // #pragma mark - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int
    {
        return self.dataSource.numberOfObjects()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("trackCell", forIndexPath: indexPath) as UITableViewCell
        let track = self.dataSource.objectAtIndex(indexPath.row)
        
        cell.textLabel?.text = track.title;
        cell.detailTextLabel?.text = track.url
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let track = self.dataSource.objectAtIndex(indexPath.row) as SearchItem;
        self.delegate?.searchController(self, didSelectTrack: track)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // #pragma mark - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar!)
    {
        self.dataSource.searchString = searchBar.text;
        self.activityIndicator.startAnimating()
    }
    
    // #pragma mark - SearchDataSourceDelegate
    func dataSource(dataSource: SearchDataSource, didLoadDataWithError: NSError?)
    {
        self.activityIndicator.stopAnimating()
        self.tableView.reloadData()
    }
}
