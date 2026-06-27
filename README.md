# 1ggun

**Claude Code**, **Codex**, **Antigravity CLI**에 사운드 훅 추가. 각 에이전트마다 다른 목소리가 이벤트에 반응함.

[PeonPing](http://peonping.com/)에서 아이디어를 얻어 훅(hooks)과 셸 스크립트로 구현.

## 지원 환경

| OS                       | 재생 방식                                                |
| ------------------------ | -------------------------------------------------------- |
| macOS                    | `afplay`                                                 |
| Linux                    | `paplay` / `aplay` / `ffplay` / `mpg123` (순서대로 시도) |
| Windows (Git Bash / WSL) | PowerShell MediaPlayer                                   |

## 설치

프로젝트 루트에서 실행. 동일한 명령어 재실행으로 업데이트 가능.

### macOS

`curl`, `jq` 기본 사용. `jq`가 없다면 Homebrew로 설치:

```bash
brew install jq
curl -fsSL https://raw.githubusercontent.com/qus0in/1ggun/main/install.sh | bash
```

### Linux

`curl`, `jq` 필요. 패키지 매니저로 설치:

```bash
# Debian / Ubuntu
sudo apt install -y curl jq

# Fedora / RHEL
sudo dnf install -y curl jq
```

```bash
curl -fsSL https://raw.githubusercontent.com/qus0in/1ggun/main/install.sh | bash
```

### Windows

**Git Bash 또는 WSL2 환경을 권장.** PowerShell이나 cmd에서는 동작하지 않음.

설치 스크립트는 아래 순서로 JSON 처리 방법을 자동 감지:

1. 설정 파일 미존재 시 → 직접 생성
2. `jq` 설치 확인 → jq로 머지
3. `python3` / `python` 설치 확인 → Python으로 머지
4. 모두 불가 시 → 덮어쓰기 여부 사용자 확인 (거부 시 설치 취소)

**Git Bash** ([Git for Windows](https://gitforwindows.org/) 포함):

```bash
curl -fsSL https://raw.githubusercontent.com/qus0in/1ggun/main/install.sh | bash
```

**WSL2** (Ubuntu 등):

```bash
sudo apt install -y curl jq
curl -fsSL https://raw.githubusercontent.com/qus0in/1ggun/main/install.sh | bash
```

---

생성/수정되는 파일:

```
.agents/
  sound_hook.sh        # 훅 실행 스크립트
  sound/               # MP3 파일들
  hooks.json           # AGY 훅 설정
.claude/
  settings.json        # Claude Code 훅 설정
.codex/
  hooks.json           # Codex 훅 설정
```

## 에이전트별 목소리

| 에이전트        | 인자    | 목소리    |
| --------------- | ------- | --------- |
| Claude Code     | `cc`    | 조선 일꾼 |
| Codex           | `codex` | 일본 일꾼 |
| Antigravity CLI | `agy`   | 명 일꾼   |

## 이벤트 매핑

| 이벤트            | cc (조선 일꾼)    | codex (일본 일꾼) | agy (명 일꾼)     |
| ----------------- | ----------------- | ----------------- | ----------------- |
| SessionStart      | 찾으셨나요        | 갑니다요          | -                 |
| UserPromptSubmit  | 그렇게 합죠       | 녜녜 그렇게 합죠  | -                 |
| PermissionRequest | 열심히 하겠습니다 | 걱정마십쇼        | -                 |
| Notification      | 말씀하세요        | -                 | -                 |
| Stop              | 말씀하세요        | 어떤 일을 할까요  | 분부만 내리세요   |
| PreInvocation     | -                 | -                 | 네네 알겠습니다요 |

## 사운드 파일 목록

`.agents/sound/` 하위 구성. 이벤트 매핑에 쓰이지 않는 파일도 포함되어 있으며, 커스터마이징에 활용 가능.

**조선 일꾼** (`sound/ko/`)

| 파일        | 대사              |
| ----------- | ----------------- |
| `ko_s1.mp3` | 찾으셨나요        |
| `ko_s2.mp3` | 말씀하세요        |
| `ko_s3.mp3` | 예                |
| `ko_h1.mp3` | 일하러 갑니다요   |
| `ko_h2.mp3` | 그렇게 합죠       |
| `ko_h3.mp3` | 열심히 하겠습니다 |
| `ko_m1.mp3` | 갑니다요          |
| `ko_m2.mp3` | 예 갑니다         |

**명 일꾼** (`sound/ch/`)

| 파일        | 대사              |
| ----------- | ----------------- |
| `ch_s1.mp3` | 일해야죠          |
| `ch_s2.mp3` | 분부만 내리세요   |
| `ch_m1.mp3` | 네네 알겠습니다요 |
| `ch_h1.mp3` | 그렇게 합죠       |

**일본 일꾼** (`sound/jp/`)

| 파일        | 대사             |
| ----------- | ---------------- |
| `jp_s1.mp3` | 어떤 일을 할까요 |
| `jp_s2.mp3` | 녜녜녜녜         |
| `jp_h1.mp3` | 걱정마십쇼       |
| `jp_h2.mp3` | 녜녜 그렇게 합죠 |
| `jp_m1.mp3` | 갑니다요         |
| `jp_m2.mp3` | 아 녜녜          |

## 커스터마이징

이벤트별 재생 파일 변경 시 `.agents/sound_hook.sh` 수정.

## 출처

- 사운드 원본: 게임 **임진록 2+ 조선의 반격** 각 진영 일꾼 유닛 효과음.

- 유튜브 채널 [권율](https://www.youtube.com/@%EA%B6%8C%EC%9C%A8) 영상에서 발췌:
  - [조선 일꾼](https://www.youtube.com/watch?v=W9v_7TyGC3E)
  - [명 일꾼](https://www.youtube.com/watch?v=C-TCE3xOF0U)
  - [일본 일꾼](https://www.youtube.com/watch?v=j1hfb-0lzYM)

## 저작권 고지

- 임진록 2+ 조선의 반격은 현재 어밴던웨어(abandonware)로 분류됨
  - 현재 실질적인 저작권 행사 주체 없음 → 최종적으로 인천시청에 의해 몰수됨 ([근거](https://namu.wiki/w/%EC%9E%84%EC%A7%84%EB%A1%9D%202#s-8))

- 하지만 이것이 곧 저작권 소멸을 의미하는 것은 아님

- ⚠️ **상업적 활용 시 법적 위험 있음**

## 라이센스

MIT
