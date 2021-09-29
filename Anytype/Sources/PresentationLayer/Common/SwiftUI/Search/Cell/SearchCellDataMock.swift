final class SearchCellDataMock {
    static let data = [
        SearchCellData(
                id: "1",
                title: "Foooo",
                description: "Fooo",
                type: "type",
                icon: .todo(false)
        ),
        SearchCellData(
                id: "1",
                title: "Foooo",
                description: nil,
                type: "Type",
                icon: .todo(false)
        ),
        SearchCellData(
                id: "2",
                title: "Foooo",
                description: "Barr",
                type: "type",
                icon: .todo(false)
        ),
        SearchCellData(
            id: "3",
            title: "Bar",
            description: nil,
            type: "type",
            icon: .placeholder("B")
        )
    ]
}
