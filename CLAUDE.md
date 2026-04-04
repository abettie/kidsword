# プロジェクト概要

このプロジェクトは、インフラ、フロントエンド、バックエンドを含むモノレポ構成です。

## プロジェクト構成

```
/
├── infrastructure/    # インフラ
├── frontend/          # フロントエンド
└── backend/           # バックエンド
```

## 技術スタック

- **インフラ**: Terraform (AWS Lambda, DynamoDB, etc.)
- **フロントエンド**: Flutter
- **バックエンド**: TypeScript, AWS Lambda, DynamoDB

# ルール

## コミュニケーション

- チャットは日本語でやり取りする
- 技術用語は英語のまま使って構わない（例: `commit`, `branch`, `refactor`, `dependency` など）

## 人間への問い合わせ（ask_slack.sh）

作業中に人間の判断が必要になった場合、`scripts/ask_slack.sh` を使ってSlackと会話の両方で同時に待機する。

### 手順

1. `ask_slack.sh` をバックグラウンドで実行してSlackに質問を投稿する
2. 同じ質問をチャット上でもユーザーに提示して回答を待つ
3. **チャットで先に回答が得られた場合**
   - `ask_slack.sh` のプロセスをkillする
   - Slackに「チャットで回答を受け取りました: {回答内容}」と投稿して締める
4. **Slackで先に回答が得られた場合**
   - チャット上でユーザーにSlackの回答内容を提示して待機を解除する

### スクリプトの場所・設定

- スクリプト: `scripts/ask_slack.sh`
- 設定ファイル: `scripts/.env`（`scripts/.env_sample` を参照）
