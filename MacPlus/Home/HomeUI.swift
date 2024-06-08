//
//  HomeUI.swift
//  file automation
//
//  Created by matthew hermans on 06/06/2024.
//

import Foundation

enum HomeUI {
    enum Error {
        static let failedToSetupFolderMonitor = AlertItem(title: "Error occured while setting up folder monitor", message: "Please contact support if this keeps errors keeps happening")
    }
    enum keys {
        static let sortDownloads = "sortDownloads"
    }
    
    enum Labels {
        static let sortDownloads = "Sort Downloads"
        static let sortDownloadsExplanation = "This feature organizes your downloads folder by sorting your files into appropriate folders on your desktop based on their types."
    }
}
