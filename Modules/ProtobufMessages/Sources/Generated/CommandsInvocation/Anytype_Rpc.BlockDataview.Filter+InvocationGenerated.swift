// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


extension Anytype_Rpc.BlockDataview.Filter.Add.Response: ResultWithError {}
extension Anytype_Rpc.BlockDataview.Filter.Add.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

extension Anytype_Rpc.BlockDataview.Filter.Remove.Response: ResultWithError {}
extension Anytype_Rpc.BlockDataview.Filter.Remove.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

extension Anytype_Rpc.BlockDataview.Filter.Replace.Response: ResultWithError {}
extension Anytype_Rpc.BlockDataview.Filter.Replace.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

extension Anytype_Rpc.BlockDataview.Filter.Sort.Response: ResultWithError {}
extension Anytype_Rpc.BlockDataview.Filter.Sort.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

