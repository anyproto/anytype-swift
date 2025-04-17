import Foundation

protocol StdOutFileStreamProtocol: AnyObject {
    var folderURL: URL { get }
    var fileName: String { get }
}

#if RELEASE_ANYTYPE || DEBUG
final class StdOutFileStream: StdOutFileStreamProtocol {
    var folderURL: URL { FileManager.default.temporaryDirectory }
    var fileName: String { "" }
}
#else
final class StdOutFileStream: StdOutFileStreamProtocol {
    
    private let readQueue: DispatchQueue
    
    private let outPipe: Pipe
    private let errPipe: Pipe
    
    private let originalStdout: Int32
    private let originalStderr: Int32
    
    private let sourceOut: any DispatchSourceRead
    private let sourceErr: any DispatchSourceRead
    
    let folderURL = FileManager.default.temporaryDirectory
    let fileName: String
    
    init() {
        fileName = UUID().uuidString + ".txt"
        
        let logFilePath = FileManager.default.temporaryDirectory.appendingPathComponent(fileName, isDirectory: false).path
        
        FileManager.default.createFile(atPath: logFilePath, contents: nil)
        let fileHandle = FileHandle(forWritingAtPath: logFilePath)

        fileHandle?.write(Data("test data".utf8))
        
        let originalStdout = dup(STDOUT_FILENO)
        let originalStderr = dup(STDERR_FILENO)
        
        let outPipe = Pipe()
        dup2(outPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)

        let errPipe = Pipe()
        dup2(errPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
        
        readQueue = DispatchQueue(
            label: "io.anytype.stdout",
            // It's OK. StdOutFileStream works only in test builds.
            // Tihs proprity probably guarantee that all logs will be write before the crash.
            qos: .userInteractive,
            attributes: .concurrent
        )
        
        sourceOut = DispatchSource.makeReadSource(
            fileDescriptor: outPipe.fileHandleForReading.fileDescriptor,
            queue: readQueue
        )

        sourceErr = DispatchSource.makeReadSource(
            fileDescriptor: errPipe.fileHandleForReading.fileDescriptor,
            queue: readQueue
        )
        
        sourceOut.setEventHandler {
            let data = outPipe.fileHandleForReading.availableData
            if let output = String(data: data, encoding: .utf8) {
                write(originalStdout, output, output.utf8.count)
            }
            fileHandle?.write(data)
        }

        sourceErr.setEventHandler {
            let data = errPipe.fileHandleForReading.availableData
            if let output = String(data: data, encoding: .utf8) {
                write(originalStderr, output, output.utf8.count)
            }
            fileHandle?.write(data)
        }
        
        sourceOut.resume()
        sourceErr.resume()
        
        self.originalStderr = originalStderr
        self.originalStdout = originalStdout
        
        self.outPipe = outPipe
        self.errPipe = errPipe
    }
}
#endif
