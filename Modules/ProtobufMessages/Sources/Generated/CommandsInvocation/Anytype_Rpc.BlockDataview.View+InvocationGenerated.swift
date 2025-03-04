// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


extension Anytype_Rpc.BlockDataview.View.Create.Response: ResultWithError {}
extension Anytype_Rpc.BlockDataview.View.Create.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

extension Anytype_Rpc.BlockDataview.View.Delete.Response: ResultWithError {}
extension Anytype_Rpc.BlockDataview.View.Delete.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

extension Anytype_Rpc.BlockDataview.View.SetActive.Response: ResultWithError {}
extension Anytype_Rpc.BlockDataview.View.SetActive.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

extension Anytype_Rpc.BlockDataview.View.SetPosition.Response: ResultWithError {}
extension Anytype_Rpc.BlockDataview.View.SetPosition.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

extension Anytype_Rpc.BlockDataview.View.Update.Response: ResultWithError {}
extension Anytype_Rpc.BlockDataview.View.Update.Response.Error: ResponseError {
    public var isNull: Bool { code == .null && description_p.isEmpty }
}

