#!/bin/bash

agent="$1"
SOUND="$(dirname "$0")/sound"

input=""

if [ -n "$2" ]; then
    hook_event_name="$2"

    # agy PreInvocation에서도 payload는 stdin JSON으로 들어오므로
    # invocationNum은 인자가 아니라 jq로 읽는다.
    input=$(cat)
    invocation_num=$(echo "$input" | jq -r '.invocationNum // empty')
else
    input=$(cat)
    hook_event_name=$(echo "$input" | jq -r '.hook_event_name // empty')
    # invocation_num=$(echo "$input" | jq -r '.invocationNum // empty')
fi

play() {
    local file="$1"
    case "$(uname -s)" in
        Darwin)
            afplay "$file" ;;
        Linux)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                # WSL: Windows PowerShell로 재생
                local winpath
                winpath=$(wslpath -w "$file")
                powershell.exe -c "
                    Add-Type -AssemblyName presentationCore
                    \$p = New-Object System.Windows.Media.MediaPlayer
                    \$p.Open([uri]'$winpath')
                    \$p.Play()
                    Start-Sleep -Milliseconds 3000
                " 2>/dev/null
            elif command -v paplay &>/dev/null; then
                paplay "$file"
            elif command -v aplay &>/dev/null; then
                aplay "$file" 2>/dev/null
            elif command -v ffplay &>/dev/null; then
                ffplay -nodisp -autoexit "$file" &>/dev/null
            elif command -v mpg123 &>/dev/null; then
                mpg123 -q "$file"
            fi ;;
        MINGW*|MSYS*|CYGWIN*)
            # Git Bash / MSYS2
            local winpath
            winpath=$(cygpath -w "$file")
            powershell.exe -c "
                Add-Type -AssemblyName presentationCore
                \$p = New-Object System.Windows.Media.MediaPlayer
                \$p.Open([uri]'$winpath')
                \$p.Play()
                Start-Sleep -Milliseconds 3000
            " 2>/dev/null ;;
    esac
}

# [cc / ko]
# play $SOUND/ko/ko_h1.mp3 # 일하러 갑니다요
# play $SOUND/ko/ko_h2.mp3 # 그렇게 합죠
# play $SOUND/ko/ko_h3.mp3 # 열심히 하겠습니다
# play $SOUND/ko/ko_m1.mp3 # 갑니다요
# play $SOUND/ko/ko_m2.mp3 # 예 갑니다
# play $SOUND/ko/ko_s1.mp3 # 찾으셨나요
# play $SOUND/ko/ko_s2.mp3 # 말씀하세요
# play $SOUND/ko/ko_s3.mp3 # 예

# [agy / ch]
# play $SOUND/ch/ch_m1.mp3 # 네네 알겠습니다요
# play $SOUND/ch/ch_s1.mp3 # 일해야죠
# play $SOUND/ch/ch_s2.mp3 # 분부만 내리세요
# play $SOUND/ch/ch_h1.mp3 # 그렇게 합죠

# [codex / jp]
# play $SOUND/jp/jp_h1.mp3 # 걱정마십쇼
# play $SOUND/jp/jp_h2.mp3 # 녜녜 그렇게 합죠
# play $SOUND/jp/jp_m1.mp3 # 갑니다요
# play $SOUND/jp/jp_m2.mp3 # 아 녜녜
# play $SOUND/jp/jp_s1.mp3 # 어떤 일을 할까요
# play $SOUND/jp/jp_s2.mp3 # 녜녜녜녜

case "$agent" in
    cc)
        case "$hook_event_name" in
            SessionStart)      play "$SOUND/ko/ko_s1.mp3" ;; # 찾으셨나요
            UserPromptSubmit)  play "$SOUND/ko/ko_h2.mp3" ;; # 그렇게 합죠
            PermissionRequest) play "$SOUND/ko/ko_h3.mp3" ;; # 열심히 하겠습니다
            Notification|Stop) play "$SOUND/ko/ko_s2.mp3" ;; # 말씀하세요
        esac
        ;;
    agy)
        case "$hook_event_name" in
            PreInvocation)
                if [ "$invocation_num" = "0" ]; then
                    play "$SOUND/ch/ch_m1.mp3" # 네네 알겠습니다요
                fi
                ;;
            Stop)          play "$SOUND/ch/ch_s2.mp3" ;; # 분부만 내리세요
        esac
        ;;
    codex)
        case "$hook_event_name" in
            SessionStart)      play "$SOUND/jp/jp_m1.mp3" ;; # 갑니다요
            UserPromptSubmit)  play "$SOUND/jp/jp_h2.mp3" ;; # 녜녜 그렇게 합죠
            PermissionRequest) play "$SOUND/jp/jp_h1.mp3" ;; # 걱정마십쇼
            Stop)              play "$SOUND/jp/jp_s1.mp3" ;; # 어떤 일을 할까요
        esac
        ;;
esac