import Foundation

extension NewSearchView {
    
    enum ListModel {
        case plain(rows: [NewSearchRowConfiguration])
        case sectioned(sectinos: [NewSearchSectionConfiguration])
    }
    
}

extension NewSearchView.ListModel {
    
    var isEmpty: Bool {
        switch self {
        case .plain(let rows): return rows.isEmpty
        case .sectioned(let sections): return sections.isEmpty
        }
    }
    
}
