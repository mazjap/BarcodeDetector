import SwiftUI
import AVFoundation
import CoreImage.CIFilterBuiltins

struct CameraView: UIViewControllerRepresentable {
    private let scanned: (String) -> Void
    
    init(scanned: @escaping (String) -> Void) {
        self.scanned = scanned
    }
    
    func makeUIViewController(context: Context) -> CameraVC {
        let vc = CameraVC()
        
        return vc
    }
    
    func updateUIViewController(_ vc: CameraVC, context: Context) {
        vc.scanned = scanned
    }
}

class CameraVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private var captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private weak var output: AVCaptureMetadataOutput!
    
    var scanned: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice), captureSession.canAddInput(videoInput) else {
            failed()
            return
        }
        
        captureSession.addInput(videoInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        guard captureSession.canAddOutput(metadataOutput) else {
            failed()
            return
        }
        
        output = metadataOutput
        captureSession.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        print(metadataOutput.availableMetadataObjectTypes)
        metadataOutput.metadataObjectTypes = BarcodeType.allCases.map { AVMetadataObject.ObjectType.for($0) }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global().async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    private func failed() {
        print("Be better")
    }
    
    override func viewDidLayoutSubviews() {
        guard let previewLayer else { return }
        
        previewLayer.frame = view.layer.bounds
    }
    
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue
        else { return }
        
        Task { @MainActor in
            self.scanned?(stringValue)
        }
    }
}

extension AVMetadataObject.ObjectType {
    static func `for`(_ barcodeType: BarcodeType) -> AVMetadataObject.ObjectType {
        switch barcodeType {
        case .aztec:
            return .aztec
        case .code128:
            return .code128
        case .pdf417:
            return .pdf417
        case .qrCode:
            return .qr
        }
    }
}

#Preview {
    CameraView {_ in}
}
