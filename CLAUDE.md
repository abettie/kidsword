# CLAUDE.md

## プロジェクト概要

子供の可愛い言い間違いを投稿・閲覧するAndroidアプリ「kidsword」。

## 技術スタック

| レイヤー | 技術 |
|----------|------|
| フロントエンド | Flutter（Androidのみ） |
| バックエンド | TypeScript + AWS Lambda |
| データベース | DynamoDB |
| 認証 | Firebase Auth（Googleログイン） |
| インフラ | Terraform |

## アーキテクチャ

```
/
├── frontend/      # Flutter（Android）アプリ
├── backend/       # TypeScript Lambda関数群
└── terraform/     # Terraform（AWS + Firebase設定）
```

### データフロー

Flutter（Android）→ Firebase Auth（認証）→ AWS Lambda（API）→ DynamoDB

- 認証はFirebase AuthのIDトークンをバックエンドで検証する方式
- バックエンドはLambda関数 + API Gateway（またはFunction URL）で構成

## 機能要件

- Googleログインによるユーザ管理
- ニックネーム設定（必須、初回ログイン時）
- 言い間違い投稿（「言い間違った言葉」「伝えたかった言葉」「説明」）
- 自分の過去投稿の閲覧
- 他ユーザの投稿を新着順で閲覧

**対象外**: ソート/絞り込み、いいね、ランキング、画像投稿

## 実装時の補足
- オーナーは PHP や JavaScript などのプログラミング経験は豊富だが、Flutter・TypeScript は初心者。コードを理解しやすくするため、実装した各ディレクトリに `code-reading.md` を作成すること。
