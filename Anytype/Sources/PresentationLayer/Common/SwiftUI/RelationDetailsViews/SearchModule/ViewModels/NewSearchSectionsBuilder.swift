import Foundation

final class NewSearchSectionsBuilder {
    
    static func makeSections<O: NewRelationOptionProtocol>(_ options: [O], rowsBuilder: ([O]) -> [NewSearchRowConfiguration]) -> [NewSearchSectionConfiguration] {
        var localOptions: [O] = []
        var otherOptions: [O] = []
        
        options.forEach {
            if $0.scope == .local {
                localOptions.append($0)
            } else {
                otherOptions.append($0)
            }
        }
        
        var sections: [NewSearchSectionConfiguration] = []
        
        if localOptions.isNotEmpty {
            sections.append(
                NewSearchSectionConfiguration(
                    id: "localOptionsSectionID",
                    title: "In this object".localized,
                    rows: rowsBuilder(localOptions)
                )
            )
        }
        
        if otherOptions.isNotEmpty {
            sections.append(
                NewSearchSectionConfiguration(
                    id: "otherOptionsSectionID",
                    title: "Everywhere".localized,
                    rows: rowsBuilder(otherOptions)
                )
            )
        }
        
        return sections
    }
    
}
