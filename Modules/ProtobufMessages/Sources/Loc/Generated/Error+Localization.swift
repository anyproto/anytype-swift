// Generated using Sourcery 2.2.6 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation

extension Anytype_Rpc.AI.Autofill.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "AI.Autofill.badInput")
            case .rateLimitExceeded:
                return LocHelper.tr(table: "LocalizableError", key: "AI.Autofill.rateLimitExceeded")
            case .endpointNotReachable:
                return LocHelper.tr(table: "LocalizableError", key: "AI.Autofill.endpointNotReachable")
            case .modelNotFound:
                return LocHelper.tr(table: "LocalizableError", key: "AI.Autofill.modelNotFound")
            case .authRequired:
                return LocHelper.tr(table: "LocalizableError", key: "AI.Autofill.authRequired")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.AI.ListSummary.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "AI.ListSummary.badInput")
            case .rateLimitExceeded:
                return LocHelper.tr(table: "LocalizableError", key: "AI.ListSummary.rateLimitExceeded")
            case .endpointNotReachable:
                return LocHelper.tr(table: "LocalizableError", key: "AI.ListSummary.endpointNotReachable")
            case .modelNotFound:
                return LocHelper.tr(table: "LocalizableError", key: "AI.ListSummary.modelNotFound")
            case .authRequired:
                return LocHelper.tr(table: "LocalizableError", key: "AI.ListSummary.authRequired")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.AI.ObjectCreateFromUrl.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "AI.ObjectCreateFromUrl.badInput")
            case .rateLimitExceeded:
                return LocHelper.tr(table: "LocalizableError", key: "AI.ObjectCreateFromUrl.rateLimitExceeded")
            case .endpointNotReachable:
                return LocHelper.tr(table: "LocalizableError", key: "AI.ObjectCreateFromUrl.endpointNotReachable")
            case .modelNotFound:
                return LocHelper.tr(table: "LocalizableError", key: "AI.ObjectCreateFromUrl.modelNotFound")
            case .authRequired:
                return LocHelper.tr(table: "LocalizableError", key: "AI.ObjectCreateFromUrl.authRequired")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.AI.WritingTools.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "AI.WritingTools.badInput")
            case .rateLimitExceeded:
                return LocHelper.tr(table: "LocalizableError", key: "AI.WritingTools.rateLimitExceeded")
            case .endpointNotReachable:
                return LocHelper.tr(table: "LocalizableError", key: "AI.WritingTools.endpointNotReachable")
            case .modelNotFound:
                return LocHelper.tr(table: "LocalizableError", key: "AI.WritingTools.modelNotFound")
            case .authRequired:
                return LocHelper.tr(table: "LocalizableError", key: "AI.WritingTools.authRequired")
            case .languageNotSupported:
                return LocHelper.tr(table: "LocalizableError", key: "AI.WritingTools.languageNotSupported")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Account.ChangeJsonApiAddr.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Account.ChangeJsonApiAddr.badInput")
            case .accountIsNotRunning:
                return LocHelper.tr(table: "LocalizableError", key: "Account.ChangeJsonApiAddr.accountIsNotRunning")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Account.ChangeNetworkConfigAndRestart.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Account.ChangeNetworkConfigAndRestart.badInput")
            case .accountIsNotRunning:
                return LocHelper.tr(table: "LocalizableError", key: "Account.ChangeNetworkConfigAndRestart.accountIsNotRunning")
            case .accountFailedToStop:
                return LocHelper.tr(table: "LocalizableError", key: "Account.ChangeNetworkConfigAndRestart.accountFailedToStop")
            case .configFileNotFound:
                return LocHelper.tr(table: "LocalizableError", key: "Account.ChangeNetworkConfigAndRestart.configFileNotFound")
            case .configFileInvalid:
                return LocHelper.tr(table: "LocalizableError", key: "Account.ChangeNetworkConfigAndRestart.configFileInvalid")
            case .configFileNetworkIDMismatch:
                return LocHelper.tr(table: "LocalizableError", key: "Account.ChangeNetworkConfigAndRestart.configFileNetworkIDMismatch")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Account.ConfigUpdate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Account.ConfigUpdate.badInput")
            case .accountIsNotRunning:
                return LocHelper.tr(table: "LocalizableError", key: "Account.ConfigUpdate.accountIsNotRunning")
            case .failedToWriteConfig:
                return LocHelper.tr(table: "LocalizableError", key: "Account.ConfigUpdate.failedToWriteConfig")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Account.Create.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Create.badInput")
            case .accountCreatedButFailedToStartNode:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Create.accountCreatedButFailedToStartNode")
            case .accountCreatedButFailedToSetName:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Create.accountCreatedButFailedToSetName")
            case .failedToStopRunningNode:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Create.failedToStopRunningNode")
            case .failedToWriteConfig:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Create.failedToWriteConfig")
            case .failedToCreateLocalRepo:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Create.failedToCreateLocalRepo")
            case .accountCreationIsCanceled:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Create.accountCreationIsCanceled")
            case .configFileNotFound:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Create.configFileNotFound")
            case .configFileInvalid:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Create.configFileInvalid")
            case .configFileNetworkIDMismatch:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Create.configFileNetworkIDMismatch")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Account.Delete.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Delete.badInput")
            case .accountIsAlreadyDeleted:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Delete.accountIsAlreadyDeleted")
            case .unableToConnect:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Delete.unableToConnect")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Account.EnableLocalNetworkSync.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Account.EnableLocalNetworkSync.badInput")
            case .accountIsNotRunning:
                return LocHelper.tr(table: "LocalizableError", key: "Account.EnableLocalNetworkSync.accountIsNotRunning")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Account.LocalLink.CreateApp.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Account.LocalLink.CreateApp.badInput")
            case .accountIsNotRunning:
                return LocHelper.tr(table: "LocalizableError", key: "Account.LocalLink.CreateApp.accountIsNotRunning")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Account.LocalLink.ListApps.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Account.LocalLink.ListApps.badInput")
            case .accountIsNotRunning:
                return LocHelper.tr(table: "LocalizableError", key: "Account.LocalLink.ListApps.accountIsNotRunning")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Account.LocalLink.NewChallenge.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Account.LocalLink.NewChallenge.badInput")
            case .accountIsNotRunning:
                return LocHelper.tr(table: "LocalizableError", key: "Account.LocalLink.NewChallenge.accountIsNotRunning")
            case .tooManyRequests:
                return LocHelper.tr(table: "LocalizableError", key: "Account.LocalLink.NewChallenge.tooManyRequests")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Account.LocalLink.RevokeApp.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Account.LocalLink.RevokeApp.badInput")
            case .notFound:
                return LocHelper.tr(table: "LocalizableError", key: "Account.LocalLink.RevokeApp.notFound")
            case .accountIsNotRunning:
                return LocHelper.tr(table: "LocalizableError", key: "Account.LocalLink.RevokeApp.accountIsNotRunning")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Account.LocalLink.SolveChallenge.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Account.LocalLink.SolveChallenge.badInput")
            case .accountIsNotRunning:
                return LocHelper.tr(table: "LocalizableError", key: "Account.LocalLink.SolveChallenge.accountIsNotRunning")
            case .invalidChallengeID:
                return LocHelper.tr(table: "LocalizableError", key: "Account.LocalLink.SolveChallenge.invalidChallengeID")
            case .challengeAttemptsExceeded:
                return LocHelper.tr(table: "LocalizableError", key: "Account.LocalLink.SolveChallenge.challengeAttemptsExceeded")
            case .incorrectAnswer:
                return LocHelper.tr(table: "LocalizableError", key: "Account.LocalLink.SolveChallenge.incorrectAnswer")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Account.Migrate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Migrate.badInput")
            case .accountNotFound:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Migrate.accountNotFound")
            case .canceled:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Migrate.canceled")
            case .notEnoughFreeSpace:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Migrate.notEnoughFreeSpace")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Account.MigrateCancel.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Account.MigrateCancel.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Account.Move.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Move.badInput")
            case .failedToStopNode:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Move.failedToStopNode")
            case .failedToIdentifyAccountDir:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Move.failedToIdentifyAccountDir")
            case .failedToRemoveAccountData:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Move.failedToRemoveAccountData")
            case .failedToCreateLocalRepo:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Move.failedToCreateLocalRepo")
            case .failedToWriteConfig:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Move.failedToWriteConfig")
            case .failedToGetConfig:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Move.failedToGetConfig")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Account.Recover.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Recover.badInput")
            case .needToRecoverWalletFirst:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Recover.needToRecoverWalletFirst")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Account.RecoverFromLegacyExport.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Account.RecoverFromLegacyExport.badInput")
            case .differentAccount:
                return LocHelper.tr(table: "LocalizableError", key: "Account.RecoverFromLegacyExport.differentAccount")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Account.RevertDeletion.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Account.RevertDeletion.badInput")
            case .accountIsActive:
                return LocHelper.tr(table: "LocalizableError", key: "Account.RevertDeletion.accountIsActive")
            case .unableToConnect:
                return LocHelper.tr(table: "LocalizableError", key: "Account.RevertDeletion.unableToConnect")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Account.Select.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Select.badInput")
            case .failedToCreateLocalRepo:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Select.failedToCreateLocalRepo")
            case .localRepoExistsButCorrupted:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Select.localRepoExistsButCorrupted")
            case .failedToRunNode:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Select.failedToRunNode")
            case .failedToFindAccountInfo:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Select.failedToFindAccountInfo")
            case .localRepoNotExistsAndMnemonicNotSet:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Select.localRepoNotExistsAndMnemonicNotSet")
            case .failedToStopSearcherNode:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Select.failedToStopSearcherNode")
            case .anotherAnytypeProcessIsRunning:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Select.anotherAnytypeProcessIsRunning")
            case .failedToFetchRemoteNodeHasIncompatibleProtoVersion:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Select.failedToFetchRemoteNodeHasIncompatibleProtoVersion")
            case .accountIsDeleted:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Select.accountIsDeleted")
            case .accountLoadIsCanceled:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Select.accountLoadIsCanceled")
            case .accountStoreNotMigrated:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Select.accountStoreNotMigrated")
            case .configFileNotFound:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Select.configFileNotFound")
            case .configFileInvalid:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Select.configFileInvalid")
            case .configFileNetworkIDMismatch:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Select.configFileNetworkIDMismatch")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Account.Stop.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Stop.badInput")
            case .accountIsNotRunning:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Stop.accountIsNotRunning")
            case .failedToStopNode:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Stop.failedToStopNode")
            case .failedToRemoveAccountData:
                return LocHelper.tr(table: "LocalizableError", key: "Account.Stop.failedToRemoveAccountData")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.App.GetVersion.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "App.GetVersion.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.App.SetDeviceState.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "App.SetDeviceState.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.App.Shutdown.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "App.Shutdown.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.Copy.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.Copy.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.Create.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.Create.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.CreateWidget.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.CreateWidget.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.Cut.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.Cut.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.Download.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.Download.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.Export.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.Export.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.ListConvertToObjects.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.ListConvertToObjects.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.ListDelete.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.ListDelete.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.ListDuplicate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.ListDuplicate.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.ListMoveToExistingObject.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.ListMoveToExistingObject.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.ListMoveToNewObject.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.ListMoveToNewObject.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.ListSetAlign.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.ListSetAlign.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.ListSetBackgroundColor.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.ListSetBackgroundColor.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.ListSetFields.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.ListSetFields.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.ListSetVerticalAlign.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.ListSetVerticalAlign.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.ListTurnInto.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.ListTurnInto.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.Merge.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.Merge.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.Paste.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.Paste.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.Preview.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.Preview.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.Replace.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.Replace.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.SetCarriage.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.SetCarriage.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.SetFields.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.SetFields.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.Split.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.Split.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Block.Upload.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Block.Upload.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockBookmark.CreateAndFetch.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockBookmark.CreateAndFetch.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockBookmark.Fetch.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockBookmark.Fetch.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.CreateFromExistingObject.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.CreateFromExistingObject.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Filter.Add.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.Filter.Add.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Filter.Remove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.Filter.Remove.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Filter.Replace.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.Filter.Replace.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Filter.Sort.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.Filter.Sort.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.GroupOrder.Update.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.GroupOrder.Update.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.ObjectOrder.Move.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.ObjectOrder.Move.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.ObjectOrder.Update.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.ObjectOrder.Update.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Relation.Add.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.Relation.Add.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Relation.Delete.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.Relation.Delete.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Relation.Set.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.Relation.Set.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.SetSource.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.SetSource.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Sort.Add.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.Sort.Add.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Sort.Remove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.Sort.Remove.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Sort.Replace.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.Sort.Replace.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.Sort.SSort.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.Sort.SSort.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.View.Create.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.View.Create.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.View.Delete.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.View.Delete.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.View.SetActive.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.View.SetActive.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.View.SetPosition.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.View.SetPosition.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.View.Update.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.View.Update.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.ViewRelation.Add.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.ViewRelation.Add.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.ViewRelation.Remove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.ViewRelation.Remove.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.ViewRelation.Replace.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.ViewRelation.Replace.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDataview.ViewRelation.Sort.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDataview.ViewRelation.Sort.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockDiv.ListSetStyle.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockDiv.ListSetStyle.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockFile.CreateAndUpload.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockFile.CreateAndUpload.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockFile.ListSetStyle.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockFile.ListSetStyle.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockFile.SetName.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockFile.SetName.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockFile.SetTargetObjectId.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockFile.SetTargetObjectId.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockImage.SetName.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockImage.SetName.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockImage.SetWidth.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockImage.SetWidth.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockLatex.SetProcessor.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockLatex.SetProcessor.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockLatex.SetText.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockLatex.SetText.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockLink.CreateWithObject.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockLink.CreateWithObject.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockLink.ListSetAppearance.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockLink.ListSetAppearance.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockRelation.Add.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockRelation.Add.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockRelation.SetKey.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockRelation.SetKey.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockTable.ColumnCreate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockTable.ColumnCreate.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockTable.ColumnDelete.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockTable.ColumnDelete.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockTable.ColumnDuplicate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockTable.ColumnDuplicate.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockTable.ColumnListFill.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockTable.ColumnListFill.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockTable.ColumnMove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockTable.ColumnMove.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockTable.Create.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockTable.Create.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockTable.Expand.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockTable.Expand.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockTable.RowCreate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockTable.RowCreate.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockTable.RowDelete.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockTable.RowDelete.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockTable.RowDuplicate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockTable.RowDuplicate.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockTable.RowListClean.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockTable.RowListClean.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockTable.RowListFill.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockTable.RowListFill.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockTable.RowSetHeader.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockTable.RowSetHeader.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockTable.Sort.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockTable.Sort.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockText.ListClearContent.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockText.ListClearContent.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockText.ListClearStyle.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockText.ListClearStyle.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockText.ListSetColor.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockText.ListSetColor.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockText.ListSetMark.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockText.ListSetMark.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockText.ListSetStyle.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockText.ListSetStyle.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockText.SetChecked.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockText.SetChecked.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockText.SetColor.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockText.SetColor.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockText.SetIcon.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockText.SetIcon.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockText.SetMarks.Get.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockText.SetMarks.Get.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockText.SetStyle.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockText.SetStyle.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockText.SetText.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockText.SetText.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockVideo.SetName.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockVideo.SetName.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockVideo.SetWidth.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockVideo.SetWidth.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockWidget.SetLayout.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockWidget.SetLayout.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockWidget.SetLimit.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockWidget.SetLimit.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockWidget.SetTargetId.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockWidget.SetTargetId.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.BlockWidget.SetViewId.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "BlockWidget.SetViewId.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Broadcast.PayloadEvent.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Broadcast.PayloadEvent.badInput")
            case .internalError:
                return LocHelper.tr(table: "LocalizableError", key: "Broadcast.PayloadEvent.internalError")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Chat.AddMessage.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Chat.AddMessage.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Chat.DeleteMessage.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Chat.DeleteMessage.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Chat.EditMessageContent.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Chat.EditMessageContent.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Chat.GetMessages.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Chat.GetMessages.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Chat.GetMessagesByIds.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Chat.GetMessagesByIds.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Chat.ReadAll.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Chat.ReadAll.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Chat.ReadMessages.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Chat.ReadMessages.badInput")
            case .messagesNotFound:
                return LocHelper.tr(table: "LocalizableError", key: "Chat.ReadMessages.messagesNotFound")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Chat.SubscribeLastMessages.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Chat.SubscribeLastMessages.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Chat.SubscribeToMessagePreviews.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Chat.ToggleMessageReaction.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Chat.ToggleMessageReaction.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Chat.Unread.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Chat.Unread.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Chat.Unsubscribe.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Chat.Unsubscribe.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Chat.UnsubscribeFromMessagePreviews.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Chat.UnsubscribeFromMessagePreviews.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Debug.AccountSelectTrace.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Debug.AccountSelectTrace.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Debug.AnystoreObjectChanges.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Debug.AnystoreObjectChanges.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Debug.ExportLocalstore.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Debug.ExportLocalstore.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Debug.ExportLog.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Debug.ExportLog.badInput")
            case .noFolder:
                return LocHelper.tr(table: "LocalizableError", key: "Debug.ExportLog.noFolder")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Debug.NetCheck.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Debug.NetCheck.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Debug.OpenedObjects.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Debug.OpenedObjects.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Debug.Ping.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Debug.Ping.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Debug.RunProfiler.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Debug.RunProfiler.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Debug.SpaceSummary.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Debug.SpaceSummary.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Debug.StackGoroutines.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Debug.StackGoroutines.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Debug.Stat.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Debug.Stat.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Debug.Subscriptions.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Debug.Subscriptions.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Debug.Tree.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Debug.Tree.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Debug.TreeHeads.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Debug.TreeHeads.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Device.List.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Device.List.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Device.NetworkState.Set.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Device.NetworkState.Set.badInput")
            case .internalError:
                return LocHelper.tr(table: "LocalizableError", key: "Device.NetworkState.Set.internalError")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Device.SetName.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Device.SetName.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.File.Download.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "File.Download.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.File.Drop.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "File.Drop.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.File.ListOffload.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "File.ListOffload.badInput")
            case .nodeNotStarted:
                return LocHelper.tr(table: "LocalizableError", key: "File.ListOffload.nodeNotStarted")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.File.NodeUsage.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "File.NodeUsage.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.File.Offload.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "File.Offload.badInput")
            case .nodeNotStarted:
                return LocHelper.tr(table: "LocalizableError", key: "File.Offload.nodeNotStarted")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.File.Reconcile.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "File.Reconcile.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.File.SpaceOffload.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "File.SpaceOffload.badInput")
            case .nodeNotStarted:
                return LocHelper.tr(table: "LocalizableError", key: "File.SpaceOffload.nodeNotStarted")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.File.SpaceUsage.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "File.SpaceUsage.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.File.Upload.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "File.Upload.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Gallery.DownloadIndex.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Gallery.DownloadIndex.badInput")
            case .unmarshallingError:
                return LocHelper.tr(table: "LocalizableError", key: "Gallery.DownloadIndex.unmarshallingError")
            case .downloadError:
                return LocHelper.tr(table: "LocalizableError", key: "Gallery.DownloadIndex.downloadError")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Gallery.DownloadManifest.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Gallery.DownloadManifest.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.GenericErrorResponse.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "GenericErrorResponse.Error.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.History.DiffVersions.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "History.DiffVersions.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.History.GetVersions.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "History.GetVersions.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.History.SetVersion.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "History.SetVersion.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.History.ShowVersion.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "History.ShowVersion.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Initial.SetParameters.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Initial.SetParameters.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.LinkPreview.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "LinkPreview.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Log.Send.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Log.Send.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Membership.CodeGetInfo.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.CodeGetInfo.badInput")
            case .notLoggedIn:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.CodeGetInfo.notLoggedIn")
            case .paymentNodeError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.CodeGetInfo.paymentNodeError")
            case .notFound:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.CodeGetInfo.notFound")
            case .alreadyUsed:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.CodeGetInfo.alreadyUsed")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Membership.CodeRedeem.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.CodeRedeem.badInput")
            case .notLoggedIn:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.CodeRedeem.notLoggedIn")
            case .paymentNodeError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.CodeRedeem.paymentNodeError")
            case .notFound:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.CodeRedeem.notFound")
            case .alreadyUsed:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.CodeRedeem.alreadyUsed")
            case .badAnyname:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.CodeRedeem.badAnyname")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Membership.Finalize.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.Finalize.badInput")
            case .notLoggedIn:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.Finalize.notLoggedIn")
            case .paymentNodeError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.Finalize.paymentNodeError")
            case .cacheError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.Finalize.cacheError")
            case .membershipNotFound:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.Finalize.membershipNotFound")
            case .membershipWrongState:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.Finalize.membershipWrongState")
            case .badAnyname:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.Finalize.badAnyname")
            case .canNotConnect:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.Finalize.canNotConnect")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Membership.GetPortalLinkUrl.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetPortalLinkUrl.badInput")
            case .notLoggedIn:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetPortalLinkUrl.notLoggedIn")
            case .paymentNodeError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetPortalLinkUrl.paymentNodeError")
            case .cacheError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetPortalLinkUrl.cacheError")
            case .canNotConnect:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetPortalLinkUrl.canNotConnect")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Membership.GetStatus.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetStatus.badInput")
            case .notLoggedIn:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetStatus.notLoggedIn")
            case .paymentNodeError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetStatus.paymentNodeError")
            case .cacheError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetStatus.cacheError")
            case .membershipNotFound:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetStatus.membershipNotFound")
            case .membershipWrongState:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetStatus.membershipWrongState")
            case .canNotConnect:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetStatus.canNotConnect")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Membership.GetTiers.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetTiers.badInput")
            case .notLoggedIn:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetTiers.notLoggedIn")
            case .paymentNodeError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetTiers.paymentNodeError")
            case .cacheError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetTiers.cacheError")
            case .canNotConnect:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetTiers.canNotConnect")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Membership.GetVerificationEmail.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetVerificationEmail.badInput")
            case .notLoggedIn:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetVerificationEmail.notLoggedIn")
            case .paymentNodeError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetVerificationEmail.paymentNodeError")
            case .cacheError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetVerificationEmail.cacheError")
            case .emailWrongFormat:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetVerificationEmail.emailWrongFormat")
            case .emailAlreadyVerified:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetVerificationEmail.emailAlreadyVerified")
            case .emailAlredySent:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetVerificationEmail.emailAlredySent")
            case .emailFailedToSend:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetVerificationEmail.emailFailedToSend")
            case .membershipAlreadyExists:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetVerificationEmail.membershipAlreadyExists")
            case .canNotConnect:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetVerificationEmail.canNotConnect")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Membership.GetVerificationEmailStatus.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetVerificationEmailStatus.badInput")
            case .notLoggedIn:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetVerificationEmailStatus.notLoggedIn")
            case .paymentNodeError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetVerificationEmailStatus.paymentNodeError")
            case .canNotConnect:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.GetVerificationEmailStatus.canNotConnect")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Membership.IsNameValid.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.IsNameValid.badInput")
            case .tooShort:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.IsNameValid.tooShort")
            case .tooLong:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.IsNameValid.tooLong")
            case .hasInvalidChars:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.IsNameValid.hasInvalidChars")
            case .tierFeaturesNoName:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.IsNameValid.tierFeaturesNoName")
            case .tierNotFound:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.IsNameValid.tierNotFound")
            case .notLoggedIn:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.IsNameValid.notLoggedIn")
            case .paymentNodeError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.IsNameValid.paymentNodeError")
            case .cacheError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.IsNameValid.cacheError")
            case .canNotReserve:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.IsNameValid.canNotReserve")
            case .canNotConnect:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.IsNameValid.canNotConnect")
            case .nameIsReserved:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.IsNameValid.nameIsReserved")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Membership.RegisterPaymentRequest.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.RegisterPaymentRequest.badInput")
            case .notLoggedIn:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.RegisterPaymentRequest.notLoggedIn")
            case .paymentNodeError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.RegisterPaymentRequest.paymentNodeError")
            case .cacheError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.RegisterPaymentRequest.cacheError")
            case .tierNotFound:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.RegisterPaymentRequest.tierNotFound")
            case .tierInvalid:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.RegisterPaymentRequest.tierInvalid")
            case .paymentMethodInvalid:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.RegisterPaymentRequest.paymentMethodInvalid")
            case .badAnyname:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.RegisterPaymentRequest.badAnyname")
            case .membershipAlreadyExists:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.RegisterPaymentRequest.membershipAlreadyExists")
            case .canNotConnect:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.RegisterPaymentRequest.canNotConnect")
            case .emailWrongFormat:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.RegisterPaymentRequest.emailWrongFormat")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Membership.VerifyAppStoreReceipt.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.VerifyAppStoreReceipt.badInput")
            case .notLoggedIn:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.VerifyAppStoreReceipt.notLoggedIn")
            case .paymentNodeError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.VerifyAppStoreReceipt.paymentNodeError")
            case .cacheError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.VerifyAppStoreReceipt.cacheError")
            case .invalidReceipt:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.VerifyAppStoreReceipt.invalidReceipt")
            case .purchaseRegistrationError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.VerifyAppStoreReceipt.purchaseRegistrationError")
            case .subscriptionRenewError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.VerifyAppStoreReceipt.subscriptionRenewError")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Membership.VerifyEmailCode.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.VerifyEmailCode.badInput")
            case .notLoggedIn:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.VerifyEmailCode.notLoggedIn")
            case .paymentNodeError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.VerifyEmailCode.paymentNodeError")
            case .cacheError:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.VerifyEmailCode.cacheError")
            case .emailAlreadyVerified:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.VerifyEmailCode.emailAlreadyVerified")
            case .expired:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.VerifyEmailCode.expired")
            case .wrong:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.VerifyEmailCode.wrong")
            case .membershipNotFound:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.VerifyEmailCode.membershipNotFound")
            case .membershipAlreadyActive:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.VerifyEmailCode.membershipAlreadyActive")
            case .canNotConnect:
                return LocHelper.tr(table: "LocalizableError", key: "Membership.VerifyEmailCode.canNotConnect")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.NameService.ResolveAnyId.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "NameService.ResolveAnyId.badInput")
            case .canNotConnect:
                return LocHelper.tr(table: "LocalizableError", key: "NameService.ResolveAnyId.canNotConnect")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.NameService.ResolveName.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "NameService.ResolveName.badInput")
            case .canNotConnect:
                return LocHelper.tr(table: "LocalizableError", key: "NameService.ResolveName.canNotConnect")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.NameService.ResolveSpaceId.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "NameService.ResolveSpaceId.badInput")
            case .canNotConnect:
                return LocHelper.tr(table: "LocalizableError", key: "NameService.ResolveSpaceId.canNotConnect")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.NameService.UserAccount.Get.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "NameService.UserAccount.Get.badInput")
            case .notLoggedIn:
                return LocHelper.tr(table: "LocalizableError", key: "NameService.UserAccount.Get.notLoggedIn")
            case .badNameResolve:
                return LocHelper.tr(table: "LocalizableError", key: "NameService.UserAccount.Get.badNameResolve")
            case .canNotConnect:
                return LocHelper.tr(table: "LocalizableError", key: "NameService.UserAccount.Get.canNotConnect")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Navigation.GetObjectInfoWithLinks.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Navigation.GetObjectInfoWithLinks.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Navigation.ListObjects.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Navigation.ListObjects.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Notification.List.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Notification.List.badInput")
            case .internalError:
                return LocHelper.tr(table: "LocalizableError", key: "Notification.List.internalError")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Notification.Reply.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Notification.Reply.badInput")
            case .internalError:
                return LocHelper.tr(table: "LocalizableError", key: "Notification.Reply.internalError")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Notification.Test.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Notification.Test.badInput")
            case .internalError:
                return LocHelper.tr(table: "LocalizableError", key: "Notification.Test.internalError")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.ApplyTemplate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.ApplyTemplate.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.BookmarkFetch.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.BookmarkFetch.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.ChatAdd.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.ChatAdd.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.Close.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Close.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.Create.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Create.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.CreateBookmark.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.CreateBookmark.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.CreateFromUrl.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.CreateFromUrl.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.CreateObjectType.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.CreateObjectType.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.CreateRelation.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.CreateRelation.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.CreateRelationOption.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.CreateRelationOption.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.CreateSet.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.CreateSet.badInput")
            case .unknownObjectTypeURL:
                return LocHelper.tr(table: "LocalizableError", key: "Object.CreateSet.unknownObjectTypeURL")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.CrossSpaceSearchSubscribe.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.CrossSpaceSearchSubscribe.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.CrossSpaceSearchUnsubscribe.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.CrossSpaceSearchUnsubscribe.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.DateByTimestamp.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.DateByTimestamp.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.Duplicate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Duplicate.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.Export.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Export.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.Graph.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Graph.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.GroupsSubscribe.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.GroupsSubscribe.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.Import.Notion.ValidateToken.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Import.Notion.ValidateToken.badInput")
            case .internalError:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Import.Notion.ValidateToken.internalError")
            case .unauthorized:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Import.Notion.ValidateToken.unauthorized")
            case .forbidden:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Import.Notion.ValidateToken.forbidden")
            case .serviceUnavailable:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Import.Notion.ValidateToken.serviceUnavailable")
            case .accountIsNotRunning:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Import.Notion.ValidateToken.accountIsNotRunning")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.Import.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Import.badInput")
            case .internalError:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Import.internalError")
            case .noObjectsToImport:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Import.noObjectsToImport")
            case .importIsCanceled:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Import.importIsCanceled")
            case .limitOfRowsOrRelationsExceeded:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Import.limitOfRowsOrRelationsExceeded")
            case .fileLoadError:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Import.fileLoadError")
            case .insufficientPermissions:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Import.insufficientPermissions")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.ImportExperience.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.ImportExperience.badInput")
            case .insufficientPermission:
                return LocHelper.tr(table: "LocalizableError", key: "Object.ImportExperience.insufficientPermission")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.ImportList.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.ImportList.badInput")
            case .internalError:
                return LocHelper.tr(table: "LocalizableError", key: "Object.ImportList.internalError")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.ImportUseCase.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.ImportUseCase.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.ListDelete.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.ListDelete.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.ListDuplicate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.ListDuplicate.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.ListExport.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.ListExport.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.ListModifyDetailValues.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.ListModifyDetailValues.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.ListSetDetails.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.ListSetDetails.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.ListSetIsArchived.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.ListSetIsArchived.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.ListSetIsFavorite.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.ListSetIsFavorite.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.ListSetObjectType.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.ListSetObjectType.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.Open.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Open.badInput")
            case .notFound:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Open.notFound")
            case .anytypeNeedsUpgrade:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Open.anytypeNeedsUpgrade")
            case .objectDeleted:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Open.objectDeleted")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.OpenBreadcrumbs.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.OpenBreadcrumbs.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.Redo.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Redo.badInput")
            case .canNotMove:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Redo.canNotMove")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.Refresh.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Refresh.badInput")
            case .objectDeleted:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Refresh.objectDeleted")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.Search.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Search.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.SearchSubscribe.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.SearchSubscribe.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.SearchUnsubscribe.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.SearchUnsubscribe.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.SearchWithMeta.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.SearchWithMeta.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.SetBreadcrumbs.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.SetBreadcrumbs.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.SetDetails.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.SetDetails.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.SetInternalFlags.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.SetInternalFlags.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.SetIsArchived.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.SetIsArchived.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.SetIsFavorite.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.SetIsFavorite.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.SetLayout.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.SetLayout.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.SetObjectType.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.SetObjectType.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.SetSource.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.SetSource.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.ShareByLink.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.ShareByLink.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.Show.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Show.badInput")
            case .notFound:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Show.notFound")
            case .objectDeleted:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Show.objectDeleted")
            case .anytypeNeedsUpgrade:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Show.anytypeNeedsUpgrade")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.SubscribeIds.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.SubscribeIds.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.ToCollection.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.ToCollection.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.ToSet.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.ToSet.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.Undo.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Undo.badInput")
            case .canNotMove:
                return LocHelper.tr(table: "LocalizableError", key: "Object.Undo.canNotMove")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.WorkspaceSetDashboard.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Object.WorkspaceSetDashboard.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.ObjectCollection.Add.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "ObjectCollection.Add.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.ObjectCollection.Remove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "ObjectCollection.Remove.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.ObjectCollection.Sort.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "ObjectCollection.Sort.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.ObjectRelation.Add.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "ObjectRelation.Add.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.ObjectRelation.AddFeatured.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "ObjectRelation.AddFeatured.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.ObjectRelation.Delete.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "ObjectRelation.Delete.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.ObjectRelation.ListAvailable.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "ObjectRelation.ListAvailable.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.ObjectRelation.RemoveFeatured.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "ObjectRelation.RemoveFeatured.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.ObjectType.ListConflictingRelations.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "ObjectType.ListConflictingRelations.badInput")
            case .readonlyObjectType:
                return LocHelper.tr(table: "LocalizableError", key: "ObjectType.ListConflictingRelations.readonlyObjectType")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.ObjectType.Recommended.FeaturedRelationsSet.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "ObjectType.Recommended.FeaturedRelationsSet.badInput")
            case .readonlyObjectType:
                return LocHelper.tr(table: "LocalizableError", key: "ObjectType.Recommended.FeaturedRelationsSet.readonlyObjectType")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.ObjectType.Recommended.RelationsSet.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "ObjectType.Recommended.RelationsSet.badInput")
            case .readonlyObjectType:
                return LocHelper.tr(table: "LocalizableError", key: "ObjectType.Recommended.RelationsSet.readonlyObjectType")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.ObjectType.Relation.Add.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "ObjectType.Relation.Add.badInput")
            case .readonlyObjectType:
                return LocHelper.tr(table: "LocalizableError", key: "ObjectType.Relation.Add.readonlyObjectType")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.ObjectType.Relation.Remove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "ObjectType.Relation.Remove.badInput")
            case .readonlyObjectType:
                return LocHelper.tr(table: "LocalizableError", key: "ObjectType.Relation.Remove.readonlyObjectType")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.ObjectType.ResolveLayoutConflicts.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "ObjectType.ResolveLayoutConflicts.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Process.Cancel.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Process.Cancel.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Process.Subscribe.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Process.Subscribe.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Process.Unsubscribe.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Process.Unsubscribe.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Publishing.Create.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Publishing.Create.badInput")
            case .noSuchObject:
                return LocHelper.tr(table: "LocalizableError", key: "Publishing.Create.noSuchObject")
            case .noSuchSpace:
                return LocHelper.tr(table: "LocalizableError", key: "Publishing.Create.noSuchSpace")
            case .limitExceeded:
                return LocHelper.tr(table: "LocalizableError", key: "Publishing.Create.limitExceeded")
            case .urlAlreadyTaken:
                return LocHelper.tr(table: "LocalizableError", key: "Publishing.Create.urlAlreadyTaken")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Publishing.GetStatus.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Publishing.GetStatus.badInput")
            case .noSuchObject:
                return LocHelper.tr(table: "LocalizableError", key: "Publishing.GetStatus.noSuchObject")
            case .noSuchSpace:
                return LocHelper.tr(table: "LocalizableError", key: "Publishing.GetStatus.noSuchSpace")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Publishing.List.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Publishing.List.badInput")
            case .noSuchSpace:
                return LocHelper.tr(table: "LocalizableError", key: "Publishing.List.noSuchSpace")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Publishing.Remove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Publishing.Remove.badInput")
            case .noSuchObject:
                return LocHelper.tr(table: "LocalizableError", key: "Publishing.Remove.noSuchObject")
            case .noSuchSpace:
                return LocHelper.tr(table: "LocalizableError", key: "Publishing.Remove.noSuchSpace")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Publishing.ResolveUri.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Publishing.ResolveUri.badInput")
            case .noSuchUri:
                return LocHelper.tr(table: "LocalizableError", key: "Publishing.ResolveUri.noSuchUri")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.PushNotification.RegisterToken.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "PushNotification.RegisterToken.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.PushNotification.SetSpaceMode.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "PushNotification.SetSpaceMode.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Relation.ListRemoveOption.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Relation.ListRemoveOption.badInput")
            case .optionUsedByObjects:
                return LocHelper.tr(table: "LocalizableError", key: "Relation.ListRemoveOption.optionUsedByObjects")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Relation.ListWithValue.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Relation.ListWithValue.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Relation.Options.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Relation.Options.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Space.Delete.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Space.Delete.badInput")
            case .noSuchSpace:
                return LocHelper.tr(table: "LocalizableError", key: "Space.Delete.noSuchSpace")
            case .spaceIsDeleted:
                return LocHelper.tr(table: "LocalizableError", key: "Space.Delete.spaceIsDeleted")
            case .requestFailed:
                return LocHelper.tr(table: "LocalizableError", key: "Space.Delete.requestFailed")
            case .limitReached:
                return LocHelper.tr(table: "LocalizableError", key: "Space.Delete.limitReached")
            case .notShareable:
                return LocHelper.tr(table: "LocalizableError", key: "Space.Delete.notShareable")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Space.InviteChange.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteChange.badInput")
            case .noSuchSpace:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteChange.noSuchSpace")
            case .spaceIsDeleted:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteChange.spaceIsDeleted")
            case .requestFailed:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteChange.requestFailed")
            case .incorrectPermissions:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteChange.incorrectPermissions")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Space.InviteGenerate.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteGenerate.badInput")
            case .noSuchSpace:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteGenerate.noSuchSpace")
            case .spaceIsDeleted:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteGenerate.spaceIsDeleted")
            case .requestFailed:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteGenerate.requestFailed")
            case .limitReached:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteGenerate.limitReached")
            case .notShareable:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteGenerate.notShareable")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Space.InviteGetCurrent.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteGetCurrent.badInput")
            case .noActiveInvite:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteGetCurrent.noActiveInvite")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Space.InviteGetGuest.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteGetGuest.badInput")
            case .invalidSpaceType:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteGetGuest.invalidSpaceType")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Space.InviteRevoke.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteRevoke.badInput")
            case .noSuchSpace:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteRevoke.noSuchSpace")
            case .spaceIsDeleted:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteRevoke.spaceIsDeleted")
            case .limitReached:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteRevoke.limitReached")
            case .requestFailed:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteRevoke.requestFailed")
            case .notShareable:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteRevoke.notShareable")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Space.InviteView.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteView.badInput")
            case .inviteNotFound:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteView.inviteNotFound")
            case .inviteBadContent:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteView.inviteBadContent")
            case .spaceIsDeleted:
                return LocHelper.tr(table: "LocalizableError", key: "Space.InviteView.spaceIsDeleted")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Space.Join.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Space.Join.badInput")
            case .noSuchSpace:
                return LocHelper.tr(table: "LocalizableError", key: "Space.Join.noSuchSpace")
            case .spaceIsDeleted:
                return LocHelper.tr(table: "LocalizableError", key: "Space.Join.spaceIsDeleted")
            case .inviteNotFound:
                return LocHelper.tr(table: "LocalizableError", key: "Space.Join.inviteNotFound")
            case .inviteBadContent:
                return LocHelper.tr(table: "LocalizableError", key: "Space.Join.inviteBadContent")
            case .requestFailed:
                return LocHelper.tr(table: "LocalizableError", key: "Space.Join.requestFailed")
            case .limitReached:
                return LocHelper.tr(table: "LocalizableError", key: "Space.Join.limitReached")
            case .notShareable:
                return LocHelper.tr(table: "LocalizableError", key: "Space.Join.notShareable")
            case .differentNetwork:
                return LocHelper.tr(table: "LocalizableError", key: "Space.Join.differentNetwork")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Space.JoinCancel.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Space.JoinCancel.badInput")
            case .noSuchSpace:
                return LocHelper.tr(table: "LocalizableError", key: "Space.JoinCancel.noSuchSpace")
            case .spaceIsDeleted:
                return LocHelper.tr(table: "LocalizableError", key: "Space.JoinCancel.spaceIsDeleted")
            case .requestFailed:
                return LocHelper.tr(table: "LocalizableError", key: "Space.JoinCancel.requestFailed")
            case .limitReached:
                return LocHelper.tr(table: "LocalizableError", key: "Space.JoinCancel.limitReached")
            case .noSuchRequest:
                return LocHelper.tr(table: "LocalizableError", key: "Space.JoinCancel.noSuchRequest")
            case .notShareable:
                return LocHelper.tr(table: "LocalizableError", key: "Space.JoinCancel.notShareable")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Space.LeaveApprove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Space.LeaveApprove.badInput")
            case .noSuchSpace:
                return LocHelper.tr(table: "LocalizableError", key: "Space.LeaveApprove.noSuchSpace")
            case .spaceIsDeleted:
                return LocHelper.tr(table: "LocalizableError", key: "Space.LeaveApprove.spaceIsDeleted")
            case .requestFailed:
                return LocHelper.tr(table: "LocalizableError", key: "Space.LeaveApprove.requestFailed")
            case .limitReached:
                return LocHelper.tr(table: "LocalizableError", key: "Space.LeaveApprove.limitReached")
            case .noApproveRequests:
                return LocHelper.tr(table: "LocalizableError", key: "Space.LeaveApprove.noApproveRequests")
            case .notShareable:
                return LocHelper.tr(table: "LocalizableError", key: "Space.LeaveApprove.notShareable")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Space.MakeShareable.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Space.MakeShareable.badInput")
            case .noSuchSpace:
                return LocHelper.tr(table: "LocalizableError", key: "Space.MakeShareable.noSuchSpace")
            case .spaceIsDeleted:
                return LocHelper.tr(table: "LocalizableError", key: "Space.MakeShareable.spaceIsDeleted")
            case .requestFailed:
                return LocHelper.tr(table: "LocalizableError", key: "Space.MakeShareable.requestFailed")
            case .limitReached:
                return LocHelper.tr(table: "LocalizableError", key: "Space.MakeShareable.limitReached")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Space.ParticipantPermissionsChange.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Space.ParticipantPermissionsChange.badInput")
            case .noSuchSpace:
                return LocHelper.tr(table: "LocalizableError", key: "Space.ParticipantPermissionsChange.noSuchSpace")
            case .spaceIsDeleted:
                return LocHelper.tr(table: "LocalizableError", key: "Space.ParticipantPermissionsChange.spaceIsDeleted")
            case .requestFailed:
                return LocHelper.tr(table: "LocalizableError", key: "Space.ParticipantPermissionsChange.requestFailed")
            case .limitReached:
                return LocHelper.tr(table: "LocalizableError", key: "Space.ParticipantPermissionsChange.limitReached")
            case .participantNotFound:
                return LocHelper.tr(table: "LocalizableError", key: "Space.ParticipantPermissionsChange.participantNotFound")
            case .incorrectPermissions:
                return LocHelper.tr(table: "LocalizableError", key: "Space.ParticipantPermissionsChange.incorrectPermissions")
            case .notShareable:
                return LocHelper.tr(table: "LocalizableError", key: "Space.ParticipantPermissionsChange.notShareable")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Space.ParticipantRemove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Space.ParticipantRemove.badInput")
            case .noSuchSpace:
                return LocHelper.tr(table: "LocalizableError", key: "Space.ParticipantRemove.noSuchSpace")
            case .spaceIsDeleted:
                return LocHelper.tr(table: "LocalizableError", key: "Space.ParticipantRemove.spaceIsDeleted")
            case .participantNotFound:
                return LocHelper.tr(table: "LocalizableError", key: "Space.ParticipantRemove.participantNotFound")
            case .requestFailed:
                return LocHelper.tr(table: "LocalizableError", key: "Space.ParticipantRemove.requestFailed")
            case .limitReached:
                return LocHelper.tr(table: "LocalizableError", key: "Space.ParticipantRemove.limitReached")
            case .notShareable:
                return LocHelper.tr(table: "LocalizableError", key: "Space.ParticipantRemove.notShareable")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Space.RequestApprove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Space.RequestApprove.badInput")
            case .noSuchSpace:
                return LocHelper.tr(table: "LocalizableError", key: "Space.RequestApprove.noSuchSpace")
            case .spaceIsDeleted:
                return LocHelper.tr(table: "LocalizableError", key: "Space.RequestApprove.spaceIsDeleted")
            case .noSuchRequest:
                return LocHelper.tr(table: "LocalizableError", key: "Space.RequestApprove.noSuchRequest")
            case .incorrectPermissions:
                return LocHelper.tr(table: "LocalizableError", key: "Space.RequestApprove.incorrectPermissions")
            case .requestFailed:
                return LocHelper.tr(table: "LocalizableError", key: "Space.RequestApprove.requestFailed")
            case .limitReached:
                return LocHelper.tr(table: "LocalizableError", key: "Space.RequestApprove.limitReached")
            case .notShareable:
                return LocHelper.tr(table: "LocalizableError", key: "Space.RequestApprove.notShareable")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Space.RequestDecline.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Space.RequestDecline.badInput")
            case .noSuchSpace:
                return LocHelper.tr(table: "LocalizableError", key: "Space.RequestDecline.noSuchSpace")
            case .spaceIsDeleted:
                return LocHelper.tr(table: "LocalizableError", key: "Space.RequestDecline.spaceIsDeleted")
            case .requestFailed:
                return LocHelper.tr(table: "LocalizableError", key: "Space.RequestDecline.requestFailed")
            case .limitReached:
                return LocHelper.tr(table: "LocalizableError", key: "Space.RequestDecline.limitReached")
            case .noSuchRequest:
                return LocHelper.tr(table: "LocalizableError", key: "Space.RequestDecline.noSuchRequest")
            case .notShareable:
                return LocHelper.tr(table: "LocalizableError", key: "Space.RequestDecline.notShareable")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Space.SetOrder.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Space.SetOrder.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Space.StopSharing.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Space.StopSharing.badInput")
            case .noSuchSpace:
                return LocHelper.tr(table: "LocalizableError", key: "Space.StopSharing.noSuchSpace")
            case .spaceIsDeleted:
                return LocHelper.tr(table: "LocalizableError", key: "Space.StopSharing.spaceIsDeleted")
            case .requestFailed:
                return LocHelper.tr(table: "LocalizableError", key: "Space.StopSharing.requestFailed")
            case .limitReached:
                return LocHelper.tr(table: "LocalizableError", key: "Space.StopSharing.limitReached")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Space.UnsetOrder.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Space.UnsetOrder.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Template.Clone.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Template.Clone.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Template.CreateFromObject.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Template.CreateFromObject.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Template.ExportAll.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Template.ExportAll.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Unsplash.Download.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Unsplash.Download.badInput")
            case .rateLimitExceeded:
                return LocHelper.tr(table: "LocalizableError", key: "Unsplash.Download.rateLimitExceeded")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Unsplash.Search.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Unsplash.Search.badInput")
            case .rateLimitExceeded:
                return LocHelper.tr(table: "LocalizableError", key: "Unsplash.Search.rateLimitExceeded")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Wallet.CloseSession.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Wallet.CloseSession.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Wallet.Convert.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Wallet.Convert.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Wallet.Create.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Wallet.Create.badInput")
            case .failedToCreateLocalRepo:
                return LocHelper.tr(table: "LocalizableError", key: "Wallet.Create.failedToCreateLocalRepo")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Wallet.CreateSession.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Wallet.CreateSession.badInput")
            case .appTokenNotFoundInTheCurrentAccount:
                return LocHelper.tr(table: "LocalizableError", key: "Wallet.CreateSession.appTokenNotFoundInTheCurrentAccount")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Wallet.Recover.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Wallet.Recover.badInput")
            case .failedToCreateLocalRepo:
                return LocHelper.tr(table: "LocalizableError", key: "Wallet.Recover.failedToCreateLocalRepo")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Workspace.Create.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Workspace.Create.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Workspace.Export.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Workspace.Export.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Workspace.GetAll.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Workspace.GetAll.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Workspace.GetCurrent.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Workspace.GetCurrent.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Workspace.Object.Add.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Workspace.Object.Add.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Workspace.Object.ListAdd.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Workspace.Object.ListAdd.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Workspace.Object.ListRemove.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Workspace.Object.ListRemove.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Workspace.Open.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Workspace.Open.badInput")
            case .failedToLoad:
                return LocHelper.tr(table: "LocalizableError", key: "Workspace.Open.failedToLoad")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Workspace.Select.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Workspace.Select.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Workspace.SetInfo.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return LocHelper.tr(table: "LocalizableError", key: "Workspace.SetInfo.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}


private struct LocHelper {
    static func tr(table: String, key: String) -> String {
        let format = BundleToken.bundle.localizedString(forKey: key, value: "", table: table)
        let locValue = String(format: format, locale: Locale.current, arguments: [])
        if key == locValue {
            return ""
        } else {
            return locValue
        }
    }
}

// swiftlint:disable convenience_type
private final class BundleToken {
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleToken.self)
        #endif
    }()
}
