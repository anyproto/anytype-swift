import Foundation

final class StdOutDuplicator {
    
    private var logFileHandle: FileHandle?
    private var stdoutPipe: Pipe?
    private var stderrPipe: Pipe?
    private var started: Bool = false
    
    init() {}
    
    func startDuplicatingOutputToFile(logFilePath: String) {
    
        guard !started else { return }
        
            guard let logFile = fopen(logFilePath, "a") else {
                return
            }
//            
            let stdoutDescriptor = fileno(logFile)
////            let originalStdout = dup(STDOUT_FILENO)
////            let originalStderr = dup(STDERR_FILENO)
//
            dup2(stdoutDescriptor, STDOUT_FILENO)
            dup2(stdoutDescriptor, STDERR_FILENO)
        
//        FileManager.default.createFile(atPath: logFilePath, contents: nil)
//        guard let fileHandle = FileHandle(forWritingAtPath: logFilePath) ?? FileHandle(forUpdatingAtPath: logFilePath) else {
//            return
//        }
//        fileHandle.seekToEndOfFile()
//        logFileHandle = fileHandle
//
//        let originalStdout = dup(STDOUT_FILENO)
//        let originalStderr = dup(STDERR_FILENO)
//        
//        
//        let outPipe = Pipe()
//        stdoutPipe = outPipe
//        dup2(outPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
//
//        
//        let errPipe = Pipe()
//        stderrPipe = errPipe
//        dup2(errPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
//
//        
//        DispatchQueue.global(qos: .background).async {
//            while let data = try? outPipe.fileHandleForReading.read(upToCount: 4096),
//                    let output = String(data: data, encoding: .utf8) {
////                write(originalStdout, output, output.utf8.count)
//                fileHandle.write(data)
//                fileHandle.synchronizeFile()
//            }
//        }
//        
//        DispatchQueue.global(qos: .background).async {
//            while let data = try? errPipe.fileHandleForReading.read(upToCount: 4096),
//                    let output = String(data: data, encoding: .utf8) {
////                write(originalStderr, output, output.utf8.count)
//                fileHandle.write(data)
//                fileHandle.synchronizeFile()
//            }
//        }
        
        started = true
    }
    
    func stopDuplicatingOutput() {
        
        logFileHandle?.closeFile()
        logFileHandle = nil
        
        stdoutPipe?.fileHandleForReading.closeFile()
        stdoutPipe?.fileHandleForWriting.closeFile()
        stdoutPipe = nil

        stderrPipe?.fileHandleForReading.closeFile()
        stderrPipe?.fileHandleForWriting.closeFile()
        stderrPipe = nil
        
        started = false
    }
}
