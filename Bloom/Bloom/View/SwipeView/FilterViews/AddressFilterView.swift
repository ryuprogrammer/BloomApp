import SwiftUI

struct AddressFilterView: View {
    let explanationText = ExplanationText()
    let filterViewModel = FilterViewModel()
    @Binding var address: [String]
    @State var isAddressValid: Bool = true
    let maxSelectNumber = 3
    let barHeight = UIScreen.main.bounds.height / 10

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            ScrollView {
                Spacer()
                    .frame(height: barHeight)

                ForEach(filterViewModel.prefectures, id: \.self) { prefecture in
                    if self.address.contains(prefecture) {
                        Text(prefecture)
                            .font(.title)
                            .foregroundStyle(Color.pink.opacity(0.8))
                            .padding(.vertical, 5)
                            .padding(.horizontal, 15)
                            .background {
                                Capsule().stroke(Color.pink.opacity(0.8), lineWidth: 5)
                            }
                            .padding(2)
                            .onTapGesture {
                                withAnimation {
                                    self.address.removeAll(where: {
                                        $0 == prefecture
                                    })
                                }
                            }
                    } else {
                        Text(prefecture)
                            .font(.title)
                            .foregroundStyle(Color(UIColor.lightGray))
                            .onTapGesture {
                                withAnimation {
                                    if self.address.count < maxSelectNumber {
                                        self.address.append(prefecture)
                                    }
                                }
                            }
                            .padding(2)
                    }
                }
                .frame(maxWidth: .infinity)

                Spacer()
                    .frame(height: 130)
            }

            VStack {
                VStack {
                    Text("居住地を３つまで選択してください")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .padding(.top)

                    if address.isEmpty {
                        Text("まだ選択されてません")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.white)
                            .padding(5)
                    } else {
                        HStack {
                            ForEach(address, id: \.self) { address in
                                Text(address)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.pink.opacity(0.8))
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 8)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                        }
                        .padding(.bottom, 10)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: barHeight)
                .background(Color.pink.opacity(0.8))

                Spacer()

                ButtonView(
                    title: "居住地を選択",
                    imageName: "mappin.and.ellipse",
                    isValid: $isAddressValid,
                    action: {
                        dismiss()
                    }
                )
            }
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State var address: [String] = []
        var body: some View {
            AddressFilterView(address: $address)
        }
    }

    return PreviewView()
}
