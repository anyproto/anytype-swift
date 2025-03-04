import Foundation
import ArgumentParser
import AnytypeSwiftFilesplit

@main
struct ServiceGeneratorCommand: ParsableCommand {

    @Option(name: .long, help: "Source path")
    private var path: String
    
    @Option(name: .long, help: "Output dir for folder")
    private var outputDir: String
    
    @Option(name: .long, help: "File name for other data")
    private var otherName: String
    
    func run() throws {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: outputDir) {
            try fileManager.removeItem(atPath: outputDir)
        }
        
        try fileManager.createDirectory(atPath: outputDir, withIntermediateDirectories: true, attributes: nil)
        
        let source = try String(contentsOfFile: path, encoding: .utf8)
        let parser = FileSplitrer(source: source, otherName: otherName)
        let results = parser.split()
        
        let outputUrl = URL(string: outputDir)!
        
        for result in results {
            try result.source.write(to: outputUrl.appending(path: result.fileName), atomically: true, encoding: .utf8)
        }
    }
}

