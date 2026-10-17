import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
// usage: stitch out.png totalHeightPx cropTopPx file:offsetPx ...
let a = CommandLine.arguments
let out = a[1]; let total = Int(a[2])!; let crop = Int(a[3])!; let left = Int(a[4])!; let cw = Int(a[5])!; let chh = Int(a[6])!
var frames: [(CGImage, Int)] = []
for s in a[7...] {
  let p = s.split(separator: ":", maxSplits: 1); let path = String(p[0]); let off = Int(p[1])!
  guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil),
        let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else { fatalError("read \(path)") }
  frames.append((img, off))
}
let w = cw
let ctx = CGContext(data: nil, width: w, height: total, bitsPerComponent: 8, bytesPerRow: 0,
  space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: w, height: total))
for (img, off) in frames {
  let h = min(chh, img.height - crop)
  guard let c = img.cropping(to: CGRect(x: left, y: crop, width: w, height: h)) else { continue }
  // CG origin is bottom-left
  ctx.draw(c, in: CGRect(x: 0, y: total - off - h, width: w, height: h))
}
let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: out) as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, ctx.makeImage()!, nil); CGImageDestinationFinalize(dest)
