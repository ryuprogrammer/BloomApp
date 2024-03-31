import SwiftUI

struct DataImage: View {
    let dataImage: Data
    @State var repeatImage = false
    var body: some View {
        if let uiImage = UIImage(data: dataImage) {
            Image(uiImage: uiImage)
                .resizable()
        } else {
            Image(systemName: "hourglass")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundStyle(Color.pink.opacity(0.5))
                .symbolEffect(.bounce.up.byLayer, options: .repeating, value: repeatImage)
                .onAppear {
                    repeatImage.toggle()
                }
        }
    }
}

#Preview {
    DataImage(dataImage: Data())
}
