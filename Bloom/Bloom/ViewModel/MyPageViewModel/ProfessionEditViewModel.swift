import Foundation

struct ProfessionEditViewModel {
    let loadFileDataModel = LoadFileDataModel()

    /// hobbyDataを取得
    func fetchProfessionData() -> [String] {
        guard let professions = loadFileDataModel.loadCsvFile(fileName: "ProfessionList") else {
            return []
        }

        return professions
    }
}
