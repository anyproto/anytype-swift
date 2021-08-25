struct ObjectHeaderEmptyData: Hashable {
    let onTap: () -> ()
    
    func hash(into hasher: inout Hasher) { }
    static func == (lhs: ObjectHeaderEmptyData, rhs: ObjectHeaderEmptyData) -> Bool {
        return true
    }
}
