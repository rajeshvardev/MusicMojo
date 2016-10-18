//
//  MasterViewController.swift
//  MusicMojo
//
//  Created by RAJESH SUKUMARAN on 10/13/16.
//  Copyright © 2016 RAJESH SUKUMARAN. All rights reserved.
//

import UIKit
import MusicMojoLyrica

class MasterViewController: UITableViewController,ItunesSearchManagerProtocol,UISearchControllerDelegate ,UISearchBarDelegate{
    
    
    // MARK: - Constants
    static let searchBarHeaderHeight:Int = 40
    final let searchBarHeaderX = 10
    
    // MARK: - Properties
    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var songs:[Song]! = []
    let searchController = UISearchController(searchResultsController: nil)
    var searchBarHeight:Int!
    var itunesSearchManager:ItunesSearchManager!
    var recentSearchManager:RecentSearchManager = RecentSearchManager.sharedInstance
    var recentSearches:[String]!
    //the property introduces ,as the the searchcontroller isActive is set as soon as you clicked ,
    //hence has issues when the cells are pulled up when search bar becomes active
    var searchBarActive:Bool = false
    var acitivityIndicator:UIActivityIndicatorView!
    
    
    
    
    // MARK: - ItunesSearchManagerProtocol delegate methods
    func getSongsWhenDataTaskCompleted(songs:[Song])
    {
        print(songs)
        self.songs = songs
        //moved to main queue execution
        DispatchQueue.main.async {
            self.searchBarActive = true
            self.tableView.reloadData()
            self.scrollToTop()
        }
        removeActivityIndicator()
    }
    
    func getSongDataTaskError(error:Error)
    {
        print(error.localizedDescription)
        removeActivityIndicator()
    }
    
    
    
    // MARK: - Searchbar view Setup
    func setupHeaderView(searchBarHeaderHeight:Int = searchBarHeaderHeight)
    {
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: Int(searchController.searchBar.frame.width) , height: (Int(searchController.searchBar.frame.height) + searchBarHeaderHeight) ))
        let searchLabel = UILabel(frame: CGRect(x: searchBarHeaderX, y: 0, width: Int(searchController.searchBar.frame.width), height: searchBarHeaderHeight))
        searchLabel.text = Utils.getLocalisedString(key: "Search")
        searchLabel.font = UIFont(name: "Arial-BoldMT", size: 30)
        searchBarHeight = Int(searchController.searchBar.frame.height)
        searchController.searchBar.frame = CGRect(x: 0, y: searchBarHeaderHeight, width: Int(searchController.searchBar.frame.width), height: Int(searchController.searchBar.frame.height))
        //change the place holder alignment to left
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Utils.getLocalisedString(key: "Search Itunes Library")
        self.tableView.tableHeaderView?.insertSubview(searchLabel, at: 0)
        self.tableView.tableHeaderView?.insertSubview(searchController.searchBar, at: 1)
    }
    
    func showHideSearchBarHeader(hide:Bool)
    {
        if hide
        {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.tableHeaderView?.subviews[0].frame = CGRect(x: self.searchBarHeaderX, y: 0, width: Int(self.searchController.searchBar.frame.width), height: 0)
                self.tableView.tableHeaderView?.subviews[1].frame = CGRect(x: 0, y: 0, width: Int(self.searchController.searchBar.frame.width), height: self.searchBarHeight)
            })
            
        }
        else
        {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.tableHeaderView?.subviews[0].frame = CGRect(x: self.searchBarHeaderX, y: 0, width: Int(self.searchController.searchBar.frame.width), height: MasterViewController.searchBarHeaderHeight)
                self.tableView.tableHeaderView?.subviews[1].frame = CGRect(x: 0, y: MasterViewController.searchBarHeaderHeight, width: Int(self.searchController.searchBar.frame.width), height: self.searchBarHeight)
            })
            
            
        }
        
    }
    
    
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        self.navigationController?.title = Utils.getLocalisedString(key: "Music Mojo")
        setupHeaderView()
        //self.tableView.tableHeaderView = searchController.searchBar
        searchController.delegate = self
        searchController.searchBar.delegate = self
        recentSearches = recentSearchManager.readPreference()
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        self.navigationController?.title = Utils.getLocalisedString(key: "Music Mojo")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    
    
    //MARK:- UISearchControllerDelegate
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        showHideSearchBarHeader(hide:true)
        
    }
    
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        showHideSearchBarHeader(hide:false)
    }
    
    //MARK:- UISearchBarDelegate
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBarActive = true
        self.itunesSearchManager = ItunesSearchManager()
        self.itunesSearchManager.delegate = self
        showActivityIndicator()
        let task = self.itunesSearchManager.fetchMusicListFromiTunes(param: searchBar.text!)
        if task == nil
        {
            Utils.showErrorAlert(controller: self)
        }
        else
        {
            let recentManager = RecentSearchManager.sharedInstance
            recentManager.addPrefernce(search: searchBar.text!)
        }
        
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBarActive = false
        self.tableView.reloadData()
        showHideSearchBarHeader(hide:false)
        self.scrollToTop()
    }
    // MARK: - Segues
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                let selectedSong = songs[indexPath.row]
                controller.fetchLyrics(artist: selectedSong.artistName, song: selectedSong.trackName)
                controller.trackNameString = selectedSong.trackName
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        
    }
    
    
    // MARK: - Table View
    //TODO customize row height for recent search and songs
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !searchBarActive
        {
            recentSearches = recentSearchManager.readPreference()
            return recentSearches.count
        }
        else
        {
            return songs.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !searchBarActive
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath)
            let recent = cell.viewWithTag(81) as! UILabel
            recentSearches = recentSearchManager.readPreference()
            recent.text = recentSearches[indexPath.row]
            return cell
        }
        else
        {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            print(indexPath.row)
            let song = songs[indexPath.row]
            let art = cell.viewWithTag(90) as! UIImageView
            DispatchQueue.global(qos: .background).async {
                do {
                    let image  = try  UIImage(data: NSData(contentsOf: URL(string: song.artworkUrl60)!) as Data)
                    DispatchQueue.main.async {
                        art.image = image
                    }
                    
                } catch  {
                    print("error")
                }
            }
            let track = cell.viewWithTag(91) as! UILabel
            track.text = song.trackName
            let artist = cell.viewWithTag(92) as! UILabel
            artist.text = song.artistName
            let album = cell.viewWithTag(93) as! UILabel
            album.text = song.collectionName
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UIView(frame: CGRect(x: 10, y: 5, width: self.tableView.frame.width, height: 20))
        let label = UILabel(frame: view.frame)
        label.font = UIFont(name: "Arial-BoldMT", size: 16)
        if !searchBarActive
        {
            label.text = Utils.getLocalisedString(key: "Recent Searches")
        }
        else
        {
            label.text = Utils.getLocalisedString(key: "Songs")
        }
        view.addSubview(label)
        return view
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.reuseIdentifier == "Cell2"
        {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                searchController.isActive = true
                //setupHeaderView()
                showHideSearchBarHeader(hide:true)
                searchController.searchBar.text = recentSearches[indexPath.row]
                self.itunesSearchManager = ItunesSearchManager()
                self.itunesSearchManager.delegate = self
                showActivityIndicator()
                let task = self.itunesSearchManager.fetchMusicListFromiTunes(param: recentSearches[indexPath.row])
                if task == nil
                {
                    Utils.showErrorAlert(controller: self)
                }
                else
                {
                    recentSearchManager.addPrefernce(search: recentSearches[indexPath.row])
                }
                
            }
        }
    }
    
    
    // MARK: - Activity Indicator
    func showActivityIndicator()
    {
        //TODO - Set up a activity indicator with music note symbols animation
        acitivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        acitivityIndicator.center = self.view.center
        acitivityIndicator.startAnimating()
        self.view.addSubview(acitivityIndicator)
        
    }
    
    func removeActivityIndicator()
    {
        acitivityIndicator?.removeFromSuperview()
    }
    
    // MARK: - Some Uitility
    func scrollToTop()
    {
        if searchBarActive
        {
            self.tableView.setContentOffset(CGPoint(x:0,y:0), animated: true)
        }
        else
        {
            self.tableView.setContentOffset(CGPoint(x:0,y:-15), animated: true)
        }
    }
    
}

