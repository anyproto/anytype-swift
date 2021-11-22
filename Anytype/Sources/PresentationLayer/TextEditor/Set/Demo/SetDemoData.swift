enum SetDemoData {    
    static let rows: [String] = {
        (0...10).map { index -> [String] in
            [ "Vova", "Sasha", "Johny", "Kostiq", "San4ous", "Den", "Chad", "Dimik", "R4Z0R", "T0xA"]
                .map { $0 + "\(index)" }
        }.flatMap { $0 }
    }()

}
