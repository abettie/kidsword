#!/usr/bin/env bash
# ask_slack.sh — Slackに質問を投稿し、返答をポーリングで待つ。
#
# 使い方:
#   echo "質問内容" | ./ask_slack.sh
#   ./ask_slack.sh "質問内容"
#
# .env の必須キー（カレントディレクトリの .env から読み込む）:
#   SLACK_BOT_TOKEN   — Bot User OAuth Token (xoxb-...)
#   SLACK_CHANNEL_ID  — 投稿先チャンネルID (例: C01234ABCDE)
#
# .env のオプションキー:
#   SLACK_MAX_WAIT          — 総タイムアウト秒数（デフォルト: 1800 = 30分）
#   SLACK_INITIAL_INTERVAL  — 初回ポーリング間隔秒数（デフォルト: 5）
#   SLACK_MAX_INTERVAL      — ポーリング間隔の最大秒数（デフォルト: 300 = 5分）
#
# 終了コード:
#   0  — 返答あり（返答テキストをstdoutに出力）
#   1  — 設定エラーまたはSlack APIエラー
#   2  — タイムアウト（SLACK_MAX_WAIT 秒以内に返答なし）

set -euo pipefail

# ---------------------------------------------------------------------------
# .env の読み込み
# ---------------------------------------------------------------------------
ENV_FILE="${ENV_FILE:-.env}"
if [[ -f "$ENV_FILE" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "$ENV_FILE"
    set +a
else
    echo "[ask_slack] WARNING: $ENV_FILE が見つかりません" >&2
fi

# ---------------------------------------------------------------------------
# 必須変数の検証
# ---------------------------------------------------------------------------
: "${SLACK_BOT_TOKEN:?'SLACK_BOT_TOKEN が .env に設定されていません'}"
: "${SLACK_CHANNEL_ID:?'SLACK_CHANNEL_ID が .env に設定されていません'}"

MAX_WAIT="${SLACK_MAX_WAIT:-1800}"
INITIAL_INTERVAL="${SLACK_INITIAL_INTERVAL:-5}"
MAX_INTERVAL="${SLACK_MAX_INTERVAL:-300}"

# ---------------------------------------------------------------------------
# メッセージを第1引数またはstdinから取得
# ---------------------------------------------------------------------------
if [[ $# -ge 1 ]]; then
    MESSAGE="$1"
else
    MESSAGE="$(cat)"
fi

if [[ -z "$MESSAGE" ]]; then
    echo "[ask_slack] ERROR: メッセージが指定されていません" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# ヘルパー: Slack API呼び出し
# ---------------------------------------------------------------------------
slack_api() {
    local endpoint="$1"
    shift
    curl --silent --fail \
        -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
        -H "Content-Type: application/json" \
        "$@" \
        "https://slack.com/api/${endpoint}"
}

# ---------------------------------------------------------------------------
# 質問を投稿
# ---------------------------------------------------------------------------
post_response=$(slack_api chat.postMessage \
    -d "{\"channel\": $(printf '%s' "$SLACK_CHANNEL_ID" | jq -Rs .), \"text\": $(printf '%s' "$MESSAGE" | jq -Rs .)}")

if [[ "$(echo "$post_response" | jq -r '.ok')" != "true" ]]; then
    echo "[ask_slack] ERROR: メッセージ投稿失敗: $(echo "$post_response" | jq -r '.error')" >&2
    exit 1
fi

THREAD_TS=$(echo "$post_response" | jq -r '.ts')
echo "[ask_slack] メッセージを投稿しました (ts=$THREAD_TS)。返答を待機中..." >&2

# ---------------------------------------------------------------------------
# 返答をポーリング
# ---------------------------------------------------------------------------
interval=$INITIAL_INTERVAL
elapsed=0

while (( elapsed < MAX_WAIT )); do
    sleep "$interval"
    elapsed=$(( elapsed + interval ))

    # 1) チャンネル直接投稿の返答を確認（oldest は exclusive なので元投稿は除外される）
    history_response=$(slack_api conversations.history \
        --get \
        --data-urlencode "channel=$SLACK_CHANNEL_ID" \
        --data-urlencode "oldest=$THREAD_TS" \
        --data-urlencode "limit=10" \
        -G)

    if [[ "$(echo "$history_response" | jq -r '.ok')" != "true" ]]; then
        echo "[ask_slack] WARNING: conversations.history エラー: $(echo "$history_response" | jq -r '.error')" >&2
    else
        reply=$(echo "$history_response" | jq -r '[.messages[] | select(.bot_id == null)] | last | .text // empty')
        if [[ -n "$reply" ]]; then
            echo "$reply"
            exit 0
        fi
    fi

    # 2) スレッド返信を確認（「スレッドで返信」した場合は history に載らないため別途確認）
    thread_response=$(slack_api conversations.replies \
        --get \
        --data-urlencode "channel=$SLACK_CHANNEL_ID" \
        --data-urlencode "ts=$THREAD_TS" \
        -G)

    if [[ "$(echo "$thread_response" | jq -r '.ok')" != "true" ]]; then
        echo "[ask_slack] WARNING: conversations.replies エラー: $(echo "$thread_response" | jq -r '.error')" >&2
    else
        # messages[0] は元の投稿なので index ≥ 1 が返答
        reply=$(echo "$thread_response" | jq -r '[.messages[1:] | .[] | select(.bot_id == null)] | last | .text // empty')
        if [[ -n "$reply" ]]; then
            echo "$reply"
            exit 0
        fi
    fi

    echo "[ask_slack] 返答なし (経過=${elapsed}s、次回チェックまで ${interval}s)..." >&2

    # 指数関数的バックオフ（MAX_INTERVAL でキャップ）
    interval=$(( interval * 2 ))
    (( interval > MAX_INTERVAL )) && interval=$MAX_INTERVAL
done

echo "[ask_slack] TIMEOUT: ${MAX_WAIT}s 以内に返答がありませんでした" >&2
exit 2
