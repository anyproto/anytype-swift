// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
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
                return String(localized: "AI.Autofill.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.Autofill.badInput")
            case .rateLimitExceeded:
                return String(localized: "AI.Autofill.rateLimitExceeded", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.Autofill.rateLimitExceeded")
            case .endpointNotReachable:
                return String(localized: "AI.Autofill.endpointNotReachable", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.Autofill.endpointNotReachable")
            case .modelNotFound:
                return String(localized: "AI.Autofill.modelNotFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.Autofill.modelNotFound")
            case .authRequired:
                return String(localized: "AI.Autofill.authRequired", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.Autofill.authRequired")
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
                return String(localized: "AI.ListSummary.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.ListSummary.badInput")
            case .rateLimitExceeded:
                return String(localized: "AI.ListSummary.rateLimitExceeded", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.ListSummary.rateLimitExceeded")
            case .endpointNotReachable:
                return String(localized: "AI.ListSummary.endpointNotReachable", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.ListSummary.endpointNotReachable")
            case .modelNotFound:
                return String(localized: "AI.ListSummary.modelNotFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.ListSummary.modelNotFound")
            case .authRequired:
                return String(localized: "AI.ListSummary.authRequired", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.ListSummary.authRequired")
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
                return String(localized: "AI.ObjectCreateFromUrl.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.ObjectCreateFromUrl.badInput")
            case .rateLimitExceeded:
                return String(localized: "AI.ObjectCreateFromUrl.rateLimitExceeded", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.ObjectCreateFromUrl.rateLimitExceeded")
            case .endpointNotReachable:
                return String(localized: "AI.ObjectCreateFromUrl.endpointNotReachable", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.ObjectCreateFromUrl.endpointNotReachable")
            case .modelNotFound:
                return String(localized: "AI.ObjectCreateFromUrl.modelNotFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.ObjectCreateFromUrl.modelNotFound")
            case .authRequired:
                return String(localized: "AI.ObjectCreateFromUrl.authRequired", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.ObjectCreateFromUrl.authRequired")
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
                return String(localized: "AI.WritingTools.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.WritingTools.badInput")
            case .rateLimitExceeded:
                return String(localized: "AI.WritingTools.rateLimitExceeded", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.WritingTools.rateLimitExceeded")
            case .endpointNotReachable:
                return String(localized: "AI.WritingTools.endpointNotReachable", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.WritingTools.endpointNotReachable")
            case .modelNotFound:
                return String(localized: "AI.WritingTools.modelNotFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.WritingTools.modelNotFound")
            case .authRequired:
                return String(localized: "AI.WritingTools.authRequired", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.WritingTools.authRequired")
            case .languageNotSupported:
                return String(localized: "AI.WritingTools.languageNotSupported", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "AI.WritingTools.languageNotSupported")
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
                return String(localized: "Account.ChangeJsonApiAddr.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.ChangeJsonApiAddr.badInput")
            case .accountIsNotRunning:
                return String(localized: "Account.ChangeJsonApiAddr.accountIsNotRunning", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.ChangeJsonApiAddr.accountIsNotRunning")
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
                return String(localized: "Account.ChangeNetworkConfigAndRestart.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.ChangeNetworkConfigAndRestart.badInput")
            case .accountIsNotRunning:
                return String(localized: "Account.ChangeNetworkConfigAndRestart.accountIsNotRunning", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.ChangeNetworkConfigAndRestart.accountIsNotRunning")
            case .accountFailedToStop:
                return String(localized: "Account.ChangeNetworkConfigAndRestart.accountFailedToStop", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.ChangeNetworkConfigAndRestart.accountFailedToStop")
            case .configFileNotFound:
                return String(localized: "Account.ChangeNetworkConfigAndRestart.configFileNotFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.ChangeNetworkConfigAndRestart.configFileNotFound")
            case .configFileInvalid:
                return String(localized: "Account.ChangeNetworkConfigAndRestart.configFileInvalid", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.ChangeNetworkConfigAndRestart.configFileInvalid")
            case .configFileNetworkIDMismatch:
                return String(localized: "Account.ChangeNetworkConfigAndRestart.configFileNetworkIDMismatch", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.ChangeNetworkConfigAndRestart.configFileNetworkIDMismatch")
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
                return String(localized: "Account.ConfigUpdate.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.ConfigUpdate.badInput")
            case .accountIsNotRunning:
                return String(localized: "Account.ConfigUpdate.accountIsNotRunning", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.ConfigUpdate.accountIsNotRunning")
            case .failedToWriteConfig:
                return String(localized: "Account.ConfigUpdate.failedToWriteConfig", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.ConfigUpdate.failedToWriteConfig")
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
                return String(localized: "Account.Create.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Create.badInput")
            case .accountCreatedButFailedToStartNode:
                return String(localized: "Account.Create.accountCreatedButFailedToStartNode", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Create.accountCreatedButFailedToStartNode")
            case .accountCreatedButFailedToSetName:
                return String(localized: "Account.Create.accountCreatedButFailedToSetName", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Create.accountCreatedButFailedToSetName")
            case .failedToStopRunningNode:
                return String(localized: "Account.Create.failedToStopRunningNode", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Create.failedToStopRunningNode")
            case .failedToWriteConfig:
                return String(localized: "Account.Create.failedToWriteConfig", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Create.failedToWriteConfig")
            case .failedToCreateLocalRepo:
                return String(localized: "Account.Create.failedToCreateLocalRepo", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Create.failedToCreateLocalRepo")
            case .accountCreationIsCanceled:
                return String(localized: "Account.Create.accountCreationIsCanceled", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Create.accountCreationIsCanceled")
            case .configFileNotFound:
                return String(localized: "Account.Create.configFileNotFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Create.configFileNotFound")
            case .configFileInvalid:
                return String(localized: "Account.Create.configFileInvalid", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Create.configFileInvalid")
            case .configFileNetworkIDMismatch:
                return String(localized: "Account.Create.configFileNetworkIDMismatch", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Create.configFileNetworkIDMismatch")
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
                return String(localized: "Account.Delete.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Delete.badInput")
            case .accountIsAlreadyDeleted:
                return String(localized: "Account.Delete.accountIsAlreadyDeleted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Delete.accountIsAlreadyDeleted")
            case .unableToConnect:
                return String(localized: "Account.Delete.unableToConnect", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Delete.unableToConnect")
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
                return String(localized: "Account.EnableLocalNetworkSync.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.EnableLocalNetworkSync.badInput")
            case .accountIsNotRunning:
                return String(localized: "Account.EnableLocalNetworkSync.accountIsNotRunning", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.EnableLocalNetworkSync.accountIsNotRunning")
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
                return String(localized: "Account.LocalLink.NewChallenge.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.LocalLink.NewChallenge.badInput")
            case .accountIsNotRunning:
                return String(localized: "Account.LocalLink.NewChallenge.accountIsNotRunning", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.LocalLink.NewChallenge.accountIsNotRunning")
            case .tooManyRequests:
                return String(localized: "Account.LocalLink.NewChallenge.tooManyRequests", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.LocalLink.NewChallenge.tooManyRequests")
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
                return String(localized: "Account.LocalLink.SolveChallenge.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.LocalLink.SolveChallenge.badInput")
            case .accountIsNotRunning:
                return String(localized: "Account.LocalLink.SolveChallenge.accountIsNotRunning", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.LocalLink.SolveChallenge.accountIsNotRunning")
            case .invalidChallengeID:
                return String(localized: "Account.LocalLink.SolveChallenge.invalidChallengeID", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.LocalLink.SolveChallenge.invalidChallengeID")
            case .challengeAttemptsExceeded:
                return String(localized: "Account.LocalLink.SolveChallenge.challengeAttemptsExceeded", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.LocalLink.SolveChallenge.challengeAttemptsExceeded")
            case .incorrectAnswer:
                return String(localized: "Account.LocalLink.SolveChallenge.incorrectAnswer", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.LocalLink.SolveChallenge.incorrectAnswer")
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
                return String(localized: "Account.Migrate.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Migrate.badInput")
            case .accountNotFound:
                return String(localized: "Account.Migrate.accountNotFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Migrate.accountNotFound")
            case .canceled:
                return String(localized: "Account.Migrate.canceled", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Migrate.canceled")
            case .notEnoughFreeSpace:
                return String(localized: "Account.Migrate.notEnoughFreeSpace", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Migrate.notEnoughFreeSpace")
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
                return String(localized: "Account.MigrateCancel.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.MigrateCancel.badInput")
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
                return String(localized: "Account.Move.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Move.badInput")
            case .failedToStopNode:
                return String(localized: "Account.Move.failedToStopNode", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Move.failedToStopNode")
            case .failedToIdentifyAccountDir:
                return String(localized: "Account.Move.failedToIdentifyAccountDir", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Move.failedToIdentifyAccountDir")
            case .failedToRemoveAccountData:
                return String(localized: "Account.Move.failedToRemoveAccountData", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Move.failedToRemoveAccountData")
            case .failedToCreateLocalRepo:
                return String(localized: "Account.Move.failedToCreateLocalRepo", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Move.failedToCreateLocalRepo")
            case .failedToWriteConfig:
                return String(localized: "Account.Move.failedToWriteConfig", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Move.failedToWriteConfig")
            case .failedToGetConfig:
                return String(localized: "Account.Move.failedToGetConfig", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Move.failedToGetConfig")
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
                return String(localized: "Account.Recover.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Recover.badInput")
            case .needToRecoverWalletFirst:
                return String(localized: "Account.Recover.needToRecoverWalletFirst", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Recover.needToRecoverWalletFirst")
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
                return String(localized: "Account.RecoverFromLegacyExport.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.RecoverFromLegacyExport.badInput")
            case .differentAccount:
                return String(localized: "Account.RecoverFromLegacyExport.differentAccount", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.RecoverFromLegacyExport.differentAccount")
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
                return String(localized: "Account.RevertDeletion.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.RevertDeletion.badInput")
            case .accountIsActive:
                return String(localized: "Account.RevertDeletion.accountIsActive", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.RevertDeletion.accountIsActive")
            case .unableToConnect:
                return String(localized: "Account.RevertDeletion.unableToConnect", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.RevertDeletion.unableToConnect")
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
                return String(localized: "Account.Select.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Select.badInput")
            case .failedToCreateLocalRepo:
                return String(localized: "Account.Select.failedToCreateLocalRepo", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Select.failedToCreateLocalRepo")
            case .localRepoExistsButCorrupted:
                return String(localized: "Account.Select.localRepoExistsButCorrupted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Select.localRepoExistsButCorrupted")
            case .failedToRunNode:
                return String(localized: "Account.Select.failedToRunNode", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Select.failedToRunNode")
            case .failedToFindAccountInfo:
                return String(localized: "Account.Select.failedToFindAccountInfo", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Select.failedToFindAccountInfo")
            case .localRepoNotExistsAndMnemonicNotSet:
                return String(localized: "Account.Select.localRepoNotExistsAndMnemonicNotSet", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Select.localRepoNotExistsAndMnemonicNotSet")
            case .failedToStopSearcherNode:
                return String(localized: "Account.Select.failedToStopSearcherNode", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Select.failedToStopSearcherNode")
            case .anotherAnytypeProcessIsRunning:
                return String(localized: "Account.Select.anotherAnytypeProcessIsRunning", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Select.anotherAnytypeProcessIsRunning")
            case .failedToFetchRemoteNodeHasIncompatibleProtoVersion:
                return String(localized: "Account.Select.failedToFetchRemoteNodeHasIncompatibleProtoVersion", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Select.failedToFetchRemoteNodeHasIncompatibleProtoVersion")
            case .accountIsDeleted:
                return String(localized: "Account.Select.accountIsDeleted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Select.accountIsDeleted")
            case .accountLoadIsCanceled:
                return String(localized: "Account.Select.accountLoadIsCanceled", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Select.accountLoadIsCanceled")
            case .accountStoreNotMigrated:
                return String(localized: "Account.Select.accountStoreNotMigrated", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Select.accountStoreNotMigrated")
            case .configFileNotFound:
                return String(localized: "Account.Select.configFileNotFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Select.configFileNotFound")
            case .configFileInvalid:
                return String(localized: "Account.Select.configFileInvalid", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Select.configFileInvalid")
            case .configFileNetworkIDMismatch:
                return String(localized: "Account.Select.configFileNetworkIDMismatch", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Select.configFileNetworkIDMismatch")
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
                return String(localized: "Account.Stop.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Stop.badInput")
            case .accountIsNotRunning:
                return String(localized: "Account.Stop.accountIsNotRunning", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Stop.accountIsNotRunning")
            case .failedToStopNode:
                return String(localized: "Account.Stop.failedToStopNode", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Stop.failedToStopNode")
            case .failedToRemoveAccountData:
                return String(localized: "Account.Stop.failedToRemoveAccountData", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Account.Stop.failedToRemoveAccountData")
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
                return String(localized: "App.GetVersion.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "App.GetVersion.badInput")
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
                return String(localized: "App.SetDeviceState.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "App.SetDeviceState.badInput")
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
                return String(localized: "App.Shutdown.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "App.Shutdown.badInput")
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
                return String(localized: "Block.Copy.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.Copy.badInput")
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
                return String(localized: "Block.Create.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.Create.badInput")
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
                return String(localized: "Block.CreateWidget.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.CreateWidget.badInput")
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
                return String(localized: "Block.Cut.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.Cut.badInput")
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
                return String(localized: "Block.Download.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.Download.badInput")
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
                return String(localized: "Block.Export.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.Export.badInput")
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
                return String(localized: "Block.ListConvertToObjects.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.ListConvertToObjects.badInput")
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
                return String(localized: "Block.ListDelete.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.ListDelete.badInput")
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
                return String(localized: "Block.ListDuplicate.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.ListDuplicate.badInput")
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
                return String(localized: "Block.ListMoveToExistingObject.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.ListMoveToExistingObject.badInput")
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
                return String(localized: "Block.ListMoveToNewObject.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.ListMoveToNewObject.badInput")
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
                return String(localized: "Block.ListSetAlign.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.ListSetAlign.badInput")
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
                return String(localized: "Block.ListSetBackgroundColor.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.ListSetBackgroundColor.badInput")
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
                return String(localized: "Block.ListSetFields.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.ListSetFields.badInput")
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
                return String(localized: "Block.ListSetVerticalAlign.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.ListSetVerticalAlign.badInput")
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
                return String(localized: "Block.ListTurnInto.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.ListTurnInto.badInput")
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
                return String(localized: "Block.Merge.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.Merge.badInput")
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
                return String(localized: "Block.Paste.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.Paste.badInput")
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
                return String(localized: "Block.Preview.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.Preview.badInput")
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
                return String(localized: "Block.Replace.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.Replace.badInput")
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
                return String(localized: "Block.SetCarriage.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.SetCarriage.badInput")
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
                return String(localized: "Block.SetFields.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.SetFields.badInput")
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
                return String(localized: "Block.Split.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.Split.badInput")
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
                return String(localized: "Block.Upload.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Block.Upload.badInput")
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
                return String(localized: "BlockBookmark.CreateAndFetch.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockBookmark.CreateAndFetch.badInput")
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
                return String(localized: "BlockBookmark.Fetch.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockBookmark.Fetch.badInput")
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
                return String(localized: "BlockDataview.CreateFromExistingObject.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.CreateFromExistingObject.badInput")
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
                return String(localized: "BlockDataview.Filter.Add.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.Filter.Add.badInput")
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
                return String(localized: "BlockDataview.Filter.Remove.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.Filter.Remove.badInput")
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
                return String(localized: "BlockDataview.Filter.Replace.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.Filter.Replace.badInput")
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
                return String(localized: "BlockDataview.Filter.Sort.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.Filter.Sort.badInput")
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
                return String(localized: "BlockDataview.GroupOrder.Update.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.GroupOrder.Update.badInput")
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
                return String(localized: "BlockDataview.ObjectOrder.Move.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.ObjectOrder.Move.badInput")
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
                return String(localized: "BlockDataview.ObjectOrder.Update.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.ObjectOrder.Update.badInput")
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
                return String(localized: "BlockDataview.Relation.Add.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.Relation.Add.badInput")
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
                return String(localized: "BlockDataview.Relation.Delete.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.Relation.Delete.badInput")
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
                return String(localized: "BlockDataview.Relation.Set.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.Relation.Set.badInput")
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
                return String(localized: "BlockDataview.SetSource.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.SetSource.badInput")
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
                return String(localized: "BlockDataview.Sort.Add.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.Sort.Add.badInput")
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
                return String(localized: "BlockDataview.Sort.Remove.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.Sort.Remove.badInput")
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
                return String(localized: "BlockDataview.Sort.Replace.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.Sort.Replace.badInput")
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
                return String(localized: "BlockDataview.Sort.SSort.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.Sort.SSort.badInput")
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
                return String(localized: "BlockDataview.View.Create.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.View.Create.badInput")
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
                return String(localized: "BlockDataview.View.Delete.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.View.Delete.badInput")
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
                return String(localized: "BlockDataview.View.SetActive.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.View.SetActive.badInput")
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
                return String(localized: "BlockDataview.View.SetPosition.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.View.SetPosition.badInput")
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
                return String(localized: "BlockDataview.View.Update.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.View.Update.badInput")
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
                return String(localized: "BlockDataview.ViewRelation.Add.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.ViewRelation.Add.badInput")
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
                return String(localized: "BlockDataview.ViewRelation.Remove.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.ViewRelation.Remove.badInput")
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
                return String(localized: "BlockDataview.ViewRelation.Replace.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.ViewRelation.Replace.badInput")
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
                return String(localized: "BlockDataview.ViewRelation.Sort.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDataview.ViewRelation.Sort.badInput")
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
                return String(localized: "BlockDiv.ListSetStyle.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockDiv.ListSetStyle.badInput")
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
                return String(localized: "BlockFile.CreateAndUpload.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockFile.CreateAndUpload.badInput")
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
                return String(localized: "BlockFile.ListSetStyle.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockFile.ListSetStyle.badInput")
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
                return String(localized: "BlockFile.SetName.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockFile.SetName.badInput")
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
                return String(localized: "BlockFile.SetTargetObjectId.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockFile.SetTargetObjectId.badInput")
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
                return String(localized: "BlockImage.SetName.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockImage.SetName.badInput")
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
                return String(localized: "BlockImage.SetWidth.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockImage.SetWidth.badInput")
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
                return String(localized: "BlockLatex.SetProcessor.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockLatex.SetProcessor.badInput")
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
                return String(localized: "BlockLatex.SetText.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockLatex.SetText.badInput")
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
                return String(localized: "BlockLink.CreateWithObject.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockLink.CreateWithObject.badInput")
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
                return String(localized: "BlockLink.ListSetAppearance.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockLink.ListSetAppearance.badInput")
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
                return String(localized: "BlockRelation.Add.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockRelation.Add.badInput")
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
                return String(localized: "BlockRelation.SetKey.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockRelation.SetKey.badInput")
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
                return String(localized: "BlockTable.ColumnCreate.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockTable.ColumnCreate.badInput")
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
                return String(localized: "BlockTable.ColumnDelete.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockTable.ColumnDelete.badInput")
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
                return String(localized: "BlockTable.ColumnDuplicate.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockTable.ColumnDuplicate.badInput")
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
                return String(localized: "BlockTable.ColumnListFill.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockTable.ColumnListFill.badInput")
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
                return String(localized: "BlockTable.ColumnMove.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockTable.ColumnMove.badInput")
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
                return String(localized: "BlockTable.Create.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockTable.Create.badInput")
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
                return String(localized: "BlockTable.Expand.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockTable.Expand.badInput")
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
                return String(localized: "BlockTable.RowCreate.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockTable.RowCreate.badInput")
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
                return String(localized: "BlockTable.RowDelete.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockTable.RowDelete.badInput")
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
                return String(localized: "BlockTable.RowDuplicate.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockTable.RowDuplicate.badInput")
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
                return String(localized: "BlockTable.RowListClean.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockTable.RowListClean.badInput")
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
                return String(localized: "BlockTable.RowListFill.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockTable.RowListFill.badInput")
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
                return String(localized: "BlockTable.RowSetHeader.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockTable.RowSetHeader.badInput")
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
                return String(localized: "BlockTable.Sort.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockTable.Sort.badInput")
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
                return String(localized: "BlockText.ListClearContent.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockText.ListClearContent.badInput")
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
                return String(localized: "BlockText.ListClearStyle.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockText.ListClearStyle.badInput")
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
                return String(localized: "BlockText.ListSetColor.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockText.ListSetColor.badInput")
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
                return String(localized: "BlockText.ListSetMark.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockText.ListSetMark.badInput")
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
                return String(localized: "BlockText.ListSetStyle.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockText.ListSetStyle.badInput")
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
                return String(localized: "BlockText.SetChecked.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockText.SetChecked.badInput")
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
                return String(localized: "BlockText.SetColor.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockText.SetColor.badInput")
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
                return String(localized: "BlockText.SetIcon.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockText.SetIcon.badInput")
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
                return String(localized: "BlockText.SetMarks.Get.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockText.SetMarks.Get.badInput")
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
                return String(localized: "BlockText.SetStyle.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockText.SetStyle.badInput")
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
                return String(localized: "BlockText.SetText.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockText.SetText.badInput")
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
                return String(localized: "BlockVideo.SetName.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockVideo.SetName.badInput")
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
                return String(localized: "BlockVideo.SetWidth.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockVideo.SetWidth.badInput")
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
                return String(localized: "BlockWidget.SetLayout.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockWidget.SetLayout.badInput")
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
                return String(localized: "BlockWidget.SetLimit.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockWidget.SetLimit.badInput")
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
                return String(localized: "BlockWidget.SetTargetId.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockWidget.SetTargetId.badInput")
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
                return String(localized: "BlockWidget.SetViewId.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "BlockWidget.SetViewId.badInput")
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
                return String(localized: "Broadcast.PayloadEvent.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Broadcast.PayloadEvent.badInput")
            case .internalError:
                return String(localized: "Broadcast.PayloadEvent.internalError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Broadcast.PayloadEvent.internalError")
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
                return String(localized: "Chat.AddMessage.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Chat.AddMessage.badInput")
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
                return String(localized: "Chat.DeleteMessage.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Chat.DeleteMessage.badInput")
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
                return String(localized: "Chat.EditMessageContent.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Chat.EditMessageContent.badInput")
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
                return String(localized: "Chat.GetMessages.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Chat.GetMessages.badInput")
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
                return String(localized: "Chat.GetMessagesByIds.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Chat.GetMessagesByIds.badInput")
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
                return String(localized: "Chat.ReadMessages.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Chat.ReadMessages.badInput")
            case .messagesNotFound:
                return String(localized: "Chat.ReadMessages.messagesNotFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Chat.ReadMessages.messagesNotFound")
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
                return String(localized: "Chat.SubscribeLastMessages.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Chat.SubscribeLastMessages.badInput")
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
                return String(localized: "Chat.SubscribeToMessagePreviews.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Chat.SubscribeToMessagePreviews.badInput")
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
                return String(localized: "Chat.ToggleMessageReaction.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Chat.ToggleMessageReaction.badInput")
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
                return String(localized: "Chat.Unread.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Chat.Unread.badInput")
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
                return String(localized: "Chat.Unsubscribe.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Chat.Unsubscribe.badInput")
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
                return String(localized: "Chat.UnsubscribeFromMessagePreviews.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Chat.UnsubscribeFromMessagePreviews.badInput")
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
                return String(localized: "Debug.AccountSelectTrace.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Debug.AccountSelectTrace.badInput")
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
                return String(localized: "Debug.AnystoreObjectChanges.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Debug.AnystoreObjectChanges.badInput")
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
                return String(localized: "Debug.ExportLocalstore.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Debug.ExportLocalstore.badInput")
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
                return String(localized: "Debug.ExportLog.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Debug.ExportLog.badInput")
            case .noFolder:
                return String(localized: "Debug.ExportLog.noFolder", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Debug.ExportLog.noFolder")
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
                return String(localized: "Debug.NetCheck.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Debug.NetCheck.badInput")
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
                return String(localized: "Debug.OpenedObjects.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Debug.OpenedObjects.badInput")
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
                return String(localized: "Debug.Ping.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Debug.Ping.badInput")
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
                return String(localized: "Debug.RunProfiler.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Debug.RunProfiler.badInput")
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
                return String(localized: "Debug.SpaceSummary.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Debug.SpaceSummary.badInput")
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
                return String(localized: "Debug.StackGoroutines.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Debug.StackGoroutines.badInput")
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
                return String(localized: "Debug.Stat.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Debug.Stat.badInput")
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
                return String(localized: "Debug.Subscriptions.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Debug.Subscriptions.badInput")
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
                return String(localized: "Debug.Tree.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Debug.Tree.badInput")
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
                return String(localized: "Debug.TreeHeads.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Debug.TreeHeads.badInput")
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
                return String(localized: "Device.List.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Device.List.badInput")
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
                return String(localized: "Device.NetworkState.Set.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Device.NetworkState.Set.badInput")
            case .internalError:
                return String(localized: "Device.NetworkState.Set.internalError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Device.NetworkState.Set.internalError")
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
                return String(localized: "Device.SetName.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Device.SetName.badInput")
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
                return String(localized: "File.Download.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "File.Download.badInput")
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
                return String(localized: "File.Drop.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "File.Drop.badInput")
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
                return String(localized: "File.ListOffload.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "File.ListOffload.badInput")
            case .nodeNotStarted:
                return String(localized: "File.ListOffload.nodeNotStarted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "File.ListOffload.nodeNotStarted")
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
                return String(localized: "File.NodeUsage.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "File.NodeUsage.badInput")
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
                return String(localized: "File.Offload.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "File.Offload.badInput")
            case .nodeNotStarted:
                return String(localized: "File.Offload.nodeNotStarted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "File.Offload.nodeNotStarted")
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
                return String(localized: "File.Reconcile.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "File.Reconcile.badInput")
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
                return String(localized: "File.SpaceOffload.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "File.SpaceOffload.badInput")
            case .nodeNotStarted:
                return String(localized: "File.SpaceOffload.nodeNotStarted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "File.SpaceOffload.nodeNotStarted")
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
                return String(localized: "File.SpaceUsage.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "File.SpaceUsage.badInput")
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
                return String(localized: "File.Upload.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "File.Upload.badInput")
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
                return String(localized: "Gallery.DownloadIndex.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Gallery.DownloadIndex.badInput")
            case .unmarshallingError:
                return String(localized: "Gallery.DownloadIndex.unmarshallingError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Gallery.DownloadIndex.unmarshallingError")
            case .downloadError:
                return String(localized: "Gallery.DownloadIndex.downloadError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Gallery.DownloadIndex.downloadError")
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
                return String(localized: "Gallery.DownloadManifest.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Gallery.DownloadManifest.badInput")
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
                return String(localized: "GenericErrorResponse.Error.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "GenericErrorResponse.Error.badInput")
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
                return String(localized: "History.DiffVersions.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "History.DiffVersions.badInput")
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
                return String(localized: "History.GetVersions.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "History.GetVersions.badInput")
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
                return String(localized: "History.SetVersion.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "History.SetVersion.badInput")
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
                return String(localized: "History.ShowVersion.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "History.ShowVersion.badInput")
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
                return String(localized: "Initial.SetParameters.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Initial.SetParameters.badInput")
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
                return String(localized: "LinkPreview.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "LinkPreview.badInput")
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
                return String(localized: "Log.Send.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Log.Send.badInput")
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
                return String(localized: "Membership.Finalize.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.Finalize.badInput")
            case .notLoggedIn:
                return String(localized: "Membership.Finalize.notLoggedIn", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.Finalize.notLoggedIn")
            case .paymentNodeError:
                return String(localized: "Membership.Finalize.paymentNodeError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.Finalize.paymentNodeError")
            case .cacheError:
                return String(localized: "Membership.Finalize.cacheError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.Finalize.cacheError")
            case .membershipNotFound:
                return String(localized: "Membership.Finalize.membershipNotFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.Finalize.membershipNotFound")
            case .membershipWrongState:
                return String(localized: "Membership.Finalize.membershipWrongState", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.Finalize.membershipWrongState")
            case .badAnyname:
                return String(localized: "Membership.Finalize.badAnyname", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.Finalize.badAnyname")
            case .canNotConnect:
                return String(localized: "Membership.Finalize.canNotConnect", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.Finalize.canNotConnect")
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
                return String(localized: "Membership.GetPortalLinkUrl.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetPortalLinkUrl.badInput")
            case .notLoggedIn:
                return String(localized: "Membership.GetPortalLinkUrl.notLoggedIn", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetPortalLinkUrl.notLoggedIn")
            case .paymentNodeError:
                return String(localized: "Membership.GetPortalLinkUrl.paymentNodeError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetPortalLinkUrl.paymentNodeError")
            case .cacheError:
                return String(localized: "Membership.GetPortalLinkUrl.cacheError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetPortalLinkUrl.cacheError")
            case .canNotConnect:
                return String(localized: "Membership.GetPortalLinkUrl.canNotConnect", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetPortalLinkUrl.canNotConnect")
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
                return String(localized: "Membership.GetStatus.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetStatus.badInput")
            case .notLoggedIn:
                return String(localized: "Membership.GetStatus.notLoggedIn", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetStatus.notLoggedIn")
            case .paymentNodeError:
                return String(localized: "Membership.GetStatus.paymentNodeError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetStatus.paymentNodeError")
            case .cacheError:
                return String(localized: "Membership.GetStatus.cacheError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetStatus.cacheError")
            case .membershipNotFound:
                return String(localized: "Membership.GetStatus.membershipNotFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetStatus.membershipNotFound")
            case .membershipWrongState:
                return String(localized: "Membership.GetStatus.membershipWrongState", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetStatus.membershipWrongState")
            case .canNotConnect:
                return String(localized: "Membership.GetStatus.canNotConnect", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetStatus.canNotConnect")
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
                return String(localized: "Membership.GetTiers.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetTiers.badInput")
            case .notLoggedIn:
                return String(localized: "Membership.GetTiers.notLoggedIn", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetTiers.notLoggedIn")
            case .paymentNodeError:
                return String(localized: "Membership.GetTiers.paymentNodeError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetTiers.paymentNodeError")
            case .cacheError:
                return String(localized: "Membership.GetTiers.cacheError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetTiers.cacheError")
            case .canNotConnect:
                return String(localized: "Membership.GetTiers.canNotConnect", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetTiers.canNotConnect")
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
                return String(localized: "Membership.GetVerificationEmail.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetVerificationEmail.badInput")
            case .notLoggedIn:
                return String(localized: "Membership.GetVerificationEmail.notLoggedIn", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetVerificationEmail.notLoggedIn")
            case .paymentNodeError:
                return String(localized: "Membership.GetVerificationEmail.paymentNodeError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetVerificationEmail.paymentNodeError")
            case .cacheError:
                return String(localized: "Membership.GetVerificationEmail.cacheError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetVerificationEmail.cacheError")
            case .emailWrongFormat:
                return String(localized: "Membership.GetVerificationEmail.emailWrongFormat", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetVerificationEmail.emailWrongFormat")
            case .emailAlreadyVerified:
                return String(localized: "Membership.GetVerificationEmail.emailAlreadyVerified", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetVerificationEmail.emailAlreadyVerified")
            case .emailAlredySent:
                return String(localized: "Membership.GetVerificationEmail.emailAlredySent", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetVerificationEmail.emailAlredySent")
            case .emailFailedToSend:
                return String(localized: "Membership.GetVerificationEmail.emailFailedToSend", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetVerificationEmail.emailFailedToSend")
            case .membershipAlreadyExists:
                return String(localized: "Membership.GetVerificationEmail.membershipAlreadyExists", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetVerificationEmail.membershipAlreadyExists")
            case .canNotConnect:
                return String(localized: "Membership.GetVerificationEmail.canNotConnect", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetVerificationEmail.canNotConnect")
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
                return String(localized: "Membership.GetVerificationEmailStatus.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetVerificationEmailStatus.badInput")
            case .notLoggedIn:
                return String(localized: "Membership.GetVerificationEmailStatus.notLoggedIn", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetVerificationEmailStatus.notLoggedIn")
            case .paymentNodeError:
                return String(localized: "Membership.GetVerificationEmailStatus.paymentNodeError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetVerificationEmailStatus.paymentNodeError")
            case .canNotConnect:
                return String(localized: "Membership.GetVerificationEmailStatus.canNotConnect", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.GetVerificationEmailStatus.canNotConnect")
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
                return String(localized: "Membership.IsNameValid.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.IsNameValid.badInput")
            case .tooShort:
                return String(localized: "Membership.IsNameValid.tooShort", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.IsNameValid.tooShort")
            case .tooLong:
                return String(localized: "Membership.IsNameValid.tooLong", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.IsNameValid.tooLong")
            case .hasInvalidChars:
                return String(localized: "Membership.IsNameValid.hasInvalidChars", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.IsNameValid.hasInvalidChars")
            case .tierFeaturesNoName:
                return String(localized: "Membership.IsNameValid.tierFeaturesNoName", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.IsNameValid.tierFeaturesNoName")
            case .tierNotFound:
                return String(localized: "Membership.IsNameValid.tierNotFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.IsNameValid.tierNotFound")
            case .notLoggedIn:
                return String(localized: "Membership.IsNameValid.notLoggedIn", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.IsNameValid.notLoggedIn")
            case .paymentNodeError:
                return String(localized: "Membership.IsNameValid.paymentNodeError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.IsNameValid.paymentNodeError")
            case .cacheError:
                return String(localized: "Membership.IsNameValid.cacheError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.IsNameValid.cacheError")
            case .canNotReserve:
                return String(localized: "Membership.IsNameValid.canNotReserve", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.IsNameValid.canNotReserve")
            case .canNotConnect:
                return String(localized: "Membership.IsNameValid.canNotConnect", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.IsNameValid.canNotConnect")
            case .nameIsReserved:
                return String(localized: "Membership.IsNameValid.nameIsReserved", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.IsNameValid.nameIsReserved")
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
                return String(localized: "Membership.RegisterPaymentRequest.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.RegisterPaymentRequest.badInput")
            case .notLoggedIn:
                return String(localized: "Membership.RegisterPaymentRequest.notLoggedIn", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.RegisterPaymentRequest.notLoggedIn")
            case .paymentNodeError:
                return String(localized: "Membership.RegisterPaymentRequest.paymentNodeError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.RegisterPaymentRequest.paymentNodeError")
            case .cacheError:
                return String(localized: "Membership.RegisterPaymentRequest.cacheError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.RegisterPaymentRequest.cacheError")
            case .tierNotFound:
                return String(localized: "Membership.RegisterPaymentRequest.tierNotFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.RegisterPaymentRequest.tierNotFound")
            case .tierInvalid:
                return String(localized: "Membership.RegisterPaymentRequest.tierInvalid", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.RegisterPaymentRequest.tierInvalid")
            case .paymentMethodInvalid:
                return String(localized: "Membership.RegisterPaymentRequest.paymentMethodInvalid", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.RegisterPaymentRequest.paymentMethodInvalid")
            case .badAnyname:
                return String(localized: "Membership.RegisterPaymentRequest.badAnyname", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.RegisterPaymentRequest.badAnyname")
            case .membershipAlreadyExists:
                return String(localized: "Membership.RegisterPaymentRequest.membershipAlreadyExists", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.RegisterPaymentRequest.membershipAlreadyExists")
            case .canNotConnect:
                return String(localized: "Membership.RegisterPaymentRequest.canNotConnect", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.RegisterPaymentRequest.canNotConnect")
            case .emailWrongFormat:
                return String(localized: "Membership.RegisterPaymentRequest.emailWrongFormat", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.RegisterPaymentRequest.emailWrongFormat")
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
                return String(localized: "Membership.VerifyAppStoreReceipt.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.VerifyAppStoreReceipt.badInput")
            case .notLoggedIn:
                return String(localized: "Membership.VerifyAppStoreReceipt.notLoggedIn", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.VerifyAppStoreReceipt.notLoggedIn")
            case .paymentNodeError:
                return String(localized: "Membership.VerifyAppStoreReceipt.paymentNodeError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.VerifyAppStoreReceipt.paymentNodeError")
            case .cacheError:
                return String(localized: "Membership.VerifyAppStoreReceipt.cacheError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.VerifyAppStoreReceipt.cacheError")
            case .invalidReceipt:
                return String(localized: "Membership.VerifyAppStoreReceipt.invalidReceipt", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.VerifyAppStoreReceipt.invalidReceipt")
            case .purchaseRegistrationError:
                return String(localized: "Membership.VerifyAppStoreReceipt.purchaseRegistrationError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.VerifyAppStoreReceipt.purchaseRegistrationError")
            case .subscriptionRenewError:
                return String(localized: "Membership.VerifyAppStoreReceipt.subscriptionRenewError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.VerifyAppStoreReceipt.subscriptionRenewError")
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
                return String(localized: "Membership.VerifyEmailCode.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.VerifyEmailCode.badInput")
            case .notLoggedIn:
                return String(localized: "Membership.VerifyEmailCode.notLoggedIn", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.VerifyEmailCode.notLoggedIn")
            case .paymentNodeError:
                return String(localized: "Membership.VerifyEmailCode.paymentNodeError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.VerifyEmailCode.paymentNodeError")
            case .cacheError:
                return String(localized: "Membership.VerifyEmailCode.cacheError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.VerifyEmailCode.cacheError")
            case .emailAlreadyVerified:
                return String(localized: "Membership.VerifyEmailCode.emailAlreadyVerified", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.VerifyEmailCode.emailAlreadyVerified")
            case .expired:
                return String(localized: "Membership.VerifyEmailCode.expired", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.VerifyEmailCode.expired")
            case .wrong:
                return String(localized: "Membership.VerifyEmailCode.wrong", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.VerifyEmailCode.wrong")
            case .membershipNotFound:
                return String(localized: "Membership.VerifyEmailCode.membershipNotFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.VerifyEmailCode.membershipNotFound")
            case .membershipAlreadyActive:
                return String(localized: "Membership.VerifyEmailCode.membershipAlreadyActive", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.VerifyEmailCode.membershipAlreadyActive")
            case .canNotConnect:
                return String(localized: "Membership.VerifyEmailCode.canNotConnect", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Membership.VerifyEmailCode.canNotConnect")
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
                return String(localized: "NameService.ResolveAnyId.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "NameService.ResolveAnyId.badInput")
            case .canNotConnect:
                return String(localized: "NameService.ResolveAnyId.canNotConnect", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "NameService.ResolveAnyId.canNotConnect")
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
                return String(localized: "NameService.ResolveName.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "NameService.ResolveName.badInput")
            case .canNotConnect:
                return String(localized: "NameService.ResolveName.canNotConnect", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "NameService.ResolveName.canNotConnect")
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
                return String(localized: "NameService.ResolveSpaceId.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "NameService.ResolveSpaceId.badInput")
            case .canNotConnect:
                return String(localized: "NameService.ResolveSpaceId.canNotConnect", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "NameService.ResolveSpaceId.canNotConnect")
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
                return String(localized: "NameService.UserAccount.Get.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "NameService.UserAccount.Get.badInput")
            case .notLoggedIn:
                return String(localized: "NameService.UserAccount.Get.notLoggedIn", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "NameService.UserAccount.Get.notLoggedIn")
            case .badNameResolve:
                return String(localized: "NameService.UserAccount.Get.badNameResolve", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "NameService.UserAccount.Get.badNameResolve")
            case .canNotConnect:
                return String(localized: "NameService.UserAccount.Get.canNotConnect", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "NameService.UserAccount.Get.canNotConnect")
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
                return String(localized: "Navigation.GetObjectInfoWithLinks.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Navigation.GetObjectInfoWithLinks.badInput")
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
                return String(localized: "Navigation.ListObjects.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Navigation.ListObjects.badInput")
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
                return String(localized: "Notification.List.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Notification.List.badInput")
            case .internalError:
                return String(localized: "Notification.List.internalError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Notification.List.internalError")
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
                return String(localized: "Notification.Reply.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Notification.Reply.badInput")
            case .internalError:
                return String(localized: "Notification.Reply.internalError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Notification.Reply.internalError")
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
                return String(localized: "Notification.Test.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Notification.Test.badInput")
            case .internalError:
                return String(localized: "Notification.Test.internalError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Notification.Test.internalError")
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
                return String(localized: "Object.ApplyTemplate.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.ApplyTemplate.badInput")
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
                return String(localized: "Object.BookmarkFetch.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.BookmarkFetch.badInput")
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
                return String(localized: "Object.ChatAdd.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.ChatAdd.badInput")
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
                return String(localized: "Object.Close.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Close.badInput")
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
                return String(localized: "Object.Create.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Create.badInput")
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
                return String(localized: "Object.CreateBookmark.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.CreateBookmark.badInput")
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
                return String(localized: "Object.CreateFromUrl.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.CreateFromUrl.badInput")
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
                return String(localized: "Object.CreateObjectType.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.CreateObjectType.badInput")
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
                return String(localized: "Object.CreateRelation.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.CreateRelation.badInput")
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
                return String(localized: "Object.CreateRelationOption.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.CreateRelationOption.badInput")
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
                return String(localized: "Object.CreateSet.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.CreateSet.badInput")
            case .unknownObjectTypeURL:
                return String(localized: "Object.CreateSet.unknownObjectTypeURL", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.CreateSet.unknownObjectTypeURL")
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
                return String(localized: "Object.CrossSpaceSearchSubscribe.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.CrossSpaceSearchSubscribe.badInput")
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
                return String(localized: "Object.CrossSpaceSearchUnsubscribe.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.CrossSpaceSearchUnsubscribe.badInput")
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
                return String(localized: "Object.DateByTimestamp.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.DateByTimestamp.badInput")
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
                return String(localized: "Object.Duplicate.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Duplicate.badInput")
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
                return String(localized: "Object.Export.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Export.badInput")
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
                return String(localized: "Object.Graph.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Graph.badInput")
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
                return String(localized: "Object.GroupsSubscribe.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.GroupsSubscribe.badInput")
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
                return String(localized: "Object.Import.Notion.ValidateToken.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Import.Notion.ValidateToken.badInput")
            case .internalError:
                return String(localized: "Object.Import.Notion.ValidateToken.internalError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Import.Notion.ValidateToken.internalError")
            case .unauthorized:
                return String(localized: "Object.Import.Notion.ValidateToken.unauthorized", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Import.Notion.ValidateToken.unauthorized")
            case .forbidden:
                return String(localized: "Object.Import.Notion.ValidateToken.forbidden", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Import.Notion.ValidateToken.forbidden")
            case .serviceUnavailable:
                return String(localized: "Object.Import.Notion.ValidateToken.serviceUnavailable", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Import.Notion.ValidateToken.serviceUnavailable")
            case .accountIsNotRunning:
                return String(localized: "Object.Import.Notion.ValidateToken.accountIsNotRunning", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Import.Notion.ValidateToken.accountIsNotRunning")
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
                return String(localized: "Object.Import.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Import.badInput")
            case .internalError:
                return String(localized: "Object.Import.internalError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Import.internalError")
            case .noObjectsToImport:
                return String(localized: "Object.Import.noObjectsToImport", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Import.noObjectsToImport")
            case .importIsCanceled:
                return String(localized: "Object.Import.importIsCanceled", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Import.importIsCanceled")
            case .limitOfRowsOrRelationsExceeded:
                return String(localized: "Object.Import.limitOfRowsOrRelationsExceeded", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Import.limitOfRowsOrRelationsExceeded")
            case .fileLoadError:
                return String(localized: "Object.Import.fileLoadError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Import.fileLoadError")
            case .insufficientPermissions:
                return String(localized: "Object.Import.insufficientPermissions", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Import.insufficientPermissions")
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
                return String(localized: "Object.ImportExperience.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.ImportExperience.badInput")
            case .insufficientPermission:
                return String(localized: "Object.ImportExperience.insufficientPermission", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.ImportExperience.insufficientPermission")
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
                return String(localized: "Object.ImportList.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.ImportList.badInput")
            case .internalError:
                return String(localized: "Object.ImportList.internalError", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.ImportList.internalError")
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
                return String(localized: "Object.ImportUseCase.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.ImportUseCase.badInput")
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
                return String(localized: "Object.ListDelete.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.ListDelete.badInput")
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
                return String(localized: "Object.ListDuplicate.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.ListDuplicate.badInput")
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
                return String(localized: "Object.ListExport.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.ListExport.badInput")
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
                return String(localized: "Object.ListModifyDetailValues.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.ListModifyDetailValues.badInput")
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
                return String(localized: "Object.ListSetDetails.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.ListSetDetails.badInput")
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
                return String(localized: "Object.ListSetIsArchived.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.ListSetIsArchived.badInput")
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
                return String(localized: "Object.ListSetIsFavorite.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.ListSetIsFavorite.badInput")
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
                return String(localized: "Object.ListSetObjectType.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.ListSetObjectType.badInput")
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
                return String(localized: "Object.Open.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Open.badInput")
            case .notFound:
                return String(localized: "Object.Open.notFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Open.notFound")
            case .anytypeNeedsUpgrade:
                return String(localized: "Object.Open.anytypeNeedsUpgrade", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Open.anytypeNeedsUpgrade")
            case .objectDeleted:
                return String(localized: "Object.Open.objectDeleted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Open.objectDeleted")
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
                return String(localized: "Object.OpenBreadcrumbs.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.OpenBreadcrumbs.badInput")
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
                return String(localized: "Object.Redo.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Redo.badInput")
            case .canNotMove:
                return String(localized: "Object.Redo.canNotMove", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Redo.canNotMove")
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
                return String(localized: "Object.Search.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Search.badInput")
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
                return String(localized: "Object.SearchSubscribe.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.SearchSubscribe.badInput")
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
                return String(localized: "Object.SearchUnsubscribe.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.SearchUnsubscribe.badInput")
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
                return String(localized: "Object.SearchWithMeta.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.SearchWithMeta.badInput")
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
                return String(localized: "Object.SetBreadcrumbs.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.SetBreadcrumbs.badInput")
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
                return String(localized: "Object.SetDetails.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.SetDetails.badInput")
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
                return String(localized: "Object.SetInternalFlags.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.SetInternalFlags.badInput")
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
                return String(localized: "Object.SetIsArchived.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.SetIsArchived.badInput")
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
                return String(localized: "Object.SetIsFavorite.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.SetIsFavorite.badInput")
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
                return String(localized: "Object.SetLayout.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.SetLayout.badInput")
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
                return String(localized: "Object.SetObjectType.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.SetObjectType.badInput")
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
                return String(localized: "Object.SetSource.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.SetSource.badInput")
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
                return String(localized: "Object.ShareByLink.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.ShareByLink.badInput")
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
                return String(localized: "Object.Show.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Show.badInput")
            case .notFound:
                return String(localized: "Object.Show.notFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Show.notFound")
            case .objectDeleted:
                return String(localized: "Object.Show.objectDeleted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Show.objectDeleted")
            case .anytypeNeedsUpgrade:
                return String(localized: "Object.Show.anytypeNeedsUpgrade", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Show.anytypeNeedsUpgrade")
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
                return String(localized: "Object.SubscribeIds.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.SubscribeIds.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}

extension Anytype_Rpc.Object.ToBookmark.Response.Error: LocalizedError {
    public var errorDescription: String? {
        let localizeError = localizeError()
        if !localizeError.isEmpty {
            return localizeError
        }
        return "Error: \(description_p) (\(code))"
    }

    private func localizeError() -> String {
        switch code {
            case .null:
                return ""
            case .unknownError:
                return ""
            case .badInput:
                return String(localized: "Object.ToBookmark.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.ToBookmark.badInput")
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
                return String(localized: "Object.ToCollection.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.ToCollection.badInput")
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
                return String(localized: "Object.ToSet.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.ToSet.badInput")
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
                return String(localized: "Object.Undo.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Undo.badInput")
            case .canNotMove:
                return String(localized: "Object.Undo.canNotMove", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.Undo.canNotMove")
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
                return String(localized: "Object.WorkspaceSetDashboard.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Object.WorkspaceSetDashboard.badInput")
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
                return String(localized: "ObjectCollection.Add.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "ObjectCollection.Add.badInput")
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
                return String(localized: "ObjectCollection.Remove.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "ObjectCollection.Remove.badInput")
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
                return String(localized: "ObjectCollection.Sort.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "ObjectCollection.Sort.badInput")
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
                return String(localized: "ObjectRelation.Add.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "ObjectRelation.Add.badInput")
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
                return String(localized: "ObjectRelation.AddFeatured.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "ObjectRelation.AddFeatured.badInput")
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
                return String(localized: "ObjectRelation.Delete.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "ObjectRelation.Delete.badInput")
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
                return String(localized: "ObjectRelation.ListAvailable.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "ObjectRelation.ListAvailable.badInput")
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
                return String(localized: "ObjectRelation.RemoveFeatured.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "ObjectRelation.RemoveFeatured.badInput")
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
                return String(localized: "ObjectType.ListConflictingRelations.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "ObjectType.ListConflictingRelations.badInput")
            case .readonlyObjectType:
                return String(localized: "ObjectType.ListConflictingRelations.readonlyObjectType", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "ObjectType.ListConflictingRelations.readonlyObjectType")
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
                return String(localized: "ObjectType.Recommended.FeaturedRelationsSet.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "ObjectType.Recommended.FeaturedRelationsSet.badInput")
            case .readonlyObjectType:
                return String(localized: "ObjectType.Recommended.FeaturedRelationsSet.readonlyObjectType", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "ObjectType.Recommended.FeaturedRelationsSet.readonlyObjectType")
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
                return String(localized: "ObjectType.Recommended.RelationsSet.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "ObjectType.Recommended.RelationsSet.badInput")
            case .readonlyObjectType:
                return String(localized: "ObjectType.Recommended.RelationsSet.readonlyObjectType", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "ObjectType.Recommended.RelationsSet.readonlyObjectType")
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
                return String(localized: "ObjectType.Relation.Add.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "ObjectType.Relation.Add.badInput")
            case .readonlyObjectType:
                return String(localized: "ObjectType.Relation.Add.readonlyObjectType", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "ObjectType.Relation.Add.readonlyObjectType")
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
                return String(localized: "ObjectType.Relation.Remove.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "ObjectType.Relation.Remove.badInput")
            case .readonlyObjectType:
                return String(localized: "ObjectType.Relation.Remove.readonlyObjectType", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "ObjectType.Relation.Remove.readonlyObjectType")
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
                return String(localized: "Process.Cancel.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Process.Cancel.badInput")
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
                return String(localized: "Process.Subscribe.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Process.Subscribe.badInput")
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
                return String(localized: "Process.Unsubscribe.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Process.Unsubscribe.badInput")
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
                return String(localized: "Publishing.Create.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Publishing.Create.badInput")
            case .noSuchObject:
                return String(localized: "Publishing.Create.noSuchObject", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Publishing.Create.noSuchObject")
            case .noSuchSpace:
                return String(localized: "Publishing.Create.noSuchSpace", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Publishing.Create.noSuchSpace")
            case .limitExceeded:
                return String(localized: "Publishing.Create.limitExceeded", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Publishing.Create.limitExceeded")
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
                return String(localized: "Publishing.GetStatus.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Publishing.GetStatus.badInput")
            case .noSuchObject:
                return String(localized: "Publishing.GetStatus.noSuchObject", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Publishing.GetStatus.noSuchObject")
            case .noSuchSpace:
                return String(localized: "Publishing.GetStatus.noSuchSpace", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Publishing.GetStatus.noSuchSpace")
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
                return String(localized: "Publishing.List.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Publishing.List.badInput")
            case .noSuchSpace:
                return String(localized: "Publishing.List.noSuchSpace", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Publishing.List.noSuchSpace")
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
                return String(localized: "Publishing.Remove.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Publishing.Remove.badInput")
            case .noSuchObject:
                return String(localized: "Publishing.Remove.noSuchObject", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Publishing.Remove.noSuchObject")
            case .noSuchSpace:
                return String(localized: "Publishing.Remove.noSuchSpace", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Publishing.Remove.noSuchSpace")
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
                return String(localized: "Publishing.ResolveUri.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Publishing.ResolveUri.badInput")
            case .noSuchUri:
                return String(localized: "Publishing.ResolveUri.noSuchUri", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Publishing.ResolveUri.noSuchUri")
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
                return String(localized: "Relation.ListRemoveOption.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Relation.ListRemoveOption.badInput")
            case .optionUsedByObjects:
                return String(localized: "Relation.ListRemoveOption.optionUsedByObjects", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Relation.ListRemoveOption.optionUsedByObjects")
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
                return String(localized: "Relation.ListWithValue.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Relation.ListWithValue.badInput")
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
                return String(localized: "Relation.Options.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Relation.Options.badInput")
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
                return String(localized: "Space.Delete.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.Delete.badInput")
            case .noSuchSpace:
                return String(localized: "Space.Delete.noSuchSpace", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.Delete.noSuchSpace")
            case .spaceIsDeleted:
                return String(localized: "Space.Delete.spaceIsDeleted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.Delete.spaceIsDeleted")
            case .requestFailed:
                return String(localized: "Space.Delete.requestFailed", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.Delete.requestFailed")
            case .limitReached:
                return String(localized: "Space.Delete.limitReached", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.Delete.limitReached")
            case .notShareable:
                return String(localized: "Space.Delete.notShareable", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.Delete.notShareable")
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
                return String(localized: "Space.InviteGenerate.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteGenerate.badInput")
            case .noSuchSpace:
                return String(localized: "Space.InviteGenerate.noSuchSpace", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteGenerate.noSuchSpace")
            case .spaceIsDeleted:
                return String(localized: "Space.InviteGenerate.spaceIsDeleted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteGenerate.spaceIsDeleted")
            case .requestFailed:
                return String(localized: "Space.InviteGenerate.requestFailed", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteGenerate.requestFailed")
            case .limitReached:
                return String(localized: "Space.InviteGenerate.limitReached", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteGenerate.limitReached")
            case .notShareable:
                return String(localized: "Space.InviteGenerate.notShareable", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteGenerate.notShareable")
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
                return String(localized: "Space.InviteGetCurrent.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteGetCurrent.badInput")
            case .noActiveInvite:
                return String(localized: "Space.InviteGetCurrent.noActiveInvite", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteGetCurrent.noActiveInvite")
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
                return String(localized: "Space.InviteGetGuest.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteGetGuest.badInput")
            case .invalidSpaceType:
                return String(localized: "Space.InviteGetGuest.invalidSpaceType", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteGetGuest.invalidSpaceType")
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
                return String(localized: "Space.InviteRevoke.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteRevoke.badInput")
            case .noSuchSpace:
                return String(localized: "Space.InviteRevoke.noSuchSpace", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteRevoke.noSuchSpace")
            case .spaceIsDeleted:
                return String(localized: "Space.InviteRevoke.spaceIsDeleted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteRevoke.spaceIsDeleted")
            case .limitReached:
                return String(localized: "Space.InviteRevoke.limitReached", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteRevoke.limitReached")
            case .requestFailed:
                return String(localized: "Space.InviteRevoke.requestFailed", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteRevoke.requestFailed")
            case .notShareable:
                return String(localized: "Space.InviteRevoke.notShareable", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteRevoke.notShareable")
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
                return String(localized: "Space.InviteView.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteView.badInput")
            case .inviteNotFound:
                return String(localized: "Space.InviteView.inviteNotFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteView.inviteNotFound")
            case .inviteBadContent:
                return String(localized: "Space.InviteView.inviteBadContent", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteView.inviteBadContent")
            case .spaceIsDeleted:
                return String(localized: "Space.InviteView.spaceIsDeleted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.InviteView.spaceIsDeleted")
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
                return String(localized: "Space.Join.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.Join.badInput")
            case .noSuchSpace:
                return String(localized: "Space.Join.noSuchSpace", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.Join.noSuchSpace")
            case .spaceIsDeleted:
                return String(localized: "Space.Join.spaceIsDeleted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.Join.spaceIsDeleted")
            case .inviteNotFound:
                return String(localized: "Space.Join.inviteNotFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.Join.inviteNotFound")
            case .inviteBadContent:
                return String(localized: "Space.Join.inviteBadContent", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.Join.inviteBadContent")
            case .requestFailed:
                return String(localized: "Space.Join.requestFailed", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.Join.requestFailed")
            case .limitReached:
                return String(localized: "Space.Join.limitReached", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.Join.limitReached")
            case .notShareable:
                return String(localized: "Space.Join.notShareable", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.Join.notShareable")
            case .differentNetwork:
                return String(localized: "Space.Join.differentNetwork", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.Join.differentNetwork")
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
                return String(localized: "Space.JoinCancel.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.JoinCancel.badInput")
            case .noSuchSpace:
                return String(localized: "Space.JoinCancel.noSuchSpace", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.JoinCancel.noSuchSpace")
            case .spaceIsDeleted:
                return String(localized: "Space.JoinCancel.spaceIsDeleted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.JoinCancel.spaceIsDeleted")
            case .requestFailed:
                return String(localized: "Space.JoinCancel.requestFailed", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.JoinCancel.requestFailed")
            case .limitReached:
                return String(localized: "Space.JoinCancel.limitReached", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.JoinCancel.limitReached")
            case .noSuchRequest:
                return String(localized: "Space.JoinCancel.noSuchRequest", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.JoinCancel.noSuchRequest")
            case .notShareable:
                return String(localized: "Space.JoinCancel.notShareable", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.JoinCancel.notShareable")
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
                return String(localized: "Space.LeaveApprove.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.LeaveApprove.badInput")
            case .noSuchSpace:
                return String(localized: "Space.LeaveApprove.noSuchSpace", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.LeaveApprove.noSuchSpace")
            case .spaceIsDeleted:
                return String(localized: "Space.LeaveApprove.spaceIsDeleted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.LeaveApprove.spaceIsDeleted")
            case .requestFailed:
                return String(localized: "Space.LeaveApprove.requestFailed", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.LeaveApprove.requestFailed")
            case .limitReached:
                return String(localized: "Space.LeaveApprove.limitReached", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.LeaveApprove.limitReached")
            case .noApproveRequests:
                return String(localized: "Space.LeaveApprove.noApproveRequests", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.LeaveApprove.noApproveRequests")
            case .notShareable:
                return String(localized: "Space.LeaveApprove.notShareable", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.LeaveApprove.notShareable")
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
                return String(localized: "Space.MakeShareable.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.MakeShareable.badInput")
            case .noSuchSpace:
                return String(localized: "Space.MakeShareable.noSuchSpace", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.MakeShareable.noSuchSpace")
            case .spaceIsDeleted:
                return String(localized: "Space.MakeShareable.spaceIsDeleted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.MakeShareable.spaceIsDeleted")
            case .requestFailed:
                return String(localized: "Space.MakeShareable.requestFailed", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.MakeShareable.requestFailed")
            case .limitReached:
                return String(localized: "Space.MakeShareable.limitReached", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.MakeShareable.limitReached")
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
                return String(localized: "Space.ParticipantPermissionsChange.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.ParticipantPermissionsChange.badInput")
            case .noSuchSpace:
                return String(localized: "Space.ParticipantPermissionsChange.noSuchSpace", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.ParticipantPermissionsChange.noSuchSpace")
            case .spaceIsDeleted:
                return String(localized: "Space.ParticipantPermissionsChange.spaceIsDeleted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.ParticipantPermissionsChange.spaceIsDeleted")
            case .requestFailed:
                return String(localized: "Space.ParticipantPermissionsChange.requestFailed", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.ParticipantPermissionsChange.requestFailed")
            case .limitReached:
                return String(localized: "Space.ParticipantPermissionsChange.limitReached", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.ParticipantPermissionsChange.limitReached")
            case .participantNotFound:
                return String(localized: "Space.ParticipantPermissionsChange.participantNotFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.ParticipantPermissionsChange.participantNotFound")
            case .incorrectPermissions:
                return String(localized: "Space.ParticipantPermissionsChange.incorrectPermissions", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.ParticipantPermissionsChange.incorrectPermissions")
            case .notShareable:
                return String(localized: "Space.ParticipantPermissionsChange.notShareable", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.ParticipantPermissionsChange.notShareable")
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
                return String(localized: "Space.ParticipantRemove.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.ParticipantRemove.badInput")
            case .noSuchSpace:
                return String(localized: "Space.ParticipantRemove.noSuchSpace", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.ParticipantRemove.noSuchSpace")
            case .spaceIsDeleted:
                return String(localized: "Space.ParticipantRemove.spaceIsDeleted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.ParticipantRemove.spaceIsDeleted")
            case .participantNotFound:
                return String(localized: "Space.ParticipantRemove.participantNotFound", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.ParticipantRemove.participantNotFound")
            case .requestFailed:
                return String(localized: "Space.ParticipantRemove.requestFailed", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.ParticipantRemove.requestFailed")
            case .limitReached:
                return String(localized: "Space.ParticipantRemove.limitReached", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.ParticipantRemove.limitReached")
            case .notShareable:
                return String(localized: "Space.ParticipantRemove.notShareable", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.ParticipantRemove.notShareable")
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
                return String(localized: "Space.RequestApprove.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.RequestApprove.badInput")
            case .noSuchSpace:
                return String(localized: "Space.RequestApprove.noSuchSpace", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.RequestApprove.noSuchSpace")
            case .spaceIsDeleted:
                return String(localized: "Space.RequestApprove.spaceIsDeleted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.RequestApprove.spaceIsDeleted")
            case .noSuchRequest:
                return String(localized: "Space.RequestApprove.noSuchRequest", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.RequestApprove.noSuchRequest")
            case .incorrectPermissions:
                return String(localized: "Space.RequestApprove.incorrectPermissions", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.RequestApprove.incorrectPermissions")
            case .requestFailed:
                return String(localized: "Space.RequestApprove.requestFailed", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.RequestApprove.requestFailed")
            case .limitReached:
                return String(localized: "Space.RequestApprove.limitReached", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.RequestApprove.limitReached")
            case .notShareable:
                return String(localized: "Space.RequestApprove.notShareable", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.RequestApprove.notShareable")
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
                return String(localized: "Space.RequestDecline.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.RequestDecline.badInput")
            case .noSuchSpace:
                return String(localized: "Space.RequestDecline.noSuchSpace", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.RequestDecline.noSuchSpace")
            case .spaceIsDeleted:
                return String(localized: "Space.RequestDecline.spaceIsDeleted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.RequestDecline.spaceIsDeleted")
            case .requestFailed:
                return String(localized: "Space.RequestDecline.requestFailed", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.RequestDecline.requestFailed")
            case .limitReached:
                return String(localized: "Space.RequestDecline.limitReached", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.RequestDecline.limitReached")
            case .noSuchRequest:
                return String(localized: "Space.RequestDecline.noSuchRequest", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.RequestDecline.noSuchRequest")
            case .notShareable:
                return String(localized: "Space.RequestDecline.notShareable", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.RequestDecline.notShareable")
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
                return String(localized: "Space.SetOrder.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.SetOrder.badInput")
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
                return String(localized: "Space.StopSharing.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.StopSharing.badInput")
            case .noSuchSpace:
                return String(localized: "Space.StopSharing.noSuchSpace", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.StopSharing.noSuchSpace")
            case .spaceIsDeleted:
                return String(localized: "Space.StopSharing.spaceIsDeleted", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.StopSharing.spaceIsDeleted")
            case .requestFailed:
                return String(localized: "Space.StopSharing.requestFailed", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.StopSharing.requestFailed")
            case .limitReached:
                return String(localized: "Space.StopSharing.limitReached", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.StopSharing.limitReached")
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
                return String(localized: "Space.UnsetOrder.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Space.UnsetOrder.badInput")
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
                return String(localized: "Template.Clone.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Template.Clone.badInput")
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
                return String(localized: "Template.CreateFromObject.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Template.CreateFromObject.badInput")
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
                return String(localized: "Template.ExportAll.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Template.ExportAll.badInput")
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
                return String(localized: "Unsplash.Download.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Unsplash.Download.badInput")
            case .rateLimitExceeded:
                return String(localized: "Unsplash.Download.rateLimitExceeded", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Unsplash.Download.rateLimitExceeded")
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
                return String(localized: "Unsplash.Search.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Unsplash.Search.badInput")
            case .rateLimitExceeded:
                return String(localized: "Unsplash.Search.rateLimitExceeded", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Unsplash.Search.rateLimitExceeded")
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
                return String(localized: "Wallet.CloseSession.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Wallet.CloseSession.badInput")
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
                return String(localized: "Wallet.Convert.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Wallet.Convert.badInput")
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
                return String(localized: "Wallet.Create.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Wallet.Create.badInput")
            case .failedToCreateLocalRepo:
                return String(localized: "Wallet.Create.failedToCreateLocalRepo", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Wallet.Create.failedToCreateLocalRepo")
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
                return String(localized: "Wallet.CreateSession.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Wallet.CreateSession.badInput")
            case .appTokenNotFoundInTheCurrentAccount:
                return String(localized: "Wallet.CreateSession.appTokenNotFoundInTheCurrentAccount", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Wallet.CreateSession.appTokenNotFoundInTheCurrentAccount")
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
                return String(localized: "Wallet.Recover.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Wallet.Recover.badInput")
            case .failedToCreateLocalRepo:
                return String(localized: "Wallet.Recover.failedToCreateLocalRepo", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Wallet.Recover.failedToCreateLocalRepo")
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
                return String(localized: "Workspace.Create.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Workspace.Create.badInput")
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
                return String(localized: "Workspace.Export.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Workspace.Export.badInput")
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
                return String(localized: "Workspace.GetAll.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Workspace.GetAll.badInput")
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
                return String(localized: "Workspace.GetCurrent.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Workspace.GetCurrent.badInput")
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
                return String(localized: "Workspace.Object.Add.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Workspace.Object.Add.badInput")
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
                return String(localized: "Workspace.Object.ListAdd.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Workspace.Object.ListAdd.badInput")
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
                return String(localized: "Workspace.Object.ListRemove.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Workspace.Object.ListRemove.badInput")
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
                return String(localized: "Workspace.Open.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Workspace.Open.badInput")
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
                return String(localized: "Workspace.Select.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Workspace.Select.badInput")
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
                return String(localized: "Workspace.SetInfo.badInput", defaultValue: "", table: "LocalizableError")
                    .checkValue(key: "Workspace.SetInfo.badInput")
            case .UNRECOGNIZED:
                return ""
        }
    }
}


private extension String {
    // If default value is emplty, Apple return key. But we expect that localziation return empty string
    func checkValue(key: String) -> String {
        if self == key {
            return ""
        } else {
            return self
        }
    }
}
