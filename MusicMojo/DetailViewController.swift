//
//  DetailViewController.swift
//  MusicMojo
//
//  Created by RAJESH SUKUMARAN on 10/13/16.
//  Copyright © 2016 RAJESH SUKUMARAN. All rights reserved.
//

import UIKit
import iTunesSearch
class DetailViewController: UIViewController,LyricsSearchManagerProtocol {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var detailItem: String? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func fetchLyrics()
    {
        let lyrics = LyricsSearchManager()
        lyrics.delegate = self
        let task = lyrics.fetchLyricsForTrack()
    }
    
    
    func lyricsFound(lyrics:String)
    {
        print(lyrics)
        self.detailDescriptionLabel.text = lyrics
    }
    func lyricsError(error:Error)
    {
        
    }
    
    
}

