//
//  LyricsSearchManager.swift
//  MusicMojo
//
//  Created by RAJESH SUKUMARAN on 10/13/16.
//  Copyright © 2016 RAJESH SUKUMARAN. All rights reserved.
//

import UIKit
import Kanna

public protocol LyricsSearchManagerProtocol
{
    func lyricsFound(lyrics:String)
    func lyricsError(error:Error)
}

public class LyricsSearchManager: NSObject {
    
    public var delegate:LyricsSearchManagerProtocol!
    public func fetchLyricsForTrack(artist:String,song:String) -> URLSessionDataTask
    {
        //try to find a different api for the lyrics
        var task :URLSessionDataTask!
        let htmlUrlString = "http://lyrics.wikia.com/api.php"//?func=getSong&artist=Tom+Waits&song=new+coat+of+paint&fmt=json"
        
        var htmlUrlComps = URLComponents(string:htmlUrlString)
        let queryItems = [URLQueryItem(name: "func", value: "getSong"),URLQueryItem(name: "artist", value: artist),URLQueryItem(name: "song", value: song),URLQueryItem(name: "fmt", value: "json")]
        htmlUrlComps?.queryItems = queryItems
        let htmlUrl = htmlUrlComps?.url
        do {
            let htmlContentString = try String(contentsOf: htmlUrl!, encoding: .ascii)
            //todo
            //for some reason direct conversion is not working
            //let htmlContentData =  try NSData(contentsOf: htmlUrl, options: NSData.ReadingOptions())
            print(htmlContentString)
            //result is not proper json ,need to parse through to get the url
            let lyricsUrl = Utils.JsonLikeStructureValueFinder(key: "url", structure: htmlContentString)
            
            //now fetch the html content of the url
            let urlString = lyricsUrl!
            let url = URL(string: urlString)
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"
            // Excute HTTP Request
            
            
            task = URLSession.shared.dataTask(with: request) {
                data, response, error in
                
                // Check for error
                if error != nil
                {
                    print("error=\(error)")
                    return
                }
                
                // Print out response string
                let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                //print("responseString = \(responseString)")
                
                
                // parse html response to find the lyrics
                do
                {
                    
                    
                    if let document =   HTML(html: data!, encoding: .utf8)
                    {
                        
                        let nodes = document.xpath("//div[contains(@class, 'lyricbox')]")
                        /*
                         var  lyricsString = nodes.first?.text!
                         //for some reason the above block is giving text with escape chars
                         */
                        // there is an issue of text formatting
                        for element in nodes {
                            let lyricsString = element.text!
                            print("==================================================================================================================================================================================================")
                            print(lyricsString)
                            self.delegate.lyricsFound(lyrics: lyricsString)
                        }
                        
                        
                    }
                }
                catch let error {
                    print(error.localizedDescription)
                }
                
                
            }
            
            task.resume()
            
            
            
            
        } catch let error {
            print(error.localizedDescription)
            self.delegate.lyricsError(error: error)
        }
        
        
        return task
    }
    
}
