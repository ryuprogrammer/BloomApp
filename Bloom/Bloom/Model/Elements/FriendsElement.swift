import Foundation
import FirebaseFirestore

struct FriendsElement: Codable {
    @DocumentID var id: String?
    var friendUid: String
    var status: FriendStatus
}

enum FriendStatus: String, Codable {
    /// トークしている人
    case talking = "トークしている人"
    /// マッチした人: トーク画面などで使用→ 両方
    case matchd = "マッチした人"
    /// ライクされた人: 相手からのライク確認画面で使用→ 相手
    case likeByFriend = "ライクされた人"
    /// ライクした人: SwipeViewに再表示しないために使用→ 自分
    case likeByMe = "ライクした人"
    /// アンライクした人: 二度と表示しないために使用→ 自分
    case unLikeByMe = "アンライクした人"
    /// ブロックされた人→ 相手
    case blockByFriend = "ブロックされた人"
    /// ブロックした人→ 自分
    case blockByMy = "ブロックした人"
    /// 通報した人
    case reportByFriend = "この人に通報された"

    var id: String { rawValue }
}
