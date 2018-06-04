# Elkon

A modern image loading framework in Swift (supports **PNG**, **JPG**, **GIF**, **WEBP**)

[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Installation
### Carthage
To integrate **Elkon** into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), specify it in your `Cartfile`:

```ogdl
github "zetasq/Elkon"
```

Run `carthage update` to build the framework. **Elkon** has [SwiftCache](https://github.com/Carthage/SwiftCache) and [CWebP](https://github.com/Carthage/CWebP) as dependencies. Drag the built `Elkon.framework`, `SwiftCache.framework` and `CWebP.framework` into your Xcode project.

## Usage

Instead of using bare `UIImageView`, you create `ElkonImageView` (a light-weight subclass of `UIImageView`) to access the powerful **Elkon** APIs.

```swift
let iconView = ElkonImageView()

// load image by url (supports local file url)
iconView.elkon.loadImage(at: URL(string: "my-image-url", placeholder: UIImage(named: "iconPlaceholder", animated: true)

// load image in bundle
iconView.elkon.loadUIImage(named: "myImageName", bundle: .main, animated: true)

// load custom **UIImage** object directly
let myCustomImage: UIImage = MakeCustomUIImage()
iconView.elkon.load(uiImage: myCustomImage, animated: true)
```

## License

**Elkon** is released under the MIT license. [See LICENSE](https://github.com/zetasq/Elkon/blob/master/LICENSE) for details.
