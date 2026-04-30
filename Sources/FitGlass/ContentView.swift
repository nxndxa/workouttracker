import SwiftUI

private enum AppTheme {
    static let backgroundTop = Color(red: 0.09, green: 0.09, blue: 0.1)
    static let backgroundMid = Color(red: 0.15, green: 0.15, blue: 0.17)
    static let backgroundBottom = Color(red: 0.25, green: 0.25, blue: 0.28)
    static let card = Color.white.opacity(0.08)
    static let cardStrong = Color.white.opacity(0.12)
    static let border = Color.white.opacity(0.16)
    static let softText = Color.white.opacity(0.72)
    static let red = Color(red: 0.78, green: 0.13, blue: 0.18)
    static let redSoft = Color(red: 0.78, green: 0.13, blue: 0.18).opacity(0.18)
    static let steel = Color(red: 0.72, green: 0.72, blue: 0.76).opacity(0.18)
}

struct ContentView: View {
    @Bindable var store: ClosetStore
    @State private var showingAddSheet = false

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            dashboard
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add Piece", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddItemSheet(store: store, isPresented: $showingAddSheet)
        }
        .tint(AppTheme.red)
        .preferredColorScheme(.dark)
    }

    private var sidebar: some View {
        List(selection: $store.selectedCategory) {
            Section("Closet") {
                Label("All Pieces", systemImage: "square.grid.2x2")
                    .tag(Optional<ClothingCategory>.none)

                ForEach(ClothingCategory.allCases) { category in
                    Label(category.rawValue, systemImage: category.icon)
                        .tag(Optional(category))
                }
            }
        }
        .navigationTitle("WardrobeAI")
    }

    private var dashboard: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppTheme.backgroundTop,
                    AppTheme.backgroundMid,
                    AppTheme.backgroundBottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    heroCard
                    controls
                    HStack(alignment: .top, spacing: 20) {
                        closetSection
                        recommendationSection
                    }
                }
                .padding(28)
            }
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("AI Stylist for the Closet You Already Own")
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Text(store.insights.heroMessage)
                .font(.title3)
                .foregroundStyle(AppTheme.softText)

            HStack(spacing: 16) {
                statCard(title: "Pieces", value: "\(store.items.count)", icon: "hanger")
                statCard(title: "Favorites", value: "\(store.totalFavorites)", icon: "heart.fill")
                statCard(title: "Unworn", value: "\(store.unwornCount)", icon: "clock")
            }

            HStack(spacing: 10) {
                insightPill(text: store.insights.gapMessage, color: AppTheme.redSoft)
                insightPill(text: store.insights.rotationMessage, color: AppTheme.steel)
            }
        }
        .foregroundStyle(.white)
        .padding(24)
        .background(AppTheme.cardStrong, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Picker("Occasion", selection: $store.selectedOccasion) {
                ForEach(Occasion.allCases) { occasion in
                    Text(occasion.rawValue).tag(occasion)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 430)

            Picker("Season", selection: $store.selectedSeason) {
                ForEach(Season.allCases) { season in
                    Text(season.rawValue).tag(season)
                }
            }
            .frame(width: 150)

            TextField("Search closet", text: $store.searchText)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 260)

            Button {
                Task {
                    await store.generateLooks()
                }
            } label: {
                Label(store.isGenerating ? "Styling..." : "Generate Looks", systemImage: "sparkles")
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.red)
            .disabled(store.isGenerating)
        }
        .foregroundStyle(.white)
        .onChange(of: store.selectedOccasion) { _, _ in
            Task { await store.generateLooks() }
        }
        .onChange(of: store.selectedSeason) { _, _ in
            Task { await store.generateLooks() }
        }
    }

    private var closetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Closet")
                .font(.title2.bold())

            ForEach(store.filteredItems) { item in
                ClosetItemCard(
                    item: item,
                    onFavorite: { store.toggleFavorite(for: item.id) },
                    onWorn: { store.markWorn(item.id) }
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var recommendationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Outfit Studio")
                .font(.title2.bold())

            ForEach(store.generatedLooks) { look in
                RecommendationCard(look: look)
            }
        }
        .frame(width: 420, alignment: .topLeading)
    }

    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(AppTheme.red)
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text(title)
                .foregroundStyle(AppTheme.softText)
        }
        .foregroundStyle(.white)
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func insightPill(text: String, color: Color) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(color, in: Capsule())
    }
}

private struct ClosetItemCard: View {
    let item: ClothingItem
    let onFavorite: () -> Void
    let onWorn: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(item.color.swatch.gradient)
                .frame(width: 18, height: 18)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                    if item.favorite {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(AppTheme.red)
                    }
                }

                Text("\(item.brand) • \(item.category.rawValue) • \(item.occasion.rawValue)")
                    .foregroundStyle(AppTheme.softText)

                Text(item.notes)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.softText)

                HStack(spacing: 8) {
                    Text(item.formality.rawValue)
                    Text(item.season.rawValue)
                    Text("Warmth \(item.warmth)")
                }
                .font(.caption)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppTheme.steel, in: Capsule())
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 10) {
                Button(item.favorite ? "Unfavorite" : "Favorite", action: onFavorite)
                    .buttonStyle(.borderless)
                    .foregroundStyle(item.favorite ? AppTheme.red : .white)
                Button("Mark Worn", action: onWorn)
                    .buttonStyle(.bordered)
                    .tint(AppTheme.red)
                if let lastWorn = item.lastWorn {
                    Text(lastWorn, style: .relative)
                        .font(.caption)
                        .foregroundStyle(AppTheme.softText)
                } else {
                    Text("Never worn")
                        .font(.caption)
                        .foregroundStyle(AppTheme.softText)
                }
            }
        }
        .foregroundStyle(.white)
        .padding(18)
        .background(AppTheme.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }
}

private struct RecommendationCard: View {
    let look: OutfitRecommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(look.title)
                        .font(.headline)
                    Text("Confidence \(look.confidence)%")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.softText)
                }

                Spacer()

                Image(systemName: "sparkles.rectangle.stack")
                    .font(.title2)
                    .foregroundStyle(AppTheme.red)
            }

            FlowLayout(items: look.pieces) { piece in
                Text(piece.name)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(piece.color.swatch.opacity(0.22), in: Capsule())
            }

            Text(look.rationale)
                .foregroundStyle(AppTheme.softText)
            Text("Styling tip: \(look.stylingTip)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
        }
        .foregroundStyle(.white)
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardStrong, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }
}

private struct AddItemSheet: View {
    @Bindable var store: ClosetStore
    @Binding var isPresented: Bool

    @State private var name = ""
    @State private var brand = ""
    @State private var category: ClothingCategory = .tops
    @State private var color: WardrobeColor = .black
    @State private var season: Season = .spring
    @State private var occasion: Occasion = .casual
    @State private var formality: Formality = .balanced
    @State private var warmth = 2.0
    @State private var favorite = false
    @State private var notes = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add New Piece")
                .font(.title2.bold())
                .foregroundStyle(.white)

            TextField("Name", text: $name)
            TextField("Brand", text: $brand)

            HStack {
                Picker("Category", selection: $category) {
                    ForEach(ClothingCategory.allCases) { value in
                        Text(value.rawValue).tag(value)
                    }
                }

                Picker("Color", selection: $color) {
                    ForEach(WardrobeColor.allCases) { value in
                        Text(value.rawValue).tag(value)
                    }
                }
            }

            HStack {
                Picker("Season", selection: $season) {
                    ForEach(Season.allCases) { value in
                        Text(value.rawValue).tag(value)
                    }
                }

                Picker("Occasion", selection: $occasion) {
                    ForEach(Occasion.allCases) { value in
                        Text(value.rawValue).tag(value)
                    }
                }
            }

            Picker("Formality", selection: $formality) {
                ForEach(Formality.allCases) { value in
                    Text(value.rawValue).tag(value)
                }
            }

            VStack(alignment: .leading) {
                Text("Warmth \(Int(warmth))")
                Slider(value: $warmth, in: 1...5, step: 1)
            }

            Toggle("Favorite piece", isOn: $favorite)

            TextField("Notes", text: $notes, axis: .vertical)
                .lineLimit(3...5)

            HStack {
                Spacer()
                Button("Cancel") {
                    isPresented = false
                }
                .foregroundStyle(.white)
                Button("Save") {
                    store.addItem(
                        ClothingItem(
                            name: name,
                            brand: brand,
                            category: category,
                            color: color,
                            season: season,
                            occasion: occasion,
                            formality: formality,
                            warmth: Int(warmth),
                            favorite: favorite,
                            notes: notes
                        )
                    )
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.red)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .foregroundStyle(.white)
        .padding(24)
        .frame(width: 520)
        .background(
            LinearGradient(
                colors: [AppTheme.backgroundMid, AppTheme.backgroundTop],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

private struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content

    init(items: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(Array(items), id: \.self) { item in
                content(item)
            }
        }
    }
}
