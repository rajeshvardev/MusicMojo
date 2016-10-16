//
//  MasterViewController.swift
//  MusicMojo
//
//  Created by RAJESH SUKUMARAN on 10/13/16.
//  Copyright © 2016 RAJESH SUKUMARAN. All rights reserved.
//

import UIKit
import iTunesSearch

class MasterViewController: UITableViewController,ItunesSearchManagerProtocol {
    
    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var songs:[Song]! = []
    func getSongsWhenDataTaskCompleted(songs:[Song])
    {
        print(songs)
        self.songs = songs
        self.tableView.reloadData()
    }
    
    func getSongDataTaskError(error:NSError)
    {
        print(error.localizedDescription)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        let manager = ItunesSearchManager()
        manager.delegate = self
        let _ = manager.fetchMusicListFromiTunes()
        
        
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        showActivityIndicator()
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
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let _ = self.tableView.indexPathForSelectedRow {
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.fetchLyrics()
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        print(indexPath.row)
        let song = songs[indexPath.row]
        let art = cell.viewWithTag(90) as! UIImageView
        do {
            art.image = try  UIImage(data: NSData(contentsOf: URL(string: song.artworkUrl60)!) as Data)
        } catch  {
            print("error")
        }
        
        let track = cell.viewWithTag(91) as! UILabel
        track.text = song.trackName
        let artist = cell.viewWithTag(92) as! UILabel
        artist.text = song.artistName
        let album = cell.viewWithTag(93) as! UILabel
        album.text = song.collectionName
        return cell
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
    
    func showActivityIndicator()
    {
        let alphaView = UIView(frame: self.view.frame)
        alphaView.backgroundColor = UIColor.init(white: 1.0, alpha: 1.0)
        self.view.window?.addSubview(alphaView)
    }
    
    
}

