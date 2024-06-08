//
//  AlertContext.swift
//  file automation
//
//  Created by matthew hermans on 26/05/2024.
//

import Foundation

struct AlertItem: Equatable {
    let title: String
    let message: String
}

struct AlertContext {
    static let failedToSetupFolderMonitor = AlertItem(title: "Error occured while setting up folder monitor", message: "Please contact support if this keeps errors keeps happening")
    
    static let failedToStartMonitoring = AlertItem(title: "Error occured while starting to monitor downloads folder", message: "Please contact support if this keeps errors keeps happening")
    
    static let failedToMoveFile = AlertItem(title: "Error occured while moving the file to another folder", message: "Please contact support if this keeps errors keeps happening")
}
