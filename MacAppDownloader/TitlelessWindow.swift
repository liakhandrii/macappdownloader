//
//  TitlelessWindow.swift
//  MacAppDownloader
//
//  Created by Andrew Liakh on 7/11/18.
//  Copyright © 2018 Twopeople Software. All rights reserved.
//

import Cocoa

class TitlelessWindow: NSWindow {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.styleMask = [NSWindow.StyleMask.fullSizeContentView, .closable, .miniaturizable, .titled]
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
    }
    
}
