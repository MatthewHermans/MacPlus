//
//  FileManagerMock.swift
//  MacPlusTest
//
//  Created by matthew hermans on 06/06/2024.
//

import Foundation

@testable import MacPlus

public class FileManagerMock: FileManager {
    private enum FileError: Error {
        case FileManagerMock
    }
    
    var files: [URL] = []
    public var shouldFail: Bool = false
    var paths: [URL] = []
    var movedFiles: [URL] = []
    
    public override func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?, options mask: FileManager.DirectoryEnumerationOptions = []) throws -> [URL] {
        files
    }
    
    public override func moveItem(at srcURL: URL, to dstURL: URL) throws {
        if shouldFail {
            throw FileError.FileManagerMock
        } else {
            movedFiles.append(dstURL)
        }
    }
    
    public override func fileExists(atPath path: String) -> Bool {
        movedFiles.contains(where: { $0.lastPathComponent == URL(string: path)!.lastPathComponent })
    }
    
    public override func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) throws {
        paths.append(URL(string: path)!)
    }
    
    public override func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        if shouldFail {
            if FileManager.SearchPathDirectory.downloadsDirectory == directory || FileManager.SearchPathDirectory.desktopDirectory == directory {
                return []
            } else {
                return super.urls(for: directory, in: domainMask)
            }
        } else {
            return super.urls(for: directory, in: domainMask)
        }
    }
}
