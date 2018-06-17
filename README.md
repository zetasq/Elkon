# Elkon

A modern image loading framework in Swift (supports **PNG**, **JPG**, **GIF**, **WEBP**)

[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Installation
### Carthage
To integrate **Elkon** into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), specify it in your `Cartfile`:

```ogdl
github "zetasq/Elkon"
```

Run `carthage update` to build the framework. **Elkon** has [SwiftCache](https://github.com/zetasq/SwiftCache) and [CWebP](https://github.com/zetasq/CWebP) as dependencies. Drag the built `Elkon.framework`, `SwiftCache.framework` and `CWebP.framework` into your Xcode project.

## Usage

Instead of using bare `UIImageView`, you create `ElkonImageView` (a light-weight subclass of `UIImageView`) to access the powerful **Elkon** APIs.

```swift
let iconView = ElkonImageView()

// load image by url (supports local file url)
iconView.elkon.loadImage(at: URL(string: "my-image-url", placeholder: UIImage(named: "iconPlaceholder", animated: true)

// load UIImage directly
let image = UIImage(named: "icon-image")
iconView.elkon.load(uiImage: image, placeholder: nil, animated: true)

// Image resizing and cornerRadius support
let renderConfig = ImageRenderConfig(sizeInPoints: CGSize(width: 50, height: 50), cornerRadiusInPoints: 5, scaleMode: .fill)
iconView.elkon.loadImage(at: url, renderConfig: renderConfig, placeholder: nil, animated: true)
```

## License

**Elkon** is released under the MIT license. [See LICENSE](https://github.com/zetasq/Elkon/blob/master/LICENSE) for details.
