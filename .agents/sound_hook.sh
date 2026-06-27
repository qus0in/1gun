#!/bin/bash

agent="$1"
SOUND="$(dirname "$0")/sound"

if [ -n "$2" ]; then
    hook_event_name="$2"
else
    input=$(cat)
    hook_event_name=$(echo "$input" | jq -r '.hook_event_name')
fi

# [cc / ko]
# afplay $SOUND/ko/ko_h1.mp3 # 일하러 갑니다요
# afplay $SOUND/ko/ko_h2.mp3 # 그렇게 합죠
# afplay $SOUND/ko/ko_h3.mp3 # 열심히 하겠습니다
# afplay $SOUND/ko/ko_m1.mp3 # 갑니다요
# afplay $SOUND/ko/ko_m2.mp3 # 예 갑니다
# afplay $SOUND/ko/ko_s1.mp3 # 찾으셨나요
# afplay $SOUND/ko/ko_s2.mp3 # 말씀하세요
# afplay $SOUND/ko/ko_s3.mp3 # 예

# [agy / ch]
# afplay $SOUND/ch/ch_m1.mp3 # 네네 알겠습니다요
# afplay $SOUND/ch/ch_s1.mp3 # 일해야죠
# afplay $SOUND/ch/ch_s2.mp3 # 분부만 내리세요
# afplay $SOUND/ch/ch_h1.mp3 # 그렇게 합죠

# [codex / jp]
# afplay $SOUND/jp/jp_h1.mp3 # 걱정마십쇼
# afplay $SOUND/jp/jp_h2.mp3 # 녜녜 그렇게 합죠
# afplay $SOUND/jp/jp_m1.mp3 # 갑니다요
# afplay $SOUND/jp/jp_m2.mp3 # 아 녜녜
# afplay $SOUND/jp/jp_s1.mp3 # 어떤 일을 할까요
# afplay $SOUND/jp/jp_s2.mp3 # 녜녜녜녜

case "$agent" in
    cc)
        case "$hook_event_name" in
            SessionStart)      afplay "$SOUND/ko/ko_s1.mp3" ;; # 찾으셨나요
            UserPromptSubmit)  afplay "$SOUND/ko/ko_h2.mp3" ;; # 그렇게 합죠
            PermissionRequest) afplay "$SOUND/ko/ko_h3.mp3" ;; # 열심히 하겠습니다
            Notification|Stop) afplay "$SOUND/ko/ko_s2.mp3" ;; # 말씀하세요
        esac
        ;;
    agy)
        case "$hook_event_name" in
            PreInvocation) afplay "$SOUND/ch/ch_m1.mp3" ;; # 네네 알겠습니다요
            Stop)          afplay "$SOUND/ch/ch_s2.mp3" ;; # 분부만 내리세요
        esac
        ;;
    codex)
        case "$hook_event_name" in
            SessionStart)      afplay "$SOUND/jp/jp_m1.mp3" ;; # 갑니다요
            UserPromptSubmit)  afplay "$SOUND/jp/jp_h2.mp3" ;; # 녜녜 그렇게 합죠
            PermissionRequest) afplay "$SOUND/jp/jp_h1.mp3" ;; # 걱정마십쇼
            Stop)              afplay "$SOUND/jp/jp_s1.mp3" ;; # 어떤 일을 할까요
        esac
        ;;
esac
