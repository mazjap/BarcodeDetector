import Foundation

enum BarcodeType: String, Hashable, CaseIterable, Identifiable {
    case aztec
    case code128
    case pdf417
    case qrCode
    
    var id: String { rawValue }
    
    static let scannableCases: [BarcodeType] = [.qrCode]
}
