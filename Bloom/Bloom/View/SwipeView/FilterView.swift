import SwiftUI

struct FilterView: View {
    // MARK: - インスタンス
    @ObservedObject var filterVM = FilterViewModel()

    // MARK: - 検索条件
    /// 画面描画用のフィルターデータ
    @State var filter: FilterElement = FilterElement(address: [], hobbys: [], professions: [])
    /// vipか
    @State var isVip: Bool = true
    /// 距離: ピッカー用
    @State var distance: Double = 60
    /// 最大年齢: ピッカー用
    @State var maxAge: Int = 25
    /// 最小年齢: ピッカー用
    @State var minAge: Int = 20
    /// グレード: ピッカー用
    @State var grade: Double = 60

    // MARK: - 画面遷移
    @State var isShowAddressView: Bool = false
    @State var isShowHobbyView: Bool = false
    @State var isShowProfessionView: Bool = false
    @Environment(\.presentationMode) var presentation

    // MARK: - ボタンが有効か
    @State var isValidButton: Bool = false
    @State var isShowAgePicker: Bool = false

    let pickerHeight = UIScreen.main.bounds.height / 4
    let pickerOffset = UIScreen.main.bounds.height

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section {
                        ListRowView(
                            viewType: .FilterView,
                            image: "mappin.and.ellipse",
                            title: "居住地",
                            detail: filter.toString(filterType: .address)
                        )
                        .onTapGesture {
                            isShowAddressView = true
                        }

                        ListRowView(
                            viewType: .FilterView,
                            image: "birthday.cake",
                            title: "年齢",
                            detail: filter.toString(filterType: .age)
                        )
                        .onTapGesture {
                            withAnimation(.linear) {
                                isShowAgePicker.toggle()
                            }
                        }
                    } header: {
                        Text("無料フィルター")
                    }

                    Section {
                        distanceSection()

                        ListRowView(
                            viewType: .FilterView,
                            isVip: true,
                            image: "birthday.cake",
                            title: "趣味",
                            detail: isVip ? filter.toString(filterType: .hobbys) : nil
                        )
                        .onTapGesture {
                            isShowHobbyView = true
                        }

                        ListRowView(
                            viewType: .FilterView,
                            isVip: true,
                            image: "wallet.pass",
                            title: "職業",
                            detail: isVip ? filter.toString(filterType: .professions) : nil
                        )
                        .onTapGesture {
                            isShowProfessionView = true
                        }

                        gradeSection()
                    } header: {
                        Text("VIPプラン限定フィルター")
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.vipStart, Color.vipEnd]), startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }

                VStack {
                    Spacer()

                    ButtonView(
                        title: "条件を保存",
                        imageName: "magnifyingglass",
                        isValid: $isValidButton,
                        action: {
                            filterVM.addFilter(filter: filter)
                            // 画面遷移
                            self.presentation.wrappedValue.dismiss()
                        }
                    )

                    // 年齢選択のPicker
                    AgePickerView(minAge: $minAge, maxAge: $maxAge, isShowing: $isShowAgePicker)
                        .frame(height: self.isShowAgePicker ? pickerHeight : 0)
                        .offset(y: self.isShowAgePicker ? 0 : pickerOffset)
                        .onChange(of: minAge) {
                            filter.maxAge = maxAge
                            filter.minAge = minAge
                        }
                        .onChange(of: maxAge) {
                            filter.maxAge = maxAge
                            filter.minAge = minAge
                        }
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("フィルター", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        filterVM.deleteFilter()
                        filter = FilterElement(address: [], hobbys: [], professions: [])
                        distance = 60
                        grade = 60
                    } label: {
                        Text("リセット")
                            .fontWeight(.bold)
                            .foregroundStyle(Color.pink.opacity(0.8))
                            .frame(width: 80, height: 28)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                }
            }
            // 画面遷移を制御
            .sheet(isPresented: $isShowAddressView) {
                AddressFilterView(address: $filter.address)
            }
            .sheet(isPresented: $isShowHobbyView) {
                HobbyFilterView(hobbys: $filter.hobbys)
            }
            .sheet(isPresented: $isShowProfessionView) {
                ProfessionFilterView(professions: $filter.professions)
            }
            .onChange(of: filter) {
                if filter != filterVM.filter {
                    isValidButton = true
                } else {
                    isValidButton = false
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            filterVM.fetchFilter()
            filter = filterVM.filter
            distance = filter.distance ?? 30
        }
    }

    @ViewBuilder
    func distanceSection() -> some View {
        VStack(alignment: .leading) {
            ListRowView(
                viewType: .FilterView,
                isVip: true,
                image: "arrow.left.and.right",
                title: "距離",
                detail: isVip ? filter.toString(filterType: .distance) : nil
            )

            Text("登録した現在地と友達との距離")
                .font(.callout)
                .foregroundStyle(Color.gray)

            Slider(
                value: $distance,
                in: 5...100,
                step: 1.0
            )
            .tint(.pink.opacity(0.8))
            .onChange(of: distance) {
                filter.distance = distance
            }
        }
    }

    @ViewBuilder
    func gradeSection() -> some View {
        VStack(alignment: .leading) {
            ListRowView(
                viewType: .FilterView,
                isVip: true,
                image: "wallet.pass",
                title: "グレード",
                detail: isVip ? filter.toString(filterType: .grade) : nil
            )

            Text("人気度を数値化したもの")
                .font(.callout)
                .foregroundStyle(Color.gray)

            Slider(
                value: $grade,
                in: 10...100,
                step: 1
            )
            .tint(.pink.opacity(0.8))
            .onChange(of: grade) {
                filter.grade = Int(grade)
            }
        }
    }
}

#Preview {
    FilterView()
}
