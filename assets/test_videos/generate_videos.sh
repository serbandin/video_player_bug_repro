#!/bin/bash
# Generate test videos from big_buck_bunny_10s.mp4
# Source: https://peach.blender.org/ (Creative Commons)

cd "$(dirname "$0")/.."

# 01 - BUG: VideoToolbox encoder (no VUI parameters = triggers Android bug)
ffmpeg -y -i big_buck_bunny_10s.mp4 \
  -c:v h264_videotoolbox -profile:v main -level:v 3.1 \
  -vf "scale=640:640,fps=60" -b:v 1500k -an \
  test_videos/01_bug_mainconcept.mp4

# 02 - FIXED: libx264 encoder (sets bitstream_restriction_flag=1)
ffmpeg -y -i big_buck_bunny_10s.mp4 \
  -c:v libx264 -profile:v main -level:v 3.1 \
  -vf "scale=640:640,fps=60" -preset medium -crf 18 -an \
  test_videos/02_fixed_libx264.mp4

echo "Done. Verify SPS parameters:"
echo "=== 01_bug_mainconcept.mp4 ==="
ffmpeg -i test_videos/01_bug_mainconcept.mp4 -c copy -bsf:v trace_headers -f null - 2>&1 | grep -E "(vui_parameters_present|bitstream_restriction)"
echo ""
echo "=== 02_fixed_libx264.mp4 ==="
ffmpeg -i test_videos/02_fixed_libx264.mp4 -c copy -bsf:v trace_headers -f null - 2>&1 | grep -E "(vui_parameters_present|bitstream_restriction)"
