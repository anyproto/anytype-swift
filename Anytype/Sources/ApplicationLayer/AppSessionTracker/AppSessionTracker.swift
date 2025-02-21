import Foundation
import AnytypeCore
import Sentry

struct AppSessionReport {
    let reportPath: String
    let sessionFinished: Bool
}

protocol AppSessionTrackerProtocol: AnyObject {
    func startReportSession()
    func stopReportSession()
    var oldSessionReport: AppSessionReport? { get }
    var currentSessionReportPath: String { get }
}

final class AppSessionTracker: AppSessionTrackerProtocol {
    
    @UserDefault("session_report", defaultValue: "")
    private var fileName: String
    
    @UserDefault("last_session_finished", defaultValue: true)
    private var lastSessionFinished: Bool
    
    @UserDefault("last_session_is_debug", defaultValue: false)
    private var lastSessionIsDebug: Bool
    
    @Injected(\.stdOutFileStream)
    private var stdOutFileStream: any StdOutFileStreamProtocol
    
    var oldSessionReport: AppSessionReport?
    var currentSessionReportPath: String = ""
    
    init() {
        if fileName.isNotEmpty, !lastSessionIsDebug {
            oldSessionReport = AppSessionReport(
                reportPath: stdOutFileStream.folderURL.appendingPathComponent(fileName).path,
                sessionFinished: lastSessionFinished
            )
        }
        fileName = stdOutFileStream.fileName
        currentSessionReportPath = stdOutFileStream.folderURL.appendingPathComponent(stdOutFileStream.fileName).path
        
        lastSessionIsDebug = isDebuggerAttached()
    }
    
    func startReportSession() {
        lastSessionFinished = false
    }
    
    func stopReportSession() {
        lastSessionFinished = true
    }
    
    // MARK: - Private
    
    private func isDebuggerAttached() -> Bool {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]

        return mib.withUnsafeMutableBufferPointer { mibPtr in
            sysctl(mibPtr.baseAddress, 4, &info, &size, nil, 0) == 0 &&
            (info.kp_proc.p_flag & P_TRACED) != 0
        }
    }

}
