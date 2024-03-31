import Foundation

enum AccountStatus {
    /// 完全にアカウントがない
    case none
    /// アカウントはあるが、プロフィール情報がない
    case existsNoProfile
    /// アカウントもプロフィールも正常にある
    case valid
    /// アカウントもプロフィールもあるが、idが一致しない
    case mismatchID
    /// 通報回数が上限を超えて、アカウント停止
    case stopAccount
}
