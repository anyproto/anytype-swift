import StoredHashMacro

@StoredHash
struct A: Hashable {
    let a: Int
    let b: String
    
    var c: Int {
        didSet { updateHash() }
    }
}
