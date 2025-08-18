<div align="center">
<img src="https://github.com/ChifiSource/image_dump/raw/main/olive/0.1/extensions/oliveimages.png" /img>
</div>

##### currently undergoing a full rebuild into 0.2. This package shall be available soon!

The `OliveImages` module provides [Olive](https://github.com/ChifiSource/Olive.jl) with the ability to read and work with image files, including
- SVG files
- PNG files
- GIF files
- and JPG files.
```julia
using Pkg

Pkg.add("OliveImages"
```
- **note** `OliveImages` is an `Olive` extension; it requires [olive](https://github.com/ChifiSource/Olive.jl).

Add this package to your `Olive` by loading it before entering headless mode, or adding it via the `:home` directory in `Olive`. Learn more at [installing extensions](https://chifidocs.com/olive/Olive/installing-extensions).
```julia
using OliveImages; using OliveImages.Olive; Olive.start(headless = true)
```

<div align="center">
<img src="https://github.com/ChifiSource/image_dump/blob/main/olive/doc92sc/extimages.png"></img>
</div>
