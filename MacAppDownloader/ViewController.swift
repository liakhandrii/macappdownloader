//
//  ViewController.swift
//  MacAppDownloader
//
//  Created by Andrew Liakh on 7/10/18.
//  Copyright © 2018 Twopeople Software. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        let installationManager = InstallationManager()
        installationManager.installApp(progress: { (progress, message) in
            debugPrint("Progress: \(progress), message: \(message)")
        }) { (success) in
            debugPrint("Installed: \(success)")
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

