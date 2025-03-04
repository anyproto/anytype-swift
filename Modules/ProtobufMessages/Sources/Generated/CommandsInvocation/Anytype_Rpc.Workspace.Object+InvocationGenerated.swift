// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


extension Anytype_Rpc.Workspace.Object.Add.Response: ResultWithError {}
extension Anytype_Rpc.Workspace.Object.Add.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

extension Anytype_Rpc.Workspace.Object.ListAdd.Response: ResultWithError {}
extension Anytype_Rpc.Workspace.Object.ListAdd.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

extension Anytype_Rpc.Workspace.Object.ListRemove.Response: ResultWithError {}
extension Anytype_Rpc.Workspace.Object.ListRemove.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

