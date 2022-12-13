# WCGImage

A CGImage convenience library ('Wrapped' CGImage). A CGImage is a single image representation (unlike DSFImageSource which can represent multiple images in the same file)

## Why WCGImage?

There has been quite a few times where I've had to do some form of image manipulation. While it can be relatively straight forward, now we have UIImage, NSImage and CGImage (let alone SwiftUI's Image type) to deal with.

I very often find myself falling down into `CGImage` to provide cross-platform support for image manipulations, as all of the platform-specific classes have easy methods for converting to/from.

I've collated a number of these `CGImage` routines in this simple library.

If you're performing a lot of these functions one after the other it is definitely not as performant as creating all the functions in a single context, BUT, for my needs this library is simple and easy way to avoid re-writing the same code over and over again. Also means bug fixes happen in a single place and fix across the board.

## Static routines (Swift/Objective-C)

`WCGImageStatic` provides a set of static functions for loading, manipulating and saving images.
Each function takes a `CGImage` and returns a `CGImage`.

```swift
let origImage: CGImage = ...

// Saturate the original image
let saturatedImage = try WCGImageStatic.imageByAdjustingColorsInImage(origImage, saturation: 1.6)

// Scale the saturated image
let scaled = try WCGImageStatic.imageByScalingImage(saturatedImage, scalingType: .aspectFit, to: CGSize(width: 100, height: 100))

// Draw a rounded rectangle on top of the original image
let drawn = try WCGImageStatic.imageByDrawingOnImage(origImage) { ctx, size in
   ctx.setFillColor(CGColor(srgbRed: 0, green: 0, blue: 1, alpha: 1))
   ctx.addPath(
      CGPath(
         roundedRect: CGRect(x: 10, y: 10, width: 50, height: 50),
         cornerWidth: 10, cornerHeight: 10,
         transform: nil
      )
   )
   ctx.fillPath()
}
```

### Objective-C

```objc
CGImageRef image = [WCGImageStatic CreateWithSize:CGSizeMake(80, 80)
                                  backgroundColor:NULL
                                            error:NULL :^(CGContextRef _Nonnull ctx, CGSize sz) {
   const CGFloat args[] = { 0.0, 0.0, 0.0, 1.0 };
   const CGColorRef cg1 = CGColorCreate(CGColorSpaceCreateDeviceRGB(), args);
   CGContextSetFillColorWithColor(ctx, cg1);
   CGRect r = CGRectMake(10, 10, 50, 50);
   CGContextFillRect(ctx, r);

   const CGFloat args2[] = { 1.0, 1.0, 1.0, 1.0 };
   const CGColorRef cg2 = CGColorCreate(CGColorSpaceCreateDeviceRGB(), args2);
   CGContextSetFillColorWithColor(ctx, cg2);
   CGRect r2 = CGRectMake(40, 40, 30, 30);
   CGContextFillRect(ctx, r2);
}];
```

## `WCGImage` class (Swift only)

A `WCGImage` object is a constant object containing a `CGImage`. The `CGImage` cannot be directly modified and can only be used via an operation (which returns a new constant object).

All of the methods in this class are simple wrappers around the static calls.

To provide a simple method to chain together a number of operations, for example 

```swift
let imageData = 
  try WCGImage(fileURL: imageURL)
    .rotating(by: 1.54)
    .scaling(by: 0.5)
    .grayscale()
    .jpegData()
```

Each operation returns a new `WCGImage` object.

### Creation

`WCGImage` provides a number of conveniences for creating an image, setting a background color etc.

The library can also be loaded from an NSImage or UIImage, and can convert back to the platform specific types.

### Drawing on an image

`WCGImage` provides the ability to draw on an image

```swift
let originalImage = try WCGImage(fileURL: imageURL)

// Draw a red, partially transparent rectangle on the image
let modifiedImage = try originalImage.drawing { ctx, size in
   let r = CGRect(origin: .zero, size: size).insetBy(dx: 20, dy: 20)
   ctx.setFillColor(.init(red: 1, green: 0.0, blue: 0.0, alpha: 0.4))
   ctx.fill([r])
}
```

### Modifying an image

`WCGImage` provides easy methods for

* Rotating
* Scaling (axes independent, aspect fit, aspect fill)
* Flipping
* Clipping an image to a path
* Masking an image with another image
* Tinting, grayscale, transparency
* Appling another image on top of an image.
* Adjusting colors (eg. contrast, saturation, brightness)

### Saving

`WCGImage` provides easy methods for generating data for 

* JPEG
* PNG
* TIFF

## Notes and limitations

* Loading an `NSImage` with a non-standard dpi (72.0) results in a `WCGImage` with a standard dpi
* Color spaces are tricky part 1. When working with RGBA data, `WCGImage` (currently) uses `CGColorSpace.sRGB`.
* Color spaces are tricky part 2. All `WCGImage` operations result in an sRGB colorspace image.
* The tests are very visual. The tests generate a markdown document which you can then inspect visually.

## License

```
MIT License

Copyright (c) 2022 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
