
/// Options specify what events from middleware you want to listen
struct TextBlockContentChangeListenerOptions: OptionSet {
    
    let rawValue: Int
    
    static let blockSetText = TextBlockContentChangeListenerOptions(rawValue: 1 << 0)
    static let blockSetAlign = TextBlockContentChangeListenerOptions(rawValue: 1 << 1)
    static let blockDelete = TextBlockContentChangeListenerOptions(rawValue: 1 << 2)
}
