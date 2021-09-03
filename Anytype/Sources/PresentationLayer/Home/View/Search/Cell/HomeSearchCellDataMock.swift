final class HomeSearchCellDataMock {
    static let data = [
        HomeSearchCellData(
                id: "1",
                title: "Foooo",
                description: "Fooo",
                type: "type",
                icon: .todo(false)
        ),
        HomeSearchCellData(
                id: "1",
                title: "Foooo",
                description: nil,
                type: "Type",
                icon: .todo(false)
        ),
        HomeSearchCellData(
                id: "2",
                title: "Foooo",
                description: "Barr",
                type: "type",
                icon: .todo(false)
        ),
        HomeSearchCellData(
            id: "3",
            title: "Bar",
            description: nil,
            type: "type",
            icon: .placeholder("B")
        )
    ]
}
