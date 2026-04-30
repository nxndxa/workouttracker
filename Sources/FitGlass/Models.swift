import Foundation
import SwiftUI

enum ClothingCategory: String, CaseIterable, Codable, Identifiable {
    case tops = "Tops"
    case bottoms = "Bottoms"
    case layers = "Layers"
    case dresses = "Dresses"
    case shoes = "Shoes"
    case accessories = "Accessories"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .tops: "tshirt"
        case .bottoms: "square.split.2x1"
        case .layers: "square.stack.3d.up"
        case .dresses: "figure.dress.line.vertical.figure"
        case .shoes: "shoe.2"
        case .accessories: "sparkles"
        }
    }
}

enum Season: String, CaseIterable, Codable, Identifiable {
    case spring = "Spring"
    case summer = "Summer"
    case autumn = "Autumn"
    case winter = "Winter"

    var id: String { rawValue }
}

enum Occasion: String, CaseIterable, Codable, Identifiable {
    case casual = "Casual"
    case work = "Work"
    case evening = "Evening"
    case travel = "Travel"
    case active = "Active"

    var id: String { rawValue }
}

enum WardrobeColor: String, CaseIterable, Codable, Identifiable {
    case black = "Black"
    case white = "White"
    case beige = "Beige"
    case navy = "Navy"
    case gray = "Gray"
    case olive = "Olive"
    case denim = "Denim"
    case red = "Red"
    case blue = "Blue"
    case green = "Green"
    case pink = "Pink"
    case yellow = "Yellow"
    case brown = "Brown"

    var id: String { rawValue }

    var swatch: Color {
        switch self {
        case .black: Color(red: 0.12, green: 0.12, blue: 0.13)
        case .white: Color(red: 0.94, green: 0.94, blue: 0.95)
        case .beige: Color(red: 0.75, green: 0.74, blue: 0.72)
        case .navy: Color(red: 0.24, green: 0.25, blue: 0.3)
        case .gray: Color(red: 0.52, green: 0.52, blue: 0.54)
        case .olive: Color(red: 0.38, green: 0.38, blue: 0.35)
        case .denim: Color(red: 0.33, green: 0.35, blue: 0.4)
        case .red: Color(red: 0.75, green: 0.12, blue: 0.18)
        case .blue: Color(red: 0.41, green: 0.43, blue: 0.47)
        case .green: Color(red: 0.4, green: 0.43, blue: 0.41)
        case .pink: Color(red: 0.67, green: 0.55, blue: 0.57)
        case .yellow: Color(red: 0.68, green: 0.66, blue: 0.56)
        case .brown: Color(red: 0.42, green: 0.36, blue: 0.34)
        }
    }
}

enum Formality: String, CaseIterable, Codable, Identifiable {
    case relaxed = "Relaxed"
    case balanced = "Balanced"
    case polished = "Polished"

    var id: String { rawValue }
}

struct ClothingItem: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var brand: String
    var category: ClothingCategory
    var color: WardrobeColor
    var season: Season
    var occasion: Occasion
    var formality: Formality
    var warmth: Int
    var favorite: Bool
    var lastWorn: Date?
    var notes: String

    init(
        id: UUID = UUID(),
        name: String,
        brand: String,
        category: ClothingCategory,
        color: WardrobeColor,
        season: Season,
        occasion: Occasion,
        formality: Formality,
        warmth: Int,
        favorite: Bool,
        lastWorn: Date? = nil,
        notes: String
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.category = category
        self.color = color
        self.season = season
        self.occasion = occasion
        self.formality = formality
        self.warmth = warmth
        self.favorite = favorite
        self.lastWorn = lastWorn
        self.notes = notes
    }
}

struct OutfitRecommendation: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let confidence: Int
    let pieces: [ClothingItem]
    let rationale: String
    let stylingTip: String
}

struct WardrobeInsights {
    let heroMessage: String
    let gapMessage: String
    let rotationMessage: String
}

enum ClosetSeedData {
    static let items: [ClothingItem] = [
        ClothingItem(name: "Ivory Rib Tank", brand: "Everlane", category: .tops, color: .white, season: .summer, occasion: .casual, formality: .relaxed, warmth: 1, favorite: true, lastWorn: .now.addingTimeInterval(-86_400 * 3), notes: "Easy base layer."),
        ClothingItem(name: "Blue Oxford Shirt", brand: "COS", category: .tops, color: .blue, season: .spring, occasion: .work, formality: .polished, warmth: 2, favorite: true, lastWorn: .now.addingTimeInterval(-86_400 * 9), notes: "Works with denim or trousers."),
        ClothingItem(name: "Charcoal Wide-Leg Trouser", brand: "Aritzia", category: .bottoms, color: .gray, season: .autumn, occasion: .work, formality: .polished, warmth: 3, favorite: true, lastWorn: .now.addingTimeInterval(-86_400 * 5), notes: "Tailored silhouette."),
        ClothingItem(name: "Straight Denim", brand: "Levi's", category: .bottoms, color: .denim, season: .spring, occasion: .casual, formality: .balanced, warmth: 2, favorite: true, lastWorn: .now.addingTimeInterval(-86_400 * 1), notes: "Clean wash."),
        ClothingItem(name: "Camel Wool Coat", brand: "Mango", category: .layers, color: .beige, season: .winter, occasion: .work, formality: .polished, warmth: 5, favorite: false, lastWorn: .now.addingTimeInterval(-86_400 * 18), notes: "Strong statement outer layer."),
        ClothingItem(name: "Olive Utility Jacket", brand: "Uniqlo", category: .layers, color: .olive, season: .autumn, occasion: .travel, formality: .balanced, warmth: 3, favorite: false, lastWorn: .now.addingTimeInterval(-86_400 * 12), notes: "Relaxed structure."),
        ClothingItem(name: "Black Knit Dress", brand: "Reformation", category: .dresses, color: .black, season: .winter, occasion: .evening, formality: .polished, warmth: 3, favorite: true, lastWorn: .now.addingTimeInterval(-86_400 * 21), notes: "Minimal, elevated."),
        ClothingItem(name: "White Leather Sneakers", brand: "Veja", category: .shoes, color: .white, season: .spring, occasion: .casual, formality: .balanced, warmth: 1, favorite: true, lastWorn: .now.addingTimeInterval(-86_400 * 2), notes: "Versatile everyday pair."),
        ClothingItem(name: "Black Loafers", brand: "GH Bass", category: .shoes, color: .black, season: .autumn, occasion: .work, formality: .polished, warmth: 2, favorite: false, lastWorn: .now.addingTimeInterval(-86_400 * 8), notes: "Sharp finish."),
        ClothingItem(name: "Structured Tote", brand: "Polene", category: .accessories, color: .brown, season: .spring, occasion: .work, formality: .polished, warmth: 1, favorite: true, lastWorn: .now.addingTimeInterval(-86_400 * 6), notes: "Fits laptop and essentials.")
    ]
}
