import Foundation

struct LoadFileDataModel {
    /// テキストファイルの読み込み
    func readFile(fileCase: FileCase) async -> String {
        guard let fileURL = Bundle.main.url(forResource: fileCase.rawValue, withExtension: "txt"),
              let fileContents = try? String(contentsOf: fileURL, encoding: .utf8) else {
            fatalError("ファイルの読み込みができません")
        }

        return fileContents
    }

    /// csvファイルの読み込み
    func loadCsvFile(fileName: String) -> [String]? {
        var csvLines: [String] = []

        // ファイルが存在するかチェック
        guard let path = Bundle.main.path(forResource: fileName, ofType: "csv") else { return nil }

        do {
            // ファイルが存在していれば、データを読み込み
            let csvString = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            // 「,」ごとにデータを分割して配列に格納
            csvLines = csvString.components(separatedBy: ",")
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }

        for text in csvLines {
            print(text)
        }

        return csvLines
    }
}

enum FileCase: String {
    case service = "serviceDescription"
    case privacy = "privacyDescription"
    case delete = "deleteDescription"
}
