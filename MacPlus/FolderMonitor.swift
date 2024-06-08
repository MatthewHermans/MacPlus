//
//  FolderMonitor.swift
//  file automation
//
//  Created by matthew hermans on 06/06/2024.
//

import Foundation

class FolderMonitor {
    // MARK: - Private properties
    private enum FileType {
        case video, music, image, numbers, pdf
    }
    
    enum FolderError: Error {
        case setupError
        case monitorError
    }
    
    /// File paths
    private let videoPath = "downloaded Videos"
    private let musicPath = "downloaded Music"
    private let imagePath = "downloaded Images"
    private let numbersPath = "downloaded Numbers"
    private let pdfPath = "downloaded pdfs"
    
    private let imageExtensions = ["jpg", "jpeg", "jpe", "jif", "jfif", "jfi", "png", "gif", "webp", "tiff", "tif", "psd", "raw", "arw", "cr2", "nrw", "k25", "bmp", "dib", "heif", "heic", "ind", "indd", "indt", "jp2", "j2k", "jpf", "jpf", "jpx", "jpm", "mj2", "svg", "svgz", "ai", "eps", "ico"]
    
    private let videoExtensions = ["webm", "mpg", "mp2", "mpeg", "mpe", "mpv", "ogg", "mp4", "mp4v", "m4v", "avi", "wmv", "mov", "qt", "flv", "swf", "avchd"]
    
    private let audioExtensions = ["m4a", "flac", "mp3", "wav", "wma", "aac"]
    
    private let numberExtensions = ["xls", "xlsx", "numbers"]
    
    private let documentExtensions = ["doc", "docx", "odt", "pdf", "ppt", "pptx", "pages"]
    
    /// A file descriptor for the monitored directory.
    private var monitoredFolderFileDescriptor: CInt
    /// A dispatch source to monitor a file descriptor created from the directory.
    private var folderMonitorSource: DispatchSourceFileSystemObject?
    /// A dispatch queue used for sending file changes in the directory.
    private let folderMonitorQueue = DispatchQueue(label: "FolderMonitorQueue", attributes: .concurrent)
    
    /// File manager
    private let fileManager: FileManager
    
    init(shouldStartSorting: Bool,
         fileManager: FileManager = FileManager.default,
         monitoredFolderFileDescriptor: CInt = -1) throws {
        self.monitoredFolderFileDescriptor = monitoredFolderFileDescriptor
        self.fileManager = fileManager
        try startupChecks(shouldStartSorting: shouldStartSorting)
        if shouldStartSorting {
            try startMonitoring()
        }
    }
    
    func startMonitoring() throws {
        guard folderMonitorSource == nil && monitoredFolderFileDescriptor == -1,
              let url = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            throw FolderError.monitorError
        }
        
        // Open the folder referenced by URL for monitoring only.
        monitoredFolderFileDescriptor = open(url.path, O_EVTONLY)
        
        // Ensure the file descriptor is valid.
        guard monitoredFolderFileDescriptor != -1 else {
            throw FolderError.monitorError
        }
        
        // Define a dispatch source monitoring the folder for additions, deletions, and renamings.
        folderMonitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: monitoredFolderFileDescriptor,
                                                                        eventMask: .write,
                                                                        queue: folderMonitorQueue)
        
        // Define the block to call when a file change is detected.
        folderMonitorSource?.setEventHandler { [weak self] in
            self?.folderDidChange()
        }
        
        // Define a cancel handler to ensure the directory is closed when the source is cancelled.
        folderMonitorSource?.setCancelHandler { [weak self] in
            guard let self = self else { return }
            close(self.monitoredFolderFileDescriptor)
            self.monitoredFolderFileDescriptor = -1
            self.folderMonitorSource = nil
        }
        
        // Start monitoring the directory via the source.
        folderMonitorSource?.resume()
        folderDidChange()
    }
    
    func stopMonitoring() {
        folderMonitorSource?.cancel()
        folderMonitorSource = nil
        monitoredFolderFileDescriptor = -1
    }
    
    private func folderDidChange() {
        guard let files = getFiles() else {
            return
        }
        
        for file in files {
            moveFileIfNeeded(file)
        }
    }
    
    private func startupChecks(shouldStartSorting: Bool) throws {
        // check if all folder are created if not create them
        guard let documentsDirectory = fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first else {
            throw FolderError.setupError
        }
        
        let folderNames = [musicPath, videoPath, imagePath, numbersPath, pdfPath]
        
        for folderName in folderNames {
            let folderPath = documentsDirectory
                .appendingPathComponent(folderName)
            
            if !fileManager.fileExists(atPath: folderPath.path) {
                try fileManager.createDirectory(
                    at: folderPath,
                    withIntermediateDirectories: true,
                    attributes: [:])
            }
        }
        
        // start sorting the files
        if shouldStartSorting {
            folderDidChange()
        }
    }
    
    func moveFileIfNeeded(_ file: URL) {
        if imageExtensions.contains(where: { $0.lowercased() == file.pathExtension.lowercased() }) {
            move(file: file, type: .image)
        } else if videoExtensions.contains(where: { $0.lowercased() == file.pathExtension.lowercased() }) {
            move(file: file, type: .video)
        } else if audioExtensions.contains(where: { $0.lowercased() == file.pathExtension.lowercased() }) {
            move(file: file, type: .music)
        } else if numberExtensions.contains(where: { $0.lowercased() == file.pathExtension.lowercased() }) {
            move(file: file, type: .numbers)
        } else if documentExtensions.contains(where: { $0.lowercased() == file.pathExtension.lowercased() }) {
            move(file: file, type: .pdf)
        }
    }
}

private extension FolderMonitor {
    func getFiles() -> [URL]? {
        do {
            let files = try fileManager.contentsOfDirectory(at: .downloadsDirectory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            return files
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func move(file: URL, type: FileType) {
        do {
            guard let basePath = fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first else {
                return
            }
            
            var destinationURL = switch type {
            case .video:
                basePath.appendingPathComponent(videoPath)
            case .music:
                basePath.appendingPathComponent(musicPath)
            case .image:
                basePath.appendingPathComponent(imagePath)
            case .numbers:
                basePath.appendingPathComponent(numbersPath)
            case .pdf:
                basePath.appendingPathComponent(pdfPath)
            }
            
            let suffix = generateSuffix(for: file, destinationFolder: destinationURL)
            destinationURL = generateURL(file: file, destinationFolder: destinationURL, counter: suffix)
            
            try fileManager.moveItem(at: file, to: destinationURL)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func generateSuffix(for file: URL, destinationFolder: URL) -> Int {
        var counter = 0
        var fileUrl = generateURL(file: file, destinationFolder: destinationFolder, counter: counter)
        
        while fileManager.fileExists(atPath: fileUrl.path(percentEncoded: false)) {
            counter += 1
            fileUrl = generateURL(file: file, destinationFolder: destinationFolder, counter: counter)
        }
        return counter
    }
    
    private func generateURL(file: URL, destinationFolder: URL, counter: Int) -> URL {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let dateString = formatter.string(from: .now).replacingOccurrences(of: "/", with: "-")
        
        let fileExtension = file.pathExtension
        
        return destinationFolder
            .appendingPathComponent(file.deletingPathExtension().lastPathComponent + "_\(dateString)_\(counter)")
            .appendingPathExtension(fileExtension)
    }
}
