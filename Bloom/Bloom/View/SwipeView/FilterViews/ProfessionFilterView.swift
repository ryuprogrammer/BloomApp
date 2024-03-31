import SwiftUI

struct ProfessionFilterView: View {
    let filterViewModel = FilterViewModel()
    @Binding var professions: [String]
    @State var professionData: [[String]] = [[]]
    @State var isHobbyValid: Bool = true
    let maxSelectNumber = 3
    let barHeight = UIScreen.main.bounds.height / 10

    @Environment(\.dismiss) private var dismiss
    let maxWidth: CGFloat = UIScreen.main.bounds.width - 90 // マージンを取る

    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                Spacer()
                    .frame(height: barHeight)

                VStack(alignment: .leading) {
                    ForEach(professionData, id: \.self) { row in
                        HStack(spacing: 3) {
                            ForEach(row, id: \.self) { item in
                                if self.professions.contains(item) {
                                    Text(item)
                                        .font(.title2)
                                        .foregroundStyle(Color.pink.opacity(0.8))
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 8)
                                        .background {
                                            Capsule().stroke(Color.pink.opacity(0.8), lineWidth: 5)
                                        }
                                        .padding(5)
                                        .lineLimit(1)
                                        .fixedSize()
                                        .onTapGesture {
                                            withAnimation {
                                                self.professions.removeAll(where: {
                                                    $0 == item
                                                })
                                            }
                                        }
                                } else {
                                    Text(item)
                                        .font(.title3)
                                        .foregroundStyle(.gray)
                                        .padding(5)
                                        .padding(.horizontal, 8)
                                        .lineLimit(1)
                                        .fixedSize()
                                        .onTapGesture {
                                            withAnimation {
                                                if self.professions.count < maxSelectNumber {
                                                    self.professions.append(item)
                                                }
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
                .padding(.top)

                Spacer()
                    .frame(height: 130)
            }

            VStack {
                VStack {
                    Text("趣味を３つまで選択してください")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .padding(.top)

                    if professions.isEmpty {
                        Text("まだ選択されてません")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.white)
                            .padding(5)
                    } else {
                        HStack {
                            ForEach(professions, id: \.self) { profession in
                                Text(profession)
                                    .font(.callout)
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
                    title: "趣味を選択",
                    imageName: "mappin.and.ellipse",
                    isValid: $isHobbyValid,
                    action: {
                        dismiss()
                    }
                )
            }
        }
        .onAppear {
            professionData = filterViewModel.fetchProfessionData().splitArrayByWidth(maxWidth: maxWidth)
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State var professions: [String] = ["マジシャン"]
        var body: some View {
            ProfessionFilterView(professions: $professions)
        }
    }

    return PreviewView()
}
