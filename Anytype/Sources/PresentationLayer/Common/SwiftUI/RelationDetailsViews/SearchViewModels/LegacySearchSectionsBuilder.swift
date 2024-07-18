import Foundation

final class LegacySearchSectionsBuilder {
    
    static func makeSections<Option>(_ options: [Option], rowsBuilder: ([Option]) -> [ListRowConfiguration]) -> [ListSectionConfiguration] {
        
        var sections: [ListSectionConfiguration] = []
        
        if options.isNotEmpty {
            sections.append(
                ListSectionConfiguration.smallHeader(
                    id: "otherOptionsSectionID",
                    title: Loc.everywhere,
                    rows: rowsBuilder(options)
                )
            )
        }
        
        return sections
    }
    
}
