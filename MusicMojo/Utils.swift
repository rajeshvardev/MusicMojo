//
//  Utils.swift
//  MusicMojo
//
//  Created by RAJESH SUKUMARAN on 10/17/16.
//  Copyright © 2016 RAJESH SUKUMARAN. All rights reserved.
//

import Foundation
import UIKit
class Utils: NSObject {
    static func getLocalisedString(key:String) -> String
    {
        let localisedString = NSLocalizedString(key, comment: "")
        return localisedString
    }
    static func showErrorAlert(controller:UIViewController)
    {
        let alert = UIAlertController(title: Utils.getLocalisedString(key: "Oops!"), message: Utils.getLocalisedString(key: "Somme Error Happened"), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
}
