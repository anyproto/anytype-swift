import Services
import Foundation

protocol EmbedContentDataBuilderProtocol: AnyObject {
    func build(from block: BlockLatex) -> EmbedContentData
}

final class EmbedContentDataBuilder: EmbedContentDataBuilderProtocol {
    
    func build(from block: BlockLatex) -> EmbedContentData {
        EmbedContentData(
            icon: block.processor.icon,
            processorName: block.processor.name,
            hasContent: block.text.isNotEmpty,
            url: url(from: block)
        )
    }
    
    private func url(from block: BlockLatex) -> URL? {
        if let url = URL(string: block.text),
           url.scheme.isNotNil,
           url.host.isNotNil
        {
            return url
        }
        
        if block.canTryExtractUrl,
           let urlString = extractUrlString(from: block.text),
           let url = URL(string: urlString)
        {
            return url
        }
        
        return nil
    }
    
    private func extractUrlString(from html: String) -> String? {
        let pattern = #"src="([^"]+)""#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsrange = NSRange(html.startIndex..<html.endIndex, in: html)
        
        if let match = regex?.firstMatch(in: html, options: [], range: nsrange),
           let range = Range(match.range(at: 1), in: html) {
            return String(html[range])
        }
        return nil
    }

}

extension Container {
    var embedContentDataBuilder: Factory<any EmbedContentDataBuilderProtocol> {
        self { EmbedContentDataBuilder() }
    }
}
