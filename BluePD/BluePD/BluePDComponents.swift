import SwiftUI

struct BluePDCard<Content: View>: View {
    var padding: CGFloat = 18
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content()
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(BluePDTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(BluePDTheme.cardStroke, lineWidth: 1)
        )
    }
}

struct BluePDSectionHeader: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label {
            Text(title)
                .font(.headline)
                .foregroundColor(BluePDTheme.primaryText)
        } icon: {
            Image(systemName: systemImage)
                .foregroundColor(BluePDTheme.accent)
        }
    }
}

struct BluePDPrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                }

                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(BluePDTheme.accent)
            )
            .foregroundColor(.white)
        }
    }
}

struct BluePDInfoRow: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var trailingView: AnyView? = nil

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(BluePDTheme.accentSoft)
                    .frame(width: 46, height: 46)

                Image(systemName: systemImage)
                    .foregroundColor(BluePDTheme.accent)
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(BluePDTheme.primaryText)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(BluePDTheme.secondaryText)
            }

            Spacer()

            trailingView
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(BluePDTheme.innerCardGradient)
        )
    }
}

/// A small pill used across screens to show live status (iCloud sync, Pro, storage limits)
/// so status communication looks the same everywhere instead of each screen inventing its own.
struct BluePDStatusPill: View {
    enum Tone {
        case neutral, success, warning

        var color: Color {
            switch self {
            case .neutral: return BluePDTheme.accent
            case .success: return BluePDTheme.success
            case .warning: return BluePDTheme.warning
            }
        }
    }

    let text: String
    let systemImage: String
    var tone: Tone = .neutral

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.caption2.weight(.bold))

            Text(text)
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(tone.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(tone.color.opacity(0.12), in: Capsule())
    }
}

/// A generic empty-state block reused by any list-style screen (evidence, quick cards,
/// saved reports, reference search) so empty states look and read consistently.
struct BluePDEmptyState: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(BluePDTheme.secondaryText)

            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(BluePDTheme.primaryText)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(BluePDTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .bluePDCard(cornerRadius: 22)
    }
}
