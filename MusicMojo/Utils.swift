//
//  Utils.swift
//  MusicMojo
//
//  Created by RAJESH SUKUMARAN on 10/17/16.
//  Copyright © 2016 RAJESH SUKUMARAN. All rights reserved.
//

import Foundation
class Utils: NSObject {
    static func getLocalisedString(key:String) -> String
    {
        let localisedString = NSLocalizedString(key, comment: "")
        return localisedString
    }
}
