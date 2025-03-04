// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


extension Anytype_Rpc.Object.Import.Notion.ValidateToken.Response: ResultWithError {}
extension Anytype_Rpc.Object.Import.Notion.ValidateToken.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

extension Anytype_Rpc.Object.Import.Response: ResultWithError {}
extension Anytype_Rpc.Object.Import.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

