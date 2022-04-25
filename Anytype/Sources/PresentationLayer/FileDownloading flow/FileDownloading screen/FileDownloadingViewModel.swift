//
//  FileDownloadingViewModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 20.04.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import Combine
import AnytypeCore

final class FileDownloadingViewModel: NSObject, ObservableObject {
    
    @Published private(set) var bytesLoaded: Double = 0
    @Published private(set) var bytesExpected: Double = 0
    
    private weak var task: URLSessionDownloadTask?
    
    private weak var output: FileDownloadingModuleOutput?
    
    init(url: URL, output: FileDownloadingModuleOutput) {
        self.output = output
        
        super.init()
        
        self.downloadFileAt(url)
    }
    
    private func downloadFileAt(_ url: URL) {
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        let task = urlSession.downloadTask(with: url)
        self.task = task
        task.resume()
    }
    
}

// MARK: - URLSessionDownloadDelegate

extension FileDownloadingViewModel: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        // TODO: error handling
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // TODO: error handling
    }
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        handleDownloadTaskCompletion(url: location, response: downloadTask.response)
    }
    
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        self.bytesLoaded = Double(totalBytesWritten)
        self.bytesExpected = Double(totalBytesExpectedToWrite)
    }
    
}

// MARK: - Private extension

private extension FileDownloadingViewModel {
    
    private func handleDownloadTaskCompletion(url: URL, response: URLResponse?) {
        guard let response = response else {
            // TODO: error handling
            return
        }
        
        var localURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        
        if let suggestedFileName = response.suggestedFilename {
            localURL.appendPathComponent(suggestedFileName)
        }
        
        if FileManager.default.fileExists(atPath: localURL.relativePath) {
            try? FileManager.default.removeItem(at: localURL)
        }
        
        do {
            try FileManager.default.moveItem(at: url, to: localURL)
            output?.didDownloadFileTo(localURL)
        } catch {
            // TODO: error handling
            anytypeAssertionFailure(error.localizedDescription, domain: .fileLoader)
        }
    }
    
}
