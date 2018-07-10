//
//  String extension.swift
//  MacAppDownloader
//
//  Created by Andrew Liakh on 7/10/18.
//  Copyright © 2018 Twopeople Software. All rights reserved.
//

import Foundation

extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
}
