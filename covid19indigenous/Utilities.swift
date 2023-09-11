//
//  Utilities.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 8/21/23.
//  Copyright © 2023 craigdietrich.com. All rights reserved.
//

import Foundation

func getHtmlPageExtension() -> String {
    var languageCodes:[String] = ["en", "fr"]
    var connector:String = "_"
    let languageCode = NSLocale.current.languageCode! as String
    if languageCodes.contains(languageCode) {
        return connector + languageCode
    }
    return connector + languageCodes[0]
}
