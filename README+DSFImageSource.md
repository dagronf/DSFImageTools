# DSFImageSource

A wrapper around CGImageSource to provide conveniences for dealing with (potentially) multi-image images

## Why DSFImageSource?

* Provides lower-level information access to an image. For example, GPS data cannot be loaded from an `NSImage`.
* Support for images with multiple frames (like gifs, multipage tiff files etc.)
* Create a image file with multiple frames


## `DSFImageSource`

The primary image wrapper.

### Properties

| Property | Type | Description |
|:---|---|:---|
| `imageSource` | `CGImageSource` | The underlying image source |
| `type` | `String` | The type of the image source, or nil for no type |
| `count` | `Int` | The number of images in the source |
| `[Int]` | `DSFImageSource.Image?` | A subscript for returning the image at the specified index |
| `hasLocation` | `Bool` | True if the image source contains location information |
| `location` | `DSFImageSource.GPSCoordinates?` | The location coordinates for the image, or nil if no location information exists |
| `first` | `DSFImageSource.Image?` | The first image in the image source, or nil for no images |
| `images` | `[DSFImageSource.Image]` | The array of images within the image source |
| `cgImages` | `[CGImage]` | An array of `CGImage`s within the image source |

### Methods

| Method | Description |
|:---|:---|
| `data` | Returns the image data for the source |
| `image` | Return the platform-specific image (`NSImage`/`UIImage`) for the image source |

## `DSFImageSource.Image`

A representation of an image within the image source

### Properties

| Property | Type | Description |
|:---|---|:---|
| `pixelSize` | `CGSize` | The pixel dimensions for the image |
| `properties` | `[String : Any]` | The raw properties for the image |
| `orientation` | `CGImagePropertyOrientation` | The embedded orientation information for the image |
| `exifProperties` | `[String : Any]` | The exif properties for the image |
| `gpsProperties` | `[String : Any]` | The gps properties for the image |
| `hasLocation` | `Bool` | True if the image contains location information |
| `location` | `DSFImageSource.GPSCoordinates?` | The location coordinates for the image, or nil if no location information exists |
| `gifProperties` | `[String : Any]` | The gif properties for the image |
| `gifDuration` | `CFTimeInterval` | For a GIF frame, the duration that the frame should display on screen |
| `gifProperties` | `[String : Any]` | The gif properties for the image |
| `image` | `CGImage?` | A CGImage representation of the image |
| `nsImage` | `NSImage?` | An NSImage representation of the image |
| `uiImage` | `UIImage?` | A UIImage representation of the image |

### Methods

| Method | Description |
|:---|:---|
| `imageData` | Returns the data for the image for a given image type |
| `thumbnail` | Return a thumbnail representation for the image |
| `removingOrientation` | Return a CGImage representation that matches the input image but transformed to using the 'up' orientation |

## Examples

```swift
// Load the image source from a file
let imageSource = DSFImageSource(fileURL: fileURL)

// Get the number of images within the image source
let numberOfImages = imageSource.count

if let firstImage = imageSource[0] {

   // Get orientation information from this image
   let orientation = firstImage.orientation

   if orientation != .up {
      // Transform the image so that its embedded orientation is 'up'.
      let transformed = firstImage.removingOrientation()
   }

   // Get location information from this image
   let location = firstImage.location

   // Get a jpeg representation of the image
   let jpegData = firstImage.imageData(type: .jpeg, compression: 0.8)
}

// Extract an HEIC representation of the image source, removing GPS data
let heic = imageSource.data(imageType: .heic, removeGPSData: false)
```

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
