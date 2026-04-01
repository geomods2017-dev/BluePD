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
                .fill(Color.white.opacity(0.05))
        )
    }
}
