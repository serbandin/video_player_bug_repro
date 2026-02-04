# Android Video Player Bug Analysis

## Issue
H.264 videos encoded with **Mainconcept encoder** fail to play on Android with error:
```
Format exceeds selected codec's capabilities [res=640x640, fps=60.0]
```

## Root Cause
**Missing `bitstream_restriction_flag` in SPS VUI parameters.**

Mainconcept encoder sets `bitstream_restriction_flag=0`, which causes Android MediaCodec to calculate worst-case DPB (Decoded Picture Buffer) requirements. For 640x640@60fps at Level 3.1, this exceeds the decoder's capability check.

### Technical Details

| Parameter | Mainconcept (FAILS) | libx264 (WORKS) |
|-----------|---------------------|-----------------|
| `vui_parameters_present_flag` | 1 | 1 |
| `bitstream_restriction_flag` | **0** | **1** |
| `max_dec_frame_buffering` | N/A | 1-3 |

When `bitstream_restriction_flag=0`, Android assumes worst-case buffer requirements based on Level limits, which fails the capability check for high-fps square videos at Level 3.1.

### Additional Finding
Videos with NO VUI at all (`vui_parameters_present_flag=0`) also fail, as this is equivalent to having no bitstream restrictions specified.

## Solution
Re-encode videos with an encoder that properly sets `bitstream_restriction_flag=1`:

```bash
ffmpeg -i input.mp4 -c:v libx264 -profile:v main -level:v 3.1 \
       -preset medium -crf 18 output.mp4
```

## Test Videos

Located in `assets/test_videos/`:

- `01_bug_mainconcept.mp4` - Original Mainconcept video (bitstream_restriction_flag=0) - **FAILS on Android**
- `02_fixed_libx264.mp4` - Re-encoded with libx264 (bitstream_restriction_flag=1) - **WORKS on Android**

## Affected Configurations
- Resolution: 640x640 (or similar high macroblock count)
- Frame rate: 60fps
- Profile: Main
- Level: 3.1
- Encoder: Mainconcept (or any encoder that omits bitstream_restriction)
