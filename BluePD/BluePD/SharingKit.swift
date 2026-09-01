import SwiftUI
import UIKit

/// Wraps `UIActivityViewController` so any screen can offer the system share sheet
/// (AirDrop, Mail, Messages, Save to Files, Print, copy) for text or file items.
/// Reused by Miranda transcripts, SFST reports, evidence logs, and quick cards.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.excludedActivityTypes = excludedActivityTypes
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

/// Wraps a file URL as `Identifiable` so it can drive `.sheet(item:)` for exported PDFs.
struct ShareableFile: Identifiable {
    let id = UUID()
    let url: URL
}

/// Builds simple, print-friendly PDFs from either plain text or a prebuilt HTML body.
/// Uses `UIPrintPageRenderer` + `UIMarkupTextPrintFormatter`, which is Apple's own
/// pagination path for exactly this use case, instead of hand-rolling CoreText frames.
enum PDFReportBuilder {
    /// Renders a title + optional subtitle + plain body text into a paginated PDF.
    static func makeTextReportPDF(
        title: String,
        subtitle: String? = nil,
        body: String,
        generatedAt: Date = Date()
    ) -> Data? {
        let escapedBody = escapeHTML(body).replacingOccurrences(of: "\n", with: "<br/>")
        return makeHTMLReportPDF(
            title: title,
            subtitle: subtitle,
            generatedAt: generatedAt,
            bodyHTML: "<div class=\"body\">\(escapedBody)</div>"
        )
    }

    /// Renders a title + optional subtitle + arbitrary HTML body (used by Evidence export,
    /// which embeds photo thumbnails as base64 `<img>` tags) into a paginated PDF.
    static func makeHTMLReportPDF(
        title: String,
        subtitle: String? = nil,
        generatedAt: Date = Date(),
        bodyHTML: String
    ) -> Data? {
        let dateString = generatedAt.formatted(date: .abbreviated, time: .shortened)
        let subtitleHTML = subtitle.map { "<div class=\"subtitle\">\(escapeHTML($0))</div>" } ?? ""

        let html = """
        <html>
        <head>
        <meta charset="utf-8"/>
        <style>
        body { font-family: -apple-system, Helvetica, sans-serif; color: #111111; font-size: 13px; line-height: 1.5; }
        h1 { font-size: 20px; margin: 0 0 2px 0; }
        .subtitle { color: #555555; font-size: 12px; margin-bottom: 4px; }
        .meta { color: #888888; font-size: 10px; margin-bottom: 16px; }
        .body { white-space: pre-wrap; word-wrap: break-word; }
        hr { border: none; border-top: 1px solid #dddddd; margin: 12px 0 16px 0; }
        img { max-width: 100%; margin: 6px 0; }
        .disclaimer { color: #999999; font-size: 9px; margin-top: 24px; }
        </style>
        </head>
        <body>
        <h1>\(escapeHTML(title))</h1>
        \(subtitleHTML)
        <div class="meta">Generated \(dateString) &middot; BluePD</div>
        <hr/>
        \(bodyHTML)
        <div class="disclaimer">
        For informational and reference purposes only. Verify against your agency's policy,
        your prosecutor's requirements, and applicable law before relying on this document.
        </div>
        </body>
        </html>
        """

        let formatter = UIMarkupTextPrintFormatter(markupText: html)

        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)

        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 36

        let paperRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        renderer.paperRect = paperRect
        renderer.printableRect = paperRect.insetBy(dx: margin, dy: margin)

        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, paperRect, nil)

        let pageCount = max(renderer.numberOfPages, 1)
        for pageIndex in 0..<pageCount {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: pageIndex, in: UIGraphicsGetPDFContextBounds())
        }

        UIGraphicsEndPDFContext()

        return data as Data
    }

    /// Writes PDF data to a temporary file so it can be shared as a proper .pdf attachment
    /// (Mail/Files/AirDrop treat a file URL far better than raw `Data`).
    static func writeTemporaryPDF(data: Data, suggestedName: String) -> URL? {
        let sanitized = suggestedName
            .components(separatedBy: CharacterSet.alphanumerics.inverted.subtracting(CharacterSet(charactersIn: "-_ ")))
            .joined()
            .trimmingCharacters(in: .whitespaces)

        let finalName = sanitized.isEmpty ? "BluePD-Report" : sanitized
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(finalName).pdf")

        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            print("Failed to write PDF: \(error)")
            return nil
        }
    }

    private static func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
