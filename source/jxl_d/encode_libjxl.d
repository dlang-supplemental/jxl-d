module jxl_d.encode_libjxl;

import std.exception : enforce;

import jxl.codestream_header;
import jxl.color_encoding;
import jxl.encode;
import jxl.types;

/// Low-level libjxl RGBA8 → JXL encode.
ubyte[] encodeRgba8Libjxl(
    uint width,
    uint height,
    const(ubyte)[] rgba,
    float distance,
    int effort,
)
{
    auto enc = JxlEncoderCreate(null);
    enforce(enc !is null, "JxlEncoderCreate failed");
    scope (exit)
        JxlEncoderDestroy(enc);

    JxlBasicInfo info;
    JxlEncoderInitBasicInfo(&info);
    info.xsize = width;
    info.ysize = height;
    info.bits_per_sample = 8;
    info.exponent_bits_per_sample = 0;
    info.alpha_bits = 8;
    info.alpha_exponent_bits = 0;
    info.num_color_channels = 3;
    info.num_extra_channels = 1;
    info.uses_original_profile = JXL_FALSE;

    enforce(JxlEncoderSetBasicInfo(enc, &info) == JXL_ENC_SUCCESS, "JxlEncoderSetBasicInfo failed");

    JxlColorEncoding color;
    JxlColorEncodingSetToSRGB(&color, JXL_FALSE);
    enforce(JxlEncoderSetColorEncoding(enc, &color) == JXL_ENC_SUCCESS, "JxlEncoderSetColorEncoding failed");

    auto settings = JxlEncoderFrameSettingsCreate(enc, null);
    enforce(settings !is null, "JxlEncoderFrameSettingsCreate failed");

    if (distance <= 0.0f)
        enforce(JxlEncoderSetFrameLossless(settings, JXL_TRUE) == JXL_ENC_SUCCESS, "lossless failed");
    else
        enforce(JxlEncoderSetFrameDistance(settings, distance) == JXL_ENC_SUCCESS, "distance failed");

    enforce(
        JxlEncoderFrameSettingsSetOption(settings, JXL_ENC_FRAME_SETTING_EFFORT, effort) == JXL_ENC_SUCCESS,
        "effort failed"
    );

    JxlPixelFormat pixelFormat;
    pixelFormat.num_channels = 4;
    pixelFormat.data_type = JXL_TYPE_UINT8;
    pixelFormat.endianness = JXL_NATIVE_ENDIAN;
    pixelFormat.align_ = 0;

    enforce(
        JxlEncoderAddImageFrame(settings, &pixelFormat, rgba.ptr, cast(size_t) width * height * 4)
            == JXL_ENC_SUCCESS,
        "JxlEncoderAddImageFrame failed"
    );
    JxlEncoderCloseInput(enc);

    ubyte[] outBuf;
    outBuf.length = 64 * 1024;
    size_t avail = outBuf.length;
    ubyte* next = outBuf.ptr;
    size_t total;

    for (;;)
    {
        auto st = JxlEncoderProcessOutput(enc, &next, &avail);
        total = next - outBuf.ptr;
        if (st == JXL_ENC_SUCCESS)
        {
            outBuf.length = total;
            return outBuf;
        }
        if (st == JXL_ENC_NEED_MORE_OUTPUT)
        {
            auto used = total;
            outBuf.length = outBuf.length * 2;
            next = outBuf.ptr + used;
            avail = outBuf.length - used;
            continue;
        }
        enforce(false, "JxlEncoderProcessOutput failed");
    }
}
