import Foundation

struct HobbyEditViewModel {
    let loadFileDataModel = LoadFileDataModel()

    /// hobbyDataを取得
    func fetchHobbyData() -> [String] {
        guard let hobbys = loadFileDataModel.loadCsvFile(fileName: "HobbyList") else {
            return []
        }

        return hobbys
    }
}
