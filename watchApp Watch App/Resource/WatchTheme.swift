import SwiftUI

struct WatchTheme {
    static let primaryOrange = Color(red: 1.0, green: 0.32, blue: 0.18) // #FF512F
    static let primaryRed = Color(red: 0.87, green: 0.14, blue: 0.46)    // #DD2476
    
    static let background = Color.black
    static let surface = Color(white: 0.12)
    static let surfaceSecondary = Color(white: 0.18)
    
    static let burningGradient = LinearGradient(
        colors: [primaryOrange, primaryRed],
        begin: .topLeading,
        end: .bottomTrailing
    )
}

extension View {
    func premiumCardStyle(isSelected: Bool = false) -> some View {
        self
            .padding()
            .background(isSelected ? WatchTheme.surfaceSecondary : WatchTheme.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? WatchTheme.primaryOrange : Color.clear, lineWidth: 2)
            )
    }
}
