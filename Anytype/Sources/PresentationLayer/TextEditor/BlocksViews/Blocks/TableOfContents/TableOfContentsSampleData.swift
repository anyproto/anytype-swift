import Foundation

struct TableOfContentsSampleData: Equatable {
    let title: String
    let children: [TableOfContentsSampleData]
}

extension TableOfContentsSampleData {
    static func sampleData() -> [TableOfContentsSampleData] {
        return [
            TableOfContentsSampleData(
                title: "Level 1",
                children: [
                    TableOfContentsSampleData(
                        title: "Level 1.1",
                        children: [
                            TableOfContentsSampleData(
                                title: "Level 1.1.1",
                                children: []
                            ),
                            TableOfContentsSampleData(
                                title: "Level 1.1.2",
                                children: []
                            )
                        ]
                    ),
                    TableOfContentsSampleData(
                        title: "Level 1.2",
                        children: []
                    )
                ]
            ),
            TableOfContentsSampleData(
                title: "Level 2 very long very long very long very long very long very long very long",
                children: [
                    TableOfContentsSampleData(
                        title: "Level 2.1 very long very long very long very long very long very long very long",
                        children: [
                            TableOfContentsSampleData(
                                title: "Level 2.1.1 very long very long very long very long very long very long very long",
                                children: []
                            )
                        ]
                    )
                ]
            )
        ]
    }
}
