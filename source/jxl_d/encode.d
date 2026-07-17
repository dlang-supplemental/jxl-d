module jxl_d.encode;

import std.exception : enforce;

import jxl_d.encode_libjxl;

/// Encode tightly packed RGBA8 pixels to a JPEG XL bitstream via libjxl.
///
/// `distance` follows libjxl butteraugli distance (0 = lossless; ~1.0 is
/// visually near-lossless). `effort` is 1..10 (higher = slower/better).
ubyte[] encodeRgba8(
    uint width,
    uint height,
    const(ubyte)[] rgba,
    float distance = 1.0f,
    int effort = 7,
)
{
    enforce(width > 0 && height > 0, "width/height must be positive");
    enforce(rgba.length >= cast(size_t) width * height * 4, "RGBA buffer too small");
    return encodeRgba8Libjxl(width, height, rgba, distance, effort);
}

unittest
{
    static assert(is(typeof(encodeRgba8(1, 1, new ubyte[4])) == ubyte[]));
}
