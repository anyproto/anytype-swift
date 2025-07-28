import Foundation
import Factory

protocol PublishedUrlBuilderProtocol {
    func buildPublishedUrl(domain: DomainType, customPath: String) -> URL?
}

struct PublishedUrlBuilder: PublishedUrlBuilderProtocol {
    
    func buildPublishedUrl(domain: DomainType, customPath: String) -> URL? {
        let domainUrl: String
        switch domain {
        case .paid(let url):
            domainUrl = url
        case .free(let url):
            domainUrl = url
        }
        
        // Parse the domain URL to separate host and existing path
        let domainComponents = domainUrl.components(separatedBy: "/")
        guard let host = domainComponents.first, !host.isEmpty else { return nil }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        
        // Build the full path: existing domain path + custom path
        var pathComponents: [String] = []
        
        // Add existing path from domain (everything after the first "/")
        if domainComponents.count > 1 {
            pathComponents.append(contentsOf: domainComponents.dropFirst())
        }
        
        // Add custom path if provided
        if !customPath.isEmpty {
            let cleanCustomPath = customPath.hasPrefix("/") ? String(customPath.dropFirst()) : customPath
            if !cleanCustomPath.isEmpty {
                pathComponents.append(cleanCustomPath)
            }
        }
        
        // Set the full path
        if !pathComponents.isEmpty {
            components.path = "/" + pathComponents.joined(separator: "/")
        }
        
        return components.url
    }
}

extension Container {
    var publishedUrlBuilder: Factory<any PublishedUrlBuilderProtocol> {
        self { PublishedUrlBuilder() }.shared
    }
}