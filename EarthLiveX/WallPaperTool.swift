//
//  WallPaperTool.swift
//  EarthLiveX
//
//  Created by Ryinn on 2022/3/23.
//

import Foundation
import Request
import AppKit
import Wallpaper

func getLaestImg() -> Void {
    
    let latestUrl: String = "https://himawari8-dl.nict.go.jp/himawari8/img/D531106/latest.json"
    var latest: String!
    Request {
        Url(latestUrl)
        Header.Accept(.json)
    }
    .onJson { json in
        print("latest image: \(json)")
        latest = json["date"].string
        let date = dateFormat(date: latest)
        downloadImg(time: date)
    }
    .call()
    
}

func downloadImg(time: String){
    // https://himawari8-dl.nict.go.jp/himawari8/img/D531106/2d/550/2022/03/23/070000_0_0.png
    // https://himawari8-dl.nict.go.jp/himawari8/img/D531106/2d/550/2022/03/23/070000_0_1.png
    // https://himawari8-dl.nict.go.jp/himawari8/img/D531106/2d/550/2022/03/23/070000_1_0.png
    // https://himawari8-dl.nict.go.jp/himawari8/img/D531106/2d/550/2022/03/23/070000_1_1.png
    
    RequestChain {
        Request.chained { (data, errors) in
            Url("https://himawari8-dl.nict.go.jp/himawari8/img/D531106/2d/550/\(time)_0_1.png")
            Header.Accept(.png)
        }
        Request.chained { (data, errors) in
            Url("https://himawari8-dl.nict.go.jp/himawari8/img/D531106/2d/550/\(time)_1_1.png")
            Header.Accept(.png)
        }
        Request.chained { (data, errors) in
            Url("https://himawari8-dl.nict.go.jp/himawari8/img/D531106/2d/550/\(time)_0_0.png")
            Header.Accept(.png)
        }
        Request.chained { (data, errors) in
            Url("https://himawari8-dl.nict.go.jp/himawari8/img/D531106/2d/550/\(time)_1_0.png")
            Header.Accept(.png)
        }
    }.call { (data, errors) in
        saveImage(data: data, time: time)
    }
}

func saveImage(data: [Data?], time: String){
    let earthImage: NSImage = NSImage(size: NSSize(width: 2500, height: 1400))
    earthImage.lockFocus()
    let imageContext: CGContext? = NSGraphicsContext.current?.cgContext
    let centerX: CGFloat = earthImage.size.width / 2
    let centerY: CGFloat = earthImage.size.height / 2
    var imgX: CGFloat = centerX - 550
    var imgY: CGFloat = centerY - 550
    imageContext?.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 100))
    imageContext?.fill(CGRect(x: 0, y: 0, width: earthImage.size.width, height: earthImage.size.height))
    for (index, img) in data.enumerated() {
        let image: NSImage = NSImage.init(data: img!)!
        let imgRef: CGImage = getCGImageRefFromNSImage(image: image)!
        imageContext?.draw(imgRef, in: NSRect(x: imgX, y: imgY, width: image.size.width, height: image.size.height))
        imgX += image.size.width
        if (index == 1) {
            imgX = centerX - 550
        }
        if (index == 1 || index == 2) {
            imgY = centerY
        }
    }
    earthImage.unlockFocus()
    let path = NSSearchPathForDirectoriesInDomains(.picturesDirectory, .userDomainMask, true)[0] + "/earth.png"
    
    let earth: NSData = compressedImageDataWithImg(image: earthImage, rate: 1.0)!
    let result = FileManager.default.createFile(atPath: path, contents: earth as Data, attributes: nil)
    if result {
        print(path)
        setWallpaper(path: path)
    }
}

func dateFormat(date: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let now = formatter.date(from: date)
    formatter.dateFormat = "yyyy/MM/dd/HHmmss"
    let latestDate = formatter.string(from: now!)
    return latestDate
}

func getCGImageRefFromNSImage(image: NSImage) -> CGImage? {
    let imageData: NSData? = image.tiffRepresentation as NSData?
    var imageRef: CGImage? = nil
    if(imageData != nil) {
        let imageSource: CGImageSource = CGImageSourceCreateWithData(imageData! as CFData, nil)!

        imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
    }
    return imageRef;
}

func compressedImageDataWithImg(image: NSImage, rate: CGFloat) -> NSData? {
    guard let imageData = image.tiffRepresentation,
          let imageRep = NSBitmapImageRep(data: imageData) else { return nil }
    guard let data: Data = imageRep.representation(using: .jpeg, properties:[.compressionFactor:rate]) else { return nil }
    return data as NSData;
}

func setWallpaper(path: String){
    let imgUrl = URL(fileURLWithPath: path, isDirectory: false)
    print(imgUrl)
    do {
        try Wallpaper.set(imgUrl, screen: .all, scale: .fill)
    } catch {
        print("设置失败")
        try? Wallpaper.set(imgUrl, screen: .all, scale: .fill)
    }
    
}

func resizeImage(sourceImage: NSImage, forSize targetSize: CGSize) -> NSImage {

    let imageSize: CGSize = sourceImage.size
    let width: CGFloat = imageSize.width
    let height: CGFloat = imageSize.height
    let targetWidth: CGFloat = targetSize.width
    let targetHeight: CGFloat = targetSize.height
    var scaleFactor: CGFloat = 0.0
    var scaledWidth: CGFloat = targetWidth
    var scaledHeight: CGFloat = targetHeight
    var thumbnailPoint: CGPoint = CGPoint(x: 0.0, y: 0.0)

    if __CGSizeEqualToSize(imageSize, targetSize) == false {
        let widthFactor: CGFloat = targetWidth / width
        let heightFactor:  CGFloat = targetHeight / height

        // scale to fit the longer
        scaleFactor = (widthFactor > heightFactor) ? widthFactor : heightFactor
        scaledWidth  = ceil(width * scaleFactor)
        scaledHeight = ceil(height * scaleFactor)

        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
        }
    }

    let newImage: NSImage = NSImage(size: NSSize(width: scaledWidth, height: scaledHeight))
    let thumbnailRect: CGRect = CGRect(x: thumbnailPoint.x, y: thumbnailPoint.y, width: scaledWidth, height: scaledHeight)
    let imageRect: NSRect = NSRect(x: 0.0, y:0.0, width: width, height: height)

    newImage.lockFocus()
    sourceImage.draw(in: thumbnailRect, from: imageRect, operation: .copy, fraction: 1.0)
    newImage.unlockFocus()

    return newImage;
}
