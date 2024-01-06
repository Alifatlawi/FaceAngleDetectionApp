import SwiftUI
import Vision
import AVFoundation
import Photos

struct CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        CameraViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}


class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var captureSession: AVCaptureSession!
        private var previewLayer: AVCaptureVideoPreviewLayer!
        private var photoOutput = AVCapturePhotoOutput()
        private var faceDetectionRequest: VNDetectFaceLandmarksRequest!
        private var overlayView: UIView!
        private let yawThreshold: Double = 0.15  // Adjust as needed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupVision()
        setupOverlayView()
    }
    
    private func setupCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession = AVCaptureSession()
            self.captureSession.sessionPreset = .high
            
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
                  let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
                  self.captureSession.canAddInput(videoInput) else {
                print("Error: Unable to initialize video capture device")
                return
            }
            
            self.captureSession.addInput(videoInput)
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if self.captureSession.canAddOutput(videoOutput) {
                self.captureSession.addOutput(videoOutput)
            }
            
            self.captureSession.startRunning()
            
            DispatchQueue.main.async {
                self.setupPreviewLayer()
            }
        }
    }
    
    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
    
    private func setupOverlayView() {
        overlayView = UIView()
        overlayView.frame = view.bounds
        overlayView.backgroundColor = UIColor.red.withAlphaComponent(0.2)  // For debugging
        view.addSubview(overlayView)
    }
    
    
    private func setupVision() {
           faceDetectionRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
               guard let self = self, let observations = request.results as? [VNFaceObservation] else {
                   print("Error: \(error?.localizedDescription ?? "Face detection error")")
                   return
               }
               
               DispatchQueue.main.async {
                   self.processFaces(observations)
               }
           }
       }
    
    
    private func processFaces(_ faceObservations: [VNFaceObservation]) {
        // Remove previous layers
        overlayView.layer.sublayers?.removeAll(where: { $0 is CAShapeLayer })

        for faceObservation in faceObservations {
            if let yaw = faceObservation.yaw?.doubleValue, abs(yaw) < yawThreshold {
                // The face is looking straight
                print("Face is looking straight")

                // Draw face bounding box only if the face is looking straight
                drawFaceBox(faceObservation.boundingBox)
            }
        }
    }

    
    
    private func drawFaceBox(_ boundingBox: CGRect) {
        let width = overlayView.bounds.width
        let height = overlayView.bounds.height
        let transform = CGAffineTransform(scaleX: width, y: -height).translatedBy(x: 0, y: -1)
        let faceRect = boundingBox.applying(transform)

        let faceBoxLayer = CAShapeLayer()
        faceBoxLayer.frame = faceRect
        faceBoxLayer.borderColor = UIColor.red.cgColor
        faceBoxLayer.borderWidth = 2
        overlayView.layer.addSublayer(faceBoxLayer)
    }

    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        var requestOptions: [VNImageOption: Any] = [:]
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics: cameraIntrinsicData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: requestOptions)
        do {
            try imageRequestHandler.perform([faceDetectionRequest])
        } catch {
            print("Failed to perform face detection: \(error)")
        }
    }
}
