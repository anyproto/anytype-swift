import Services
import Foundation

extension BlockLatex {
    var canTryExtractUrl: Bool {
        processor.canTryExtractUrl
    }
}

extension BlockLatexProcessor {
    var icon: ImageAsset {
        switch self {
        case .latex: return .Embeds.latex
        case .mermaid: return .Embeds.mermaid
        case .chart: return .Embeds.chart
        case .youtube: return .Embeds.youtube
        case .vimeo: return .Embeds.vimeo
        case .soundcloud: return .Embeds.soundcloud
        case .googleMaps: return .Embeds.googleMaps
        case .miro: return .Embeds.miro
        case .figma: return .Embeds.figma
        case .twitter: return .Embeds.twitter
        case .openStreetMap: return .Embeds.openStreetMap
        case .reddit: return .Embeds.reddit
        case .facebook: return .Embeds.facebook
        case .instagram: return .Embeds.instagram
        case .telegram: return .Embeds.telegram
        case .githubGist: return .Embeds.githubGist
        case .codepen: return .Embeds.codepen
        case .bilibili: return .Embeds.bilibili
        case .excalidraw: return .Embeds.excalidraw
        case .kroki: return .Embeds.kroki
        case .graphviz: return .Embeds.graphviz
        case .sketchfab: return .Embeds.sketchfab
        case .image: return .Embeds.externalImage
        case .UNRECOGNIZED(_): return .Embeds.genericEmbedIcon
        }
    }
    
    var name: String {
        switch self {
        case .latex: return "LaTex"
        case .mermaid: return "Mermaid"
        case .chart: return "Chart"
        case .youtube: return "Youtube"
        case .vimeo: return "Vimeo"
        case .soundcloud: return "Soundcloud"
        case .googleMaps: return "Google Maps"
        case .miro: return "Miro"
        case .figma: return "Figma"
        case .twitter: return "Twitter"
        case .openStreetMap: return "OpenStreetMap"
        case .reddit: return "Reddit"
        case .facebook: return "Facebook"
        case .instagram: return "Instagram"
        case .telegram: return "Telegram"
        case .githubGist: return "Github Gist"
        case .codepen: return "Codepen"
        case .bilibili: return "Bilibili"
        case .excalidraw: return "Excalidraw"
        case .kroki: return "Kroki"
        case .graphviz: return "Graphviz"
        case .sketchfab: return "Sketchfab"
        case .image: return "External image"
        case .UNRECOGNIZED(_): return "Unrecognized"
        }
    }
    
    var canTryExtractUrl: Bool {
        switch self {
        case .latex, .mermaid, .chart, .googleMaps, .miro, .figma, .twitter, .instagram, .openStreetMap, .telegram, .image, .graphviz, .kroki, .codepen, .githubGist, .reddit, .UNRECOGNIZED(_): return false
        case .youtube, .vimeo, .soundcloud, .facebook, .sketchfab, .excalidraw, .bilibili: return true
        }
    }
}
