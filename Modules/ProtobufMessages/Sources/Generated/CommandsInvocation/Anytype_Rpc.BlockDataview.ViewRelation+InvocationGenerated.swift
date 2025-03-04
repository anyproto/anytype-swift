// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


extension Anytype_Rpc.BlockDataview.ViewRelation.Add.Response: ResultWithError {}
extension Anytype_Rpc.BlockDataview.ViewRelation.Add.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

extension Anytype_Rpc.BlockDataview.ViewRelation.Remove.Response: ResultWithError {}
extension Anytype_Rpc.BlockDataview.ViewRelation.Remove.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

extension Anytype_Rpc.BlockDataview.ViewRelation.Replace.Response: ResultWithError {}
extension Anytype_Rpc.BlockDataview.ViewRelation.Replace.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

extension Anytype_Rpc.BlockDataview.ViewRelation.Sort.Response: ResultWithError {}
extension Anytype_Rpc.BlockDataview.ViewRelation.Sort.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

