import SwiftUI

/// Storage key shared between the Settings toggle and BluePDTheme's live lookups.
/// Any top-level screen that declares `@AppStorage(BluePDTheme.daylightModeKey)` will
/// automatically re-render when Daylight Mode is switched, since BluePDTheme itself
/// reads this key fresh on every access rather than caching a static value.
enum BluePDTheme {
    static let daylightModeKey = "daylightModeEnabled"

    static var isDaylightMode: Bool {
        UserDefaults.standard.bool(forKey: daylightModeKey)
    }

    // MARK: - Backgrounds

    static var backgroundTop: Color {
        isDaylightMode
            ? Color(red: 244/255, green: 246/255, blue: 250/255)
            : Color(red: 2/255, green: 7/255, blue: 18/255)
    }

    static var backgroundMid: Color {
        isDaylightMode
            ? Color(red: 233/255, green: 237/255, blue: 244/255)
            : Color(red: 7/255, green: 17/255, blue: 31/255)
    }

    static var backgroundBottom: Color {
        isDaylightMode
            ? Color(red: 220/255, green: 227/255, blue: 238/255)
            : Color(red: 10/255, green: 24/255, blue: 44/255)
    }

    // MARK: - Text

    static var primaryText: Color {
        isDaylightMode ? Color(red: 8/255, green: 14/255, blue: 26/255) : Color.white
    }

    static var secondaryText: Color {
        isDaylightMode
            ? Color(red: 8/255, green: 14/255, blue: 26/255).opacity(0.72)
            : Color.white.opacity(0.78)
    }

    static var tertiaryText: Color {
        isDaylightMode
            ? Color(red: 8/255, green: 14/255, blue: 26/255).opacity(0.46)
            : Color.white.opacity(0.42)
    }

    static var placeholderText: Color {
        isDaylightMode
            ? Color(red: 8/255, green: 14/255, blue: 26/255).opacity(0.38)
            : Color.white.opacity(0.38)
    }

    // MARK: - Cards

    static var cardFill: Color {
        isDaylightMode ? Color.white : Color.white.opacity(0.05)
    }

    static var cardStroke: Color {
        isDaylightMode ? Color.black.opacity(0.10) : Color.white.opacity(0.08)
    }

    static var innerCardStroke: Color {
        isDaylightMode ? Color.black.opacity(0.08) : Color.white.opacity(0.07)
    }

    // MARK: - Accent & status

    static var accent: Color {
        isDaylightMode ? Color(red: 0.02, green: 0.36, blue: 0.86) : Color(red: 0.10, green: 0.56, blue: 1.00)
    }

    static var accentSoft: Color { accent.opacity(isDaylightMode ? 0.10 : 0.12) }

    static var success: Color { isDaylightMode ? Color(red: 0.09, green: 0.52, blue: 0.24) : Color.green }
    static var warning: Color { isDaylightMode ? Color(red: 0.72, green: 0.42, blue: 0.02) : Color.orange }
    static var danger: Color { isDaylightMode ? Color(red: 0.72, green: 0.10, blue: 0.10) : Color.red }

    // MARK: - Layout constants

    static let cardCornerRadius: CGFloat = 24
    static let innerCardCornerRadius: CGFloat = 20
    static let controlCornerRadius: CGFloat = 16
    static let controlHeight: CGFloat = 58

    // MARK: - Gradients

    static var appBackground: LinearGradient {
        LinearGradient(
            colors: [backgroundTop, backgroundMid, backgroundBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var outerCardGradient: LinearGradient {
        isDaylightMode
            ? LinearGradient(colors: [cardFill, cardFill], startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(
                colors: [Color.white.opacity(0.070), Color.white.opacity(0.032)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
    }

    static var innerCardGradient: LinearGradient {
        isDaylightMode
            ? LinearGradient(colors: [cardFill, cardFill], startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(
                colors: [Color.white.opacity(0.050), Color.white.opacity(0.028)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
    }

    static var primaryButtonGradient: LinearGradient {
        isDaylightMode
            ? LinearGradient(colors: [accent, accent], startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(
                colors: [Color(red: 0.08, green: 0.56, blue: 0.98), Color(red: 0.05, green: 0.42, blue: 0.92)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
    }

    // MARK: - Type scale
    // A single place to reach for consistent weights across screens, so new/edited
    // views don't reinvent ad hoc font choices.

    static let screenTitleFont: Font = .title2.weight(.bold)
    static let sectionTitleFont: Font = .title2.weight(.bold)
    static let cardTitleFont: Font = .headline.weight(.semibold)
    static let bodyFont: Font = .subheadline
    static let captionFont: Font = .caption.weight(.medium)
}

struct BluePDCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(BluePDTheme.outerCardGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(BluePDTheme.cardStroke, lineWidth: 1)
            )
            .shadow(color: .black.opacity(BluePDTheme.isDaylightMode ? 0.08 : 0.22), radius: 18, x: 0, y: 10)
    }
}

struct BluePDInnerCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(BluePDTheme.innerCardGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(BluePDTheme.innerCardStroke, lineWidth: 1)
            )
    }
}

struct BluePDPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: BluePDTheme.controlHeight)
            .background(
                RoundedRectangle(cornerRadius: BluePDTheme.controlCornerRadius, style: .continuous)
                    .fill(BluePDTheme.primaryButtonGradient)
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .shadow(color: BluePDTheme.accent.opacity(0.18), radius: 12, x: 0, y: 8)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct BluePDSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundColor(BluePDTheme.primaryText)
            .frame(maxWidth: .infinity)
            .frame(height: BluePDTheme.controlHeight)
            .background(
                RoundedRectangle(cornerRadius: BluePDTheme.controlCornerRadius, style: .continuous)
                    .fill(BluePDTheme.isDaylightMode ? Color.black.opacity(0.05) : Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: BluePDTheme.controlCornerRadius, style: .continuous)
                    .stroke(BluePDTheme.innerCardStroke, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct BluePDDestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: BluePDTheme.controlHeight)
            .background(
                RoundedRectangle(cornerRadius: BluePDTheme.controlCornerRadius, style: .continuous)
                    .fill(BluePDTheme.danger.opacity(0.90))
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct BluePDDisabledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundColor(BluePDTheme.primaryText.opacity(0.82))
            .frame(maxWidth: .infinity)
            .frame(height: BluePDTheme.controlHeight)
            .background(
                RoundedRectangle(cornerRadius: BluePDTheme.controlCornerRadius, style: .continuous)
                    .fill(BluePDTheme.isDaylightMode ? Color.black.opacity(0.06) : Color.white.opacity(0.10))
            )
    }
}

struct BluePDTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundColor(BluePDTheme.accent.opacity(configuration.isPressed ? 0.75 : 1.0))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
    }
}

extension View {
    func bluePDCard(cornerRadius: CGFloat = BluePDTheme.cardCornerRadius) -> some View {
        modifier(BluePDCardModifier(cornerRadius: cornerRadius))
    }

    func bluePDInnerCard(cornerRadius: CGFloat = BluePDTheme.innerCardCornerRadius) -> some View {
        modifier(BluePDInnerCardModifier(cornerRadius: cornerRadius))
    }
}

struct BluePDIconContainer: View {
    let systemImage: String
    let size: CGFloat
    let iconSize: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(BluePDTheme.accent.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(BluePDTheme.accent.opacity(0.22), lineWidth: 1)
                )

            Image(systemName: systemImage)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(BluePDTheme.accent)
        }
        .frame(width: size, height: size)
    }
}

extension String {
    func trimmedOrFallback(_ fallback: String) -> String {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }
}
