//import AVFoundation
//import Vision
//import SwiftUI
//
//class CameraViewModel: NSObject, ObservableObject {
//    var session = AVCaptureSession()
//    private let faceDetectionRequest = VNDetectFaceLandmarksRequest()
//    
//    // Initialize with front camera
//    override init() {
//        super.init()
//        setupCamera()
//    }
//
//     func setupCamera() {
//        DispatchQueue.global(qos: .userInitiated).async {
//            guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
//                  let input = try? AVCaptureDeviceInput(device: captureDevice) else {
//                return
//            }
//
//            // Start a new capture session
//            self.session = AVCaptureSession()
//
//            // Remove existing inputs
//            self.session.inputs.forEach { self.session.removeInput($0) }
//
//            // Add new input
//            if self.session.canAddInput(input) {
//                self.session.addInput(input)
//            }
//
//            self.setupVideoOutput()
//        }
//    }
//
//    private func setupVideoOutput() {
//        let videoOutput = AVCaptureVideoDataOutput()
//        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
//        if session.canAddOutput(videoOutput) {
//            session.addOutput(videoOutput)
//        }
//    }
//
//    func detectFaces(in sampleBuffer: CMSampleBuffer) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//            return
//        }
//
//        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
//        do {
//            try imageRequestHandler.perform([faceDetectionRequest])
//            // Further processing will be added here
//        } catch {
//            print("Failed to perform face detection: \(error)")
//        }
//    }
//}
//
//extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        detectFaces(in: sampleBuffer)
//    }
//}
//
//
