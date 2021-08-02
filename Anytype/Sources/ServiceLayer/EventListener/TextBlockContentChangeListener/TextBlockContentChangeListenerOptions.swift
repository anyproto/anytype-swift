
/// Options specify what events we want to listen
struct TextBlockContentChangeListenerOptions: OptionSet {
    
    let rawValue: Int
    
    static let blockSetText = TextBlockContentChangeListenerOptions(rawValue: 1 << 0)
    static let blockSetAlign = TextBlockContentChangeListenerOptions(rawValue: 1 << 1)
}
