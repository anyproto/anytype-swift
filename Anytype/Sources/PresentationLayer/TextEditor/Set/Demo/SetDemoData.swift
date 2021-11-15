enum SetDemoData {
    static let colums: [String] = {
        (0...3).map { index -> [String] in
            ["Text", "Tag", "Status", "Date", "Attachement", "Object", "Checkbox", "Url", "Email"]
                .map { $0 + "\(index)" }
        }.flatMap { $0 }
    }()
    
    static let rows: [String] = {
        (0...10).map { index -> [String] in
            [ "Vova", "Sasha", "Johny", "Kostiq", "San4ous", "Den", "Chad", "Dimik", "R4Z0R", "T0xA"]
                .map { $0 + "\(index)" }
        }.flatMap { $0 }
    }()

}
