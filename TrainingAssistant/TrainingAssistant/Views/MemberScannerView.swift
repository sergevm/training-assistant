//
//  MemberScannerView.swift
//  TrainingAssistant
//
//  A SwiftUI wrapper around VisionKit's live QR scanner. Recognizes QR codes
//  and forwards the first payload string to `onScan`. Only used on devices where
//  `DataScannerViewController` is supported and available (never the simulator).
//  `MemberQRCode` interprets the scanned payload; every flow that scans member
//  QR codes goes through it so they all recognize the same format.
//

import SwiftUI
import Vision
import VisionKit

/// The member QR payload format: a URL whose `member_id` query-string
/// parameter carries the club member id.
enum MemberQRCode {
    /// Extract the `member_id` query-string parameter from a URL QR payload.
    static func memberID(fromURL payload: String) -> String? {
        guard let components = URLComponents(string: payload),
              let value = components.queryItems?.first(where: { $0.name == "member_id" })?.value
        else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

struct MemberScannerView: UIViewControllerRepresentable {
    /// Called once with the recognized QR payload string.
    let onScan: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])],
            qualityLevel: .balanced,
            recognizesMultipleItems: false
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ scanner: DataScannerViewController, context: Context) {
        try? scanner.startScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan)
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        private let onScan: (String) -> Void
        private var handled = false

        init(onScan: @escaping (String) -> Void) {
            self.onScan = onScan
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            forwardFirstBarcode(in: addedItems)
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            forwardFirstBarcode(in: [item])
        }

        private func forwardFirstBarcode(in items: [RecognizedItem]) {
            guard !handled else { return }
            for item in items {
                if case let .barcode(barcode) = item, let payload = barcode.payloadStringValue {
                    handled = true
                    onScan(payload)
                    return
                }
            }
        }
    }
}
