//
//  DetailViewController.swift
//  MusicMojo
//
//  Created by RAJESH SUKUMARAN on 10/13/16.
//  Copyright © 2016 RAJESH SUKUMARAN. All rights reserved.
//

import UIKit
import MusicMojoLyrica
class DetailViewController: UIViewController,LyricsSearchManagerProtocol {
    // MARK: - Properties
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var trackName: UILabel!
    var lyrics:String = ""
    var trackNameString:String = ""
    
    
    // MARK: - CofigureView
    func configureView() {
        // Update the user interface for the detail item.
        DispatchQueue.main.async {
            if let label = self.detailDescriptionLabel {
                label.text = self.lyrics
            }
            if let track = self.trackName {
                track.text = self.trackNameString
            }
        }
        
        
        
    }
    
    // MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.configureView()
        self.navigationController?.title = Utils.getLocalisedString(key: "Lyrics")
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
    
    
    // MARK: - LyricsSearchManager
    func fetchLyrics(artist:String,song:String)
    {
        let lyrics = LyricsSearchManager()
        lyrics.delegate = self
        let task = lyrics.fetchLyricsForTrack(artist: artist, song: song)
        if task == nil
        {
            Utils.showErrorAlert(controller: self)
        }
    }
    
    // MARK: - LyricsSearchManagerProtocol delegate methods
    func lyricsFound(lyrics:String)
    {
        print(lyrics)
        self.lyrics = lyrics
        self.configureView()
    }
    func lyricsError(error:Error)
    {
        print(error.localizedDescription)
        self.lyrics = "No lyrics found"
        self.configureView()
    }
    
    
}

