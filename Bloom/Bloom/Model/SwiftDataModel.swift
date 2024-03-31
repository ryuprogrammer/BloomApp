import Foundation
import SwiftData

struct SwiftDataModel {
    
    // MARK: - TalkFriendElement: トークしてる友達
    // TalkFriendElementの全削除
    func deleteTalkFriendElement(context: ModelContext) {
        do {
            try context.delete(model: FriendListRowElement.self, includeSubclasses: true)
        } catch {
            print("SwiftDataの削除でエラー: \(error.localizedDescription)")
        }
    }
    
    /// TalkFriendElementの追加（１つ）
    func addFriendListRowElement(
        context: ModelContext,
        friendListRowElement: FriendListRowElement
    ) {
        context.insert(friendListRowElement)
        
        do {
            try context.save()
            print("追加成功ーーーーーーー！")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - SwipeFriendElement: スワイプに表示する人
    /// TalkFriendElementの全削除
    func deleteAllSwipeFriendElement(context: ModelContext) {
        print("これから削除する")
        do {
            try context.delete(model: SwipeFriendElement.self, includeSubclasses: true)
            print("削除してる")
        } catch {
            print("SwiftDataの削除でエラー: \(error.localizedDescription)")
        }
    }
    
    /// TalkFriendElementの追加（１つ）
    func addSwipeFriendElement(
        context: ModelContext,
        swipeFriendElement: SwipeFriendElement
    ) {
        context.insert(swipeFriendElement)
        
        do {
            try context.save()
            print("追加成功ーーーーーーー！")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// TalkFriendElementの削除（１つ）
    func deleteSwipeFriendElement(
        context: ModelContext,
        swipeFriendElement: SwipeFriendElement
    ) {
        print("削除するよ")
        print("このデータを削除: \(swipeFriendElement.profile.id)")
        print("このデータを削除: \(swipeFriendElement.profile.userName)")
        
        do {
            let id = swipeFriendElement.profile.id
            try context.delete(
                model: SwipeFriendElement.self,
                where: #Predicate<SwipeFriendElement> {
                    $0.profile.id == id
                }
            )
            
            try context.save()
            print("削除成功ーーーーーーー！")
        } catch {
            // エラーが発生した場合に呼び出し元に通知する
            fatalError("データの削除中にエラーが発生しました： \(error.localizedDescription)")
        }
    }
}
