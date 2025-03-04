// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


extension Anytype_Rpc.ObjectType.Relation.Add.Response: ResultWithError {}
extension Anytype_Rpc.ObjectType.Relation.Add.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

extension Anytype_Rpc.ObjectType.Relation.Remove.Response: ResultWithError {}
extension Anytype_Rpc.ObjectType.Relation.Remove.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

