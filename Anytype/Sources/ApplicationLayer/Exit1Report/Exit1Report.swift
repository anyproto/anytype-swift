import Foundation
import AnytypeCore
import Sentry

enum Exit1ReportError: Error {
    case exit1Error
}

final class Exit1Report {
    
    @UserDefault("session_report", defaultValue: "")
    private var fileName: String
    
    @UserDefault("last_session_finished", defaultValue: true)
    private var lastSessionFinished: Bool
    
    private let stdoutDuplicator = StdOutDuplicator()
    
    func startReportSession() {
        if !lastSessionFinished, fileName.isNotEmpty {
            
            let filePath = FileManager.default.temporaryDirectory.appendingPathComponent(fileName, isDirectory: false)
            let c = try? String(contentsOf: filePath, encoding: .utf8)
            let attachment = Attachment(
                path: FileManager.default.temporaryDirectory.path,
                filename: fileName,
                contentType: "text/plain"
            )
            
            SentrySDK.capture(error: Exit1ReportError.exit1Error) { scope in
                scope.addAttachment(attachment)
            }
        }
        
        fileName = UUID().uuidString + ".txt"
        
        let filePath = FileManager.default.temporaryDirectory.appendingPathComponent(fileName, isDirectory: false).path
        stdoutDuplicator.startDuplicatingOutputToFile(logFilePath: filePath)
        
        lastSessionFinished = false
    }
    
    func stopReportSession() {
        stdoutDuplicator.stopDuplicatingOutput()
        lastSessionFinished = true
    }
}
