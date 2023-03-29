//
//  NewVideoRenderer.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/03/29.
//

import UIKit
import AVFoundation
import Macaw

final class NewVideoRenderer {
    
    static let shared = NewVideoRenderer()
    
    private let group = DispatchGroup()
    private let queue = DispatchQueue(label: "NewVideoRenderer", qos: .userInitiated, attributes: .concurrent)
    
    private let fileName: String = "template"
    private var remainingImages: [UIImage] = []
    private var imagesData: [Data] = []
    private let defaultBackgoundColor: UIColor = UIColor.black
    private let scaleWidth: CGFloat = 1.0
    private let shouldOptimiseImageForVidel: Bool = true
    private let maxVideoLengthInSeconds: Double = 30
    private let videoImageWidthForMultipleVideoGeneration = 800
    
    enum VideoGeneratorType: Int {
        case single
        case multiple
        case singleAudioMultipleImage
    }
    
    private var type: VideoGeneratorType = .single
    
    private init() {}
    
    func quickRenderVideo(images: [UIImage], endTime: CMTime, timeScale: CMTimeScale, type: VideoGeneratorType, completion: @escaping ((Data?) -> Void)) {
        self.type = type
        
        if images.isEmpty {
            completion(nil)
        }
        
        if type == .single {
            if let image = images.first {
                self.remainingImages = [UIImage](repeating: image, count: 2)
            }
        } else {
            self.remainingImages = images
        }
        
        let generateQueue = DispatchQueue(label: "VideoRenderer_Generate", qos: .background)
        
        generateQueue.async {
            let outputURL = FilesManager.cacheFolderURL.appendingPathComponent("template.mov")
            let videoWriter: AVAssetWriter! = try! AVAssetWriter(outputURL: outputURL, fileType: .mov)
            FilesManager.removeFile(url: outputURL)
            
            let videoSettings: [String: AnyObject] = [
                AVVideoCodecKey: AVVideoCodecType.h264 as AnyObject,
                AVVideoWidthKey: 720 as AnyObject,
                AVVideoHeightKey: 720 as AnyObject
            ]
            
            let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
            
            let sourceBufferAttributes: [String: AnyObject] = [
                (kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32ARGB) as AnyObject,
                (kCVPixelBufferWidthKey as String): Float(720) as AnyObject,
                (kCVPixelBufferHeightKey as String): Float(720) as AnyObject,
                (kCVPixelBufferCGImageCompatibilityKey as String): NSNumber(value: true),
                (kCVPixelBufferCGBitmapContextCompatibilityKey as String): NSNumber(value: true)
            ]
            
            let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: sourceBufferAttributes)
            var nextStartTimeForFrame: CMTime! = CMTime(seconds: 0, preferredTimescale: 1)
            
            assert(videoWriter.canAdd(videoWriterInput))
            
            videoWriter.add(videoWriterInput)
            
            if videoWriter.startWriting() {
                videoWriter.startSession(atSourceTime: .zero)
                
                assert(pixelBufferAdaptor.pixelBufferPool != nil)
                
                let mediaQueue = DispatchQueue(label: "mediaQueue", qos: .background)
                
                videoWriterInput.requestMediaDataWhenReady(on: mediaQueue, using: { () -> Void in
                    
                    var bufferMap: [Int: UnsafeMutablePointer<CVPixelBuffer?>] = [:]
                    let imagesLength = images.count
                    var adoptBufferTaskCount = 0
                    let pixelBufferPoolLock = NSLock()
                    let pixelBufferIndexerLock = NSLock()
                    
                    let taskGroup = DispatchGroup()
                    taskGroup.enter()
                    
                    for imageIndex in 0..<imagesLength {
                        let currentImage: UIImage
                        if type == .single {
                            currentImage = self.remainingImages.remove(at: 0)
                        } else {
                            currentImage = images[imageIndex]
                        }
                        
                        DispatchQueue.global().async {
                            let pixelBufferPointer = self.allocateDrawnPixelBufferForImage(
                                currentImage,
                                bufferAdaptor: pixelBufferAdaptor,
                                bufferPoolLock: pixelBufferPoolLock
                            )
                            
                            pixelBufferIndexerLock.lock()
                            bufferMap[imageIndex] = pixelBufferPointer
                            
                            while true {
                                guard let bufferPointer = bufferMap[adoptBufferTaskCount] else {
                                    break;
                                }
                                
                                let result = self.adaptDrawnPixelBuffer(
                                    bufferAdapter: pixelBufferAdaptor,
                                    bufferPointer: bufferPointer,
                                    presentTimeMaker: { .init(value: CMTimeValue(adoptBufferTaskCount), timescale: timeScale) },
                                    bufferPoolLock: pixelBufferPoolLock)
                                
                                if result {
                                    bufferMap.removeValue(forKey: adoptBufferTaskCount)
                                    adoptBufferTaskCount += 1
                                }
                            }
                            
                            if adoptBufferTaskCount == imagesLength {
                                taskGroup.leave()
                            }
                            pixelBufferIndexerLock.unlock()
                        }
                    }
                    
                    taskGroup.wait()
                    
                    videoWriterInput.markAsFinished()
                    videoWriter.finishWriting { () -> Void in
                        if let data = try? Data(contentsOf: outputURL) {
                            completion(data)
                        }
                    }
                })
            }
        }
    }
    
    private func adaptDrawnPixelBuffer(
        bufferAdapter: AVAssetWriterInputPixelBufferAdaptor,
        bufferPointer: UnsafeMutablePointer<CVPixelBuffer?>,
        presentTimeMaker: () -> CMTime,
        bufferPoolLock: NSLock
    ) -> Bool {
        guard let buffer = bufferPointer.pointee else {
            LLog.w("buffer is nil.")
            bufferPointer.deallocate()
            return true
        }
        
        bufferPoolLock.lock()
        let isReadyBufferAdapter = bufferAdapter.assetWriterInput.isReadyForMoreMediaData
        bufferPoolLock.unlock()
        
        if !isReadyBufferAdapter {
            return false
        }
        
        let presentationTime = presentTimeMaker()
        
        bufferPoolLock.lock()
        let adaptionResult = bufferAdapter.append(buffer, withPresentationTime: presentationTime)
        bufferPoolLock.unlock()
        
        if !adaptionResult {
            LLog.w("adaptionResult is false.")
        }
        
        bufferPointer.deinitialize(count: 1)
        bufferPointer.deallocate()
        return true
    }
    
    private func allocateDrawnPixelBufferForImage(
        _ image: UIImage,
        bufferAdaptor: AVAssetWriterInputPixelBufferAdaptor,
        bufferPoolLock: NSLock
    ) -> UnsafeMutablePointer<CVPixelBuffer?>? {
        bufferPoolLock.lock()
        let pixelBufferPool = bufferAdaptor.pixelBufferPool
        bufferPoolLock.unlock()
        
        guard let pixelBufferPool = pixelBufferPool else {
            LLog.w("pixelBufferPool is nil.")
            return nil
        }
        
        let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: MemoryLayout<CVPixelBuffer?>.size)
        
        bufferPoolLock.lock()
        let allocationResult = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, pixelBufferPointer)
        bufferPoolLock.unlock()
        
        guard allocationResult == 0 else {
            LLog.w("allocationResult is not 0 : allocationResult: \(allocationResult).")
            pixelBufferPointer.deallocate()
            return nil
        }
        
        guard let pixelBuffer = pixelBufferPointer.pointee else {
            LLog.w("pixelBuffer is nil.")
            pixelBufferPointer.deallocate()
            return nil
        }
        
        fillPixelBufferFromImage(image, pixelBuffer: pixelBuffer)
        return pixelBufferPointer
    }
    
    private func fillPixelBufferFromImage(_ image: UIImage, pixelBuffer: CVPixelBuffer) {
        let result = CVPixelBufferLockBaseAddress(pixelBuffer, .init(rawValue: CVOptionFlags(0)))
        if result != 0 { LLog.w("Invalid result: \(result)")}
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let contextSize = image.size
        
        if let context = CGContext(data: pixelData, width: Int(contextSize.width), height: Int(contextSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) {
            var imageHeight = image.size.height
            var imageWidth = image.size.width
            
            if Int(imageHeight) > context.height {
                imageHeight = 16 * (CGFloat(context.height) / 16).rounded(.awayFromZero)
            } else if Int(imageWidth) > context.width {
                imageWidth = 16 * (CGFloat(context.width) / 16).rounded(.awayFromZero)
            }
            
            let center = type == .single ? CGPoint.zero : CGPoint(x: (720 - imageWidth) / 2, y: (720 - imageHeight) / 2)
            
            context.clear(.init(origin: .zero, size: .init(width: imageWidth, height: imageHeight)))
            
            context.setFillColor(type == .single ? UIColor.black.cgColor : UIColor.bg.cgColor)
            context.fill(.init(origin: .zero, size: .init(width: imageWidth, height: imageHeight)))
            
            context.concatenate(.identity)
            
            if let cgImage = image.cgImage {
                context.draw(cgImage, in: .init(x: center.x, y: center.y, width: imageWidth, height: imageHeight))
            } else {
                LLog.w()
            }
            
            let result = CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: .init(0)))
            if result != 0 { LLog.w("Invalid result: \(result)")}
        } else {
            LLog.w("context is nil.")
        }
    }
}
