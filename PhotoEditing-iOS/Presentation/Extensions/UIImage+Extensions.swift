//
//  UIImage+Extensions.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 16.12.2024.
//

import Foundation
import UIKit

extension UIImage {
    func resize(_ expectedSizeInMb:Int) -> Data? {
        guard let fileSize = self.jpegData(compressionQuality: 1) else {return nil}
        let Size = CGFloat(Double(fileSize.count)/1024/1024)
        // I am checking 5 MB size here you check as you want
        if Size > CGFloat(expectedSizeInMb) {
            let sizeInBytes: CGFloat = CGFloat(expectedSizeInMb * 1024 * 1024)
            let leastExpectedSize: CGFloat = (CGFloat(expectedSizeInMb) - 1) * 1024 * 1024
            var imgData:Data?
            var start: CGFloat = 0
            var end: CGFloat = 1
            var mid: CGFloat = (end+start)/2
            while true {
                guard let resizedImage = resized(withPercentage: 0.3) else {
                    return imgData
                }
                imgData = resizedImage.jpegData(compressionQuality: CGFloat(mid))
                print("current image size \(CGFloat(imgData!.count)/(1024*1024))")
                print("1st \(start) 2nd \(mid) 3rd \(end)")
                if CGFloat(imgData?.count ?? 0) > sizeInBytes {
                    end = mid
                    mid = (start+end)/2
                } else if CGFloat(imgData?.count ?? 0) < sizeInBytes && CGFloat(imgData?.count ?? 0) < leastExpectedSize {
                    start = mid
                    mid = (start+end)/2
                } else {
                    print("returning")
                    return imgData
                }
            }
        }
        return fileSize
    }
    
    func resizeImageTo(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func resizeImageTo(newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        self.draw(in: CGRectMake(0, 0, newWidth, newHeight))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
//    func makeCroppedImage(frame: CGRect) -> UIImage? {
//        let imageSize = image.size
//        let width = cropView.frame.width / imageView.frame.width
//        let height = cropView.frame.height / imageView.frame.height
//        let x = (cropView.frame.origin.x - imageView.frame.origin.x) / imageView.frame.width
//        let y = (cropView.frame.origin.y - imageView.frame.origin.y) / imageView.frame.height
//
//        let cropFrame = CGRect(x: x * imageSize.width,
//                               y: y * imageSize.height,
//                               width: imageSize.width * width,
//                               height: imageSize.height * height)
//
//        guard let cgImage = image.cgImage?.cropping(to: cropFrame) else {
//            return nil
//        }
//
//        let cropImage = UIImage(cgImage: cgImage, scale: 1, orientation: image.imageOrientation)
//        return cropImage
//    }
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
