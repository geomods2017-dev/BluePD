import SwiftUI

enum BluePDTheme {
    static let backgroundTop = Color(red: 2/255, green: 7/255, blue: 18/255)
    static let backgroundMid = Color(red: 7/255, green: 17/255, blue: 31/255)
    static let backgroundBottom = Color(red: 10/255, green: 24/255, blue: 44/255)

    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.74)
    static let tertiaryText = Color.white.opacity(0.38)
    static let placeholderText = Color.white.opacity(0.34)

    static let cardFill = Color.white.opacity(0.05)
    static let cardStroke = Color.white.opacity(0.07)
    static let innerCardStroke = Color.white.opacity(0.065)

    static let accent = Color(red: 0.10, green: 0.56, blue: 1.00)
    static let accentSoft = accent.opacity(0.12)

    static let success = Color.green
    static let warning = Color.orange
    static let danger = Color.red

    static var appBackground: LinearGradient {
        LinearGradient(
            colors: [backgroundTop, backgroundMid, backgroundBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var outerCardGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.070),
                Color.white.opacity(0.032)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var innerCardGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.050),
                Color.white.opacity(0.028)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryButtonGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.56, blue: 0.98),
                Color(red: 0.05, green: 0.42, blue: 0.92)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
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
            .shadow(color: .black.opacity(0.22), radius: 18, x: 0, y: 10)
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
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
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
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
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
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
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
            .foregroundColor(.white.opacity(0.82))
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.10))
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
    func bluePDCard(cornerRadius: CGFloat = 24) -> some View {
        modifier(BluePDCardModifier(cornerRadius: cornerRadius))
    }

    func bluePDInnerCard(cornerRadius: CGFloat = 20) -> some View {
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
