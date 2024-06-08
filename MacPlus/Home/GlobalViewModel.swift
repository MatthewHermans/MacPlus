//
//  GlobalViewModel.swift
//  file automation
//
//  Created by matthew hermans on 22/05/2024.
//

import Foundation

final class GlobalViewModel: ObservableObject {
    @Published var sortDownloads: Bool = false {
        didSet {
            if sortDownloads {
                do {
                    try folderMonitor?.startMonitoring()
                    UserDefaults().setValue(sortDownloads, forKey: HomeUI.keys.sortDownloads)
                } catch {
                    self.alert = AlertContext.failedToStartMonitoring
                    sortDownloads = false
                }
            } else {
                folderMonitor?.stopMonitoring()
            }
        }
    }
    
    @Published var alert: AlertItem?
    
    private var folderMonitor: FolderMonitor?
    
    init() {
        do {
            sortDownloads = UserDefaults().bool(forKey: HomeUI.keys.sortDownloads)
            self.folderMonitor = try FolderMonitor(shouldStartSorting: sortDownloads)
        } catch {
            self.alert = HomeUI.Error.failedToSetupFolderMonitor
        }
    }
}
