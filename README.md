# DSFImageTools

* **DSFImageSource**: A wrapper around CGImageSource to provide conveniences for dealing with (potentially) multi-image images

* **WCGImage**: A CGImage convenience library ('Wrapped' CGImage) providing ability to modify/draw on an image

<p align="center">
    <img src="https://img.shields.io/github/v/tag/dagronf/DSFImageTools" />
    <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
</p>
<p align="center">
    <img src="https://img.shields.io/badge/macOS-10.11+-red" />
    <img src="https://img.shields.io/badge/iOS-13+-blue" />
    <img src="https://img.shields.io/badge/tvOS-13+-orange" />
    <img src="https://img.shields.io/badge/macCatalyst-1.0+-purple" />
</p>
<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.4-blueviolet" />
    <img src="https://img.shields.io/badge/ObjectiveC-2.0-ff69b4" />
    <img src="https://img.shields.io/badge/SwiftUI-2.0+-9cf" />
</p>

## Why DSFImageSource?

* Provides lower-level information access to an image. For example, GPS data cannot be loaded from an `NSImage`.
* Support for images with multiple frames (like gifs, multipage tiff files etc.)
* Create a image file with multiple frames

[Information about DSFImageSource](./README+DSFImageSource.md)

## Why WCGImage?

There has been quite a few times where I've had to do some form of image manipulation. While it can be relatively straight forward, now we have UIImage, NSImage and CGImage (let alone SwiftUI's Image type) to deal with.

I very often find myself falling down into `CGImage` to provide cross-platform support for image manipulations, as all of the platform-specific classes have easy methods for converting to/from.

I've collated a number of these `CGImage` routines in this simple library.

If you're performing a lot of these functions one after the other it is definitely not as performant as creating all the functions in a single context, BUT, for my needs this library is simple and easy way to avoid re-writing the same code over and over again. Also means bug fixes happen in a single place and fix across the board.

[Information about WCGImage](./README+WCGImage.md)

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
