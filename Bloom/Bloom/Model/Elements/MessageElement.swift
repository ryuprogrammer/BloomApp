import Foundation
import FirebaseFirestore

struct MessageElement: Codable, Hashable, Identifiable {
    @DocumentID var id: String?
    var uuid = UUID()
    var uid: String
    var roomID: String
    var isNewMessage: Bool
    var name: String
    var message: String
    var createAt: Date
}
