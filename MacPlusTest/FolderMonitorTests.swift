//
//  FolderMonitorTests.swift
//  MacPlusTest
//
//  Created by matthew hermans on 06/06/2024.
//

import XCTest
import Foundation

@testable import MacPlus

class FolderMonitorTests: XCTestCase {
    private var sut: FolderMonitor!
    private var fileManager: FileManagerMock!
    
    override func setUp() async throws {
        try await super.setUp()
        self.fileManager = FileManagerMock()
        self.sut = try FolderMonitor(shouldStartSorting: true, fileManager: fileManager)
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        fileManager = nil
    }
    
    // MARK: - startMonitoring()
    func testStartMonitoringFailsNoDesktopDirectory() throws {
        do {
            fileManager.shouldFail = true
            sut = try FolderMonitor(shouldStartSorting: true,
                                    fileManager: fileManager,
                                    monitoredFolderFileDescriptor: 0
            )
            XCTFail("Initialising folder monitor should fail")
        } catch {
            guard let error = error as? FolderMonitor.FolderError else {
                XCTFail("Should return a different error")
                return
            }
            XCTAssertEqual(error, FolderMonitor.FolderError.setupError)
        }
    }
    
    func testStartMonitoringFailsFolderFileDescriptorNotMin1() throws {
        do {
            sut = try FolderMonitor(shouldStartSorting: true,
                                    fileManager: fileManager,
                                    monitoredFolderFileDescriptor: 0
            )
            XCTFail("Initialising folder monitor should fail")
        } catch {
            guard let error = error as? FolderMonitor.FolderError else {
                XCTFail("Should return a different error")
                return
            }
            XCTAssertEqual(error, FolderMonitor.FolderError.monitorError)
        }
    }
    
    func testStartMonitoringFailsNoDownloadDirectory() throws {
        sut = try FolderMonitor(shouldStartSorting: false,
                                fileManager: fileManager)
        do {
            fileManager.shouldFail = true
            sut.stopMonitoring()
            try sut.startMonitoring()
            XCTFail("Initialising folder monitor should fail")
        } catch {}
    }
    
    // MARK: - DidChange
    
    func testFolderDidChange() throws {
        let imageFile = URL(fileURLWithPath: "/path/to/test.jpg")
        let pdfFile1 = URL(fileURLWithPath: "/path/to/test.pdf")
        let pdfFile2 = URL(fileURLWithPath: "/path/to/test.pdf")
        sut.stopMonitoring()
        
        fileManager.files = [imageFile, pdfFile1, pdfFile2]
        
        try sut.startMonitoring()
        
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let dateString = formatter.string(from: .now).replacingOccurrences(of: "/", with: "-")
        
        XCTAssertTrue(fileManager.movedFiles.contains(where: { $0.lastPathComponent == "test_\(dateString)_0.jpg"}))
        XCTAssertTrue(fileManager.movedFiles.contains(where: { $0.lastPathComponent == "test_\(dateString)_0.pdf"}))
        XCTAssertTrue(fileManager.movedFiles.contains(where: { $0.lastPathComponent == "test_\(dateString)_1.pdf"}))
    }
    
    func testFolderDidChangeNofFiles() throws {
        sut.stopMonitoring()
        
        fileManager.files = []
        
        try sut.startMonitoring()
        
        XCTAssertTrue(fileManager.movedFiles.isEmpty)
    }
    
    func testFolderDidChangeDiffrentKindOfFiles() throws {
        let imageFile = URL(fileURLWithPath: "/path/to/test.random")
        let pdfFile1 = URL(fileURLWithPath: "/path/to/test.random")
        let pdfFile2 = URL(fileURLWithPath: "/path/to/test.random")
        sut.stopMonitoring()
        
        fileManager.files = [imageFile, pdfFile1, pdfFile2]
        
        try sut.startMonitoring()
        
        XCTAssertTrue(fileManager.movedFiles.isEmpty)
    }
    
    func testMoveFileIfNeededNoDesktopDirectory() throws {
        let imageFile = URL(fileURLWithPath: "/path/to/test.jpg")
        fileManager.shouldFail = true
        sut.moveFileIfNeeded(imageFile)
        XCTAssertTrue(fileManager.movedFiles.isEmpty)
    }
}
