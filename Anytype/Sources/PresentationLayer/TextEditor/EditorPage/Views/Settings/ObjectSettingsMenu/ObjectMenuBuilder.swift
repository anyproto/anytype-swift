import Foundation

struct ObjectMenuBuilder {
    static func buildMenu(settings: [ObjectSetting], actions: [ObjectAction]) -> ObjectMenuConfiguration {
        let allItems = settings.map { (ObjectMenuSectionType.section(for: $0), ObjectMenuItem.setting($0)) } +
                       actions.map { (ObjectMenuSectionType.section(for: $0), ObjectMenuItem.action($0)) }
        let grouped = Dictionary(grouping: allItems, by: { $0.0 })

        var sections: [ObjectMenuSection] = []

        if let items = grouped[.horizontal]?.map({ $0.1 }), !items.isEmpty {
            sections.append(ObjectMenuSection(
                items: items.sorted { $0.order < $1.order },
                layout: .horizontal,
                showDividerBefore: false
            ))
        }

        if let items = grouped[.mainSettings]?.map({ $0.1 }), !items.isEmpty {
            sections.append(ObjectMenuSection(
                items: items.sorted { $0.order < $1.order },
                layout: .vertical,
                showDividerBefore: false
            ))
        }

        if let items = grouped[.objectActions]?.map({ $0.1 }), !items.isEmpty {
            sections.append(ObjectMenuSection(
                items: items.sorted { $0.order < $1.order },
                layout: .vertical,
                showDividerBefore: true
            ))
        }

        if let items = grouped[.management]?.map({ $0.1 }), !items.isEmpty {
            sections.append(ObjectMenuSection(
                items: items.sorted { $0.order < $1.order },
                layout: .vertical,
                showDividerBefore: true
            ))
        }

        if let items = grouped[.finalActions]?.map({ $0.1 }), !items.isEmpty {
            sections.append(ObjectMenuSection(
                items: items.sorted { $0.order < $1.order },
                layout: .vertical,
                showDividerBefore: true
            ))
        }

        return ObjectMenuConfiguration(sections: sections)
    }
}
