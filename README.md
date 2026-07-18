# jxl-d

Unified JPEG XL API for D:

* **Decode** via [`jxl-rs-d`](https://github.com/dlang-supplemental/jxl-rs-d)
  (official Rust `jxl-rs` decoder — same family as Chrome/Firefox)
* **Encode** via [`libjxl-d`](https://github.com/bildhuus/libjxl-d) (libjxl C API)

## Site

https://dlang-supplemental.github.io/jxl-d/

## Quick start

```d
import jxl_d;

void main()
{
    // Decode (jxl-rs)
    auto img = decodeRgba8(cast(immutable(ubyte)[]) std.file.read("in.jxl"));

    // Encode (libjxl) — optional path; available even if unused for now
    auto bytes = encodeRgba8(img.width, img.height, img.pixels);
}
```

## Changelog

See [CHANGELOG](CHANGELOG.adoc).

## License

BSD-3-Clause.
