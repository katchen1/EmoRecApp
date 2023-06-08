//
//  Model.swift
//  EmoRecApp
//
//  Created by Katherine Chen on 6/7/23.
//

import UIKit
import CoreML

struct Prediction {
    var emotion: String
    var score: Double
    var emoji: String
    var multiArray: MLMultiArray
}

func predictEmotion(model: densenetmodel, image: UIImage?) -> Prediction {
    // Default return value
    var prediction = Prediction(
        emotion: "happiness",
        score: 0.5,
        emoji: emojis["happiness"]!,
        multiArray: MLMultiArray()
    )
    
    // Convert the image into 48 x 48 x 3
    if let image = image {
        let resizedImage = image.resized(to: CGSize(width: 48, height: 48))
        let pixelBuffer = resizedImage.toPixelBuffer()!
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
        let resizedUIImage = UIImage(cgImage: cgImage)
        
        guard let multiArray = try? MLMultiArray(shape: [1, 48, 48, 3], dataType: .float32) else {
            fatalError("Failed to create MLMultiArray.")
        }

        let channels = 3 // Number of color channels (RGB)
        let width = 48 // Image width
        let height = 48 // Image height
        
        for y in 0..<height {
            for x in 0..<width {
                let color = resizedUIImage.getPixelColor(pos: CGPoint(x: x, y: y))
                let index = (y * width + x) * channels
                let rgbValues = getRGBValues(from: color)
                multiArray[index] = NSNumber(value: Float(rgbValues?.red ?? 0))
                multiArray[index + 1] = NSNumber(value: Float(rgbValues?.green ?? 0))
                multiArray[index + 2] = NSNumber(value: Float(rgbValues?.blue ?? 0))
            }
        }
        
        do {
            // Pass the input into the model and make a prediction
            let modelInput = densenetmodelInput(input_1: multiArray)
            let modelOutput = try model.prediction(input: modelInput).Identity
            
            // Loop through the output MLMultiArray
            var maxIndex = 0
            var maxValue: Float = 0.0
            var sum: Float = 0.0
            for i in 0..<modelOutput.count {
                let value = modelOutput[i].floatValue
                sum += value
                if value > maxValue {
                    maxValue = value
                    maxIndex = i
                }
            }
            
            // Print model output
            print(modelOutput)
            
            // Find the predicted emotion based on model scores
            let map = [0: "anger", 1: "disgust", 2: "fear", 3: "happiness", 4: "neutral", 5: "sadness", 6: "surprise"];
            prediction = Prediction(
                emotion: map[maxIndex]!,
                score: Double(maxValue / sum),
                emoji: emojis[map[maxIndex]!]!,
                multiArray: multiArray
            )
        } catch {
            print("Error processing image: \(error)")
        }
    }
    return prediction
}

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {

        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4

        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func resized(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: newSize))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Failed to resize image.")
        }
        return resizedImage
    }
    
    func toPixelBuffer() -> CVPixelBuffer? {
        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: kCFBooleanTrue!
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(size.width),
                                         Int(size.height),
                                         kCVPixelFormatType_32BGRA,
                                         attributes as CFDictionary,
                                         &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: size.height)
        context?.scaleBy(x: 1, y: -1)
        
        UIGraphicsPushContext(context!)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return pixelBuffer
    }
}

func getRGBValues(from color: UIColor) -> (red: CGFloat, green: CGFloat, blue: CGFloat)? {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    if color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
        return (red: red, green: green, blue: blue)
    } else {
        return nil
    }
}

