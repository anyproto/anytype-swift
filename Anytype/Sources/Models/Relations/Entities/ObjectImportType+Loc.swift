import Foundation
import Services

extension ObjectImportType {
    var title: String? {
        switch self {
        case .notion: return Loc.Relation.ImportType.notion
        case .markdown: return Loc.Relation.ImportType.markdown
        case .pb: return Loc.Relation.ImportType.protobuf
        case .html: return Loc.Relation.ImportType.html
        case .txt: return Loc.Relation.ImportType.text
        case .csv: return Loc.Relation.ImportType.csv
        case .obsidian: return Loc.Relation.ImportType.obsidian
        case .external, .UNRECOGNIZED(_): return nil
        }
    }
}
