import SwiftUI

enum BluePDTheme {
    static let backgroundTop = Color(red: 7/255, green: 12/255, blue: 24/255)
    static let backgroundMid = Color(red: 13/255, green: 23/255, blue: 40/255)
    static let backgroundBottom = Color(red: 18/255, green: 29/255, blue: 48/255)

    static let cardFill = Color.white.opacity(0.06)
    static let cardStroke = Color.white.opacity(0.07)

    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.72)
    static let tertiaryText = Color.white.opacity(0.58)

    static let accent = Color.blue
    static let accentSoft = Color.blue.opacity(0.14)
    static let success = Color.green
    static let danger = Color.red

    static var appBackground: LinearGradient {
        LinearGradient(
            colors: [backgroundTop, backgroundMid, backgroundBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
