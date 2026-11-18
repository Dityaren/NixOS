{ ... }:

{
  flake.nixosModules.ffmpeg =
    {
      vars,
      pkgs,
      ...
    }:
    let
      nvenc = "-preset p5 -tune hq -rc vbr -b:v 0 -spatial-aq 1 -rc-lookahead 32";

      fn = description: body: { inherit description body; };
    in
    {
      environment.systemPackages = [ pkgs.ffmpeg ];

      home-manager.users.${vars.username}.programs.fish.functions = {
        _qpeg_out = fn "Default output name for ffmpeg presets" ''
          printf '%s_%s.%s\n' (string replace -r '\.[^./]+$' "" -- $argv[1]) $argv[2] $argv[3]
        '';

        qpeg-hevc = fn "GPU HEVC (NVENC): qpeg-hevc in [out] [cq=23]" ''
          if test (count $argv) -lt 1
            echo "usage: qpeg-hevc input [output] [cq=23]"
            return 1
          end
          set -l out (set -q argv[2]; and echo $argv[2]; or _qpeg_out $argv[1] hevc mp4)
          set -l cq 23
          set -q argv[3]; and set cq $argv[3]
          ffmpeg -hide_banner -n -hwaccel cuda -i $argv[1] \
            -c:v hevc_nvenc ${nvenc} -cq $cq -tag:v hvc1 -c:a copy $out
        '';

        qpeg-hevc-cpu = fn "CPU x265 (slow, smallest): qpeg-hevc-cpu in [out] [crf=20]" ''
          if test (count $argv) -lt 1
            echo "usage: qpeg-hevc-cpu input [output] [crf=20]"
            return 1
          end
          set -l out (set -q argv[2]; and echo $argv[2]; or _qpeg_out $argv[1] x265 mp4)
          set -l crf 20
          set -q argv[3]; and set crf $argv[3]
          ffmpeg -hide_banner -n -i $argv[1] \
            -c:v libx265 -crf $crf -preset slow -tag:v hvc1 -c:a copy $out
        '';

        qpeg-h264 = fn "GPU H.264 for maximum compatibility: qpeg-h264 in [out] [cq=23]" ''
          if test (count $argv) -lt 1
            echo "usage: qpeg-h264 input [output] [cq=23]"
            return 1
          end
          set -l out (set -q argv[2]; and echo $argv[2]; or _qpeg_out $argv[1] h264 mp4)
          set -l cq 23
          set -q argv[3]; and set cq $argv[3]
          ffmpeg -hide_banner -n -hwaccel cuda -i $argv[1] \
            -c:v h264_nvenc ${nvenc} -cq $cq -pix_fmt yuv420p -c:a copy $out
        '';

        qpeg-av1 = fn "GPU AV1 (RTX 40-series or newer): qpeg-av1 in [out] [cq=30]" ''
          if test (count $argv) -lt 1
            echo "usage: qpeg-av1 input [output] [cq=30]"
            return 1
          end
          set -l out (set -q argv[2]; and echo $argv[2]; or _qpeg_out $argv[1] av1 mp4)
          set -l cq 30
          set -q argv[3]; and set cq $argv[3]
          ffmpeg -hide_banner -n -hwaccel cuda -i $argv[1] \
            -c:v av1_nvenc ${nvenc} -cq $cq -c:a copy $out
        '';

        qpeg-shrink = fn "Small shareable copy: qpeg-shrink in [height=1080] [out]" ''
          if test (count $argv) -lt 1
            echo "usage: qpeg-shrink input [height=1080] [output]"
            return 1
          end
          set -l h 1080
          set -q argv[2]; and set h $argv[2]
          set -l out (set -q argv[3]; and echo $argv[3]; or _qpeg_out $argv[1] $h"p" mp4)
          ffmpeg -hide_banner -n -hwaccel cuda -i $argv[1] \
            -vf scale=-2:$h -c:v hevc_nvenc ${nvenc} -cq 28 -tag:v hvc1 \
            -c:a aac -b:a 128k $out
        '';

        qpeg-trim = fn "Cut without re-encoding: qpeg-trim in start end [out]" ''
          if test (count $argv) -lt 3
            echo "usage: qpeg-trim input start end [output]   (e.g. qpeg-trim a.mp4 00:01:00 00:02:30)"
            return 1
          end
          set -l ext (string match -r '[^.]+$' -- $argv[1])
          set -l out (set -q argv[4]; and echo $argv[4]; or _qpeg_out $argv[1] trim $ext)
          ffmpeg -hide_banner -n -ss $argv[2] -to $argv[3] -i $argv[1] -c copy $out
        '';

        qpeg-mute = fn "Remove the audio track: qpeg-mute in [out]" ''
          if test (count $argv) -lt 1
            echo "usage: qpeg-mute input [output]"
            return 1
          end
          set -l ext (string match -r '[^.]+$' -- $argv[1])
          set -l out (set -q argv[2]; and echo $argv[2]; or _qpeg_out $argv[1] mute $ext)
          ffmpeg -hide_banner -n -i $argv[1] -c:v copy -an $out
        '';

        qpeg-remux = fn "Change container only: qpeg-remux in [out.mp4]" ''
          if test (count $argv) -lt 1
            echo "usage: qpeg-remux input [output.mp4]"
            return 1
          end
          set -l out (set -q argv[2]; and echo $argv[2]; or _qpeg_out $argv[1] remux mp4)
          ffmpeg -hide_banner -n -i $argv[1] -c copy $out
        '';

        qpeg-mp3 = fn "Extract audio as MP3 (VBR ~190k): qpeg-mp3 in [out]" ''
          if test (count $argv) -lt 1
            echo "usage: qpeg-mp3 input [output]"
            return 1
          end
          set -l out (set -q argv[2]; and echo $argv[2]; or _qpeg_out $argv[1] audio mp3)
          ffmpeg -hide_banner -n -i $argv[1] -vn -c:a libmp3lame -q:a 2 $out
        '';

        qpeg-togif = fn "Video to GIF: qpeg-togif in [width=480] [fps=15] [out]" ''
          if test (count $argv) -lt 1
            echo "usage: qpeg-togif input [width=480] [fps=15] [output]"
            return 1
          end
          set -l w 480
          set -l fps 15
          set -q argv[2]; and set w $argv[2]
          set -q argv[3]; and set fps $argv[3]
          set -l out (set -q argv[4]; and echo $argv[4]; or _qpeg_out $argv[1] gif gif)
          ffmpeg -hide_banner -n -i $argv[1] \
            -vf "fps=$fps,scale=$w:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse" \
            $out
        '';

        qpeg-fps = fn "Change frame rate: qpeg-fps in rate [out]" ''
          if test (count $argv) -lt 2
            echo "usage: qpeg-fps input rate [output]   (e.g. qpeg-fps a.mp4 30)"
            return 1
          end
          set -l rate $argv[2]
          set -l out (set -q argv[3]; and echo $argv[3]; or _qpeg_out $argv[1] $rate"fps" mp4)
          ffmpeg -hide_banner -n -hwaccel cuda -i $argv[1] \
            -vf fps=$rate -c:v hevc_nvenc ${nvenc} -cq 23 -tag:v hvc1 -c:a copy $out
        '';

        qpeg-fps-smooth = fn "Interpolate to a higher frame rate: qpeg-fps-smooth in rate [out]" ''
          if test (count $argv) -lt 2
            echo "usage: qpeg-fps-smooth input rate [output]   (e.g. qpeg-fps-smooth a.mp4 60)"
            return 1
          end
          set -l rate $argv[2]
          set -l out (set -q argv[3]; and echo $argv[3]; or _qpeg_out $argv[1] $rate"fps-smooth" mp4)
          ffmpeg -hide_banner -n -i $argv[1] \
            -vf "minterpolate=fps=$rate:mi_mode=mci:mc_mode=aobmc:vsbmc=1" \
            -c:v hevc_nvenc ${nvenc} -cq 23 -tag:v hvc1 -c:a copy $out
        '';

        qpeg-help = fn "List every qpeg command and what it does" ''
          echo "qpeg: ffmpeg presets. GPU = NVIDIA NVENC. Format: command input [optional args]

          ENCODE
            qpeg-hevc      in [out] [cq=23]       GPU HEVC, audio copied. Lower cq = better, bigger.
            qpeg-hevc-cpu  in [out] [crf=20]      CPU x265 (slow). Smallest files for the quality.
            qpeg-h264      in [out] [cq=23]       GPU H.264, plays on almost any device.
            qpeg-av1       in [out] [cq=30]       GPU AV1. Needs an RTX 40-series card or newer.
            qpeg-shrink    in [height=1080] [out] Small copy for sharing: downscaled, AAC audio.

          FRAME RATE
            qpeg-fps         in rate [out]        Change fps by dropping/repeating frames (fast).
            qpeg-fps-smooth  in rate [out]        Interpolate new frames, e.g. 30 to 60 (slow, CPU).

          CUT AND CONVERT (no re-encode unless noted)
            qpeg-trim   in start end [out]        Lossless cut, snaps to keyframes. 00:01:00 00:02:30
            qpeg-mute   in [out]                  Remove the audio track.
            qpeg-remux  in [out.mp4]              Change container only, e.g. mkv to mp4.
            qpeg-mp3    in [out]                  Extract audio as MP3 (re-encodes audio).
            qpeg-togif  in [width=480] [fps=15] [out]  Video to GIF with a proper palette.

          INFO
            qpeg-info   file                      Codecs, resolution, fps, bitrate, duration.

          Output goes next to the input as name_suffix.ext (e.g. clip_hevc.mp4).
          Existing files are never overwritten. Run any command with no arguments for usage."
        '';

        qpeg-info = fn "Short stream summary: qpeg-info file" ''
          ffprobe -v error \
            -show_entries stream=index,codec_type,codec_name,width,height,r_frame_rate,bit_rate \
            -show_entries format=duration,size \
            -of default=nw=1 $argv[1]
        '';
      };
    };
}
