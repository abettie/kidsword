# プロジェクト概要

このプロジェクトは、AWSインフラ、フロントエンド、バックエンドを含むモノレポ構成です。

## プロジェクト構成

```
/
├── infrastructure/     # Terraform (AWS)
├── frontend/          # React アプリケーション
└── backend/           # TypeScript Lambda + DynamoDB
```

## 技術スタック

- **インフラ**: Terraform (AWS Lambda, DynamoDB, etc.)
- **フロントエンド**: React, TypeScript
- **バックエンド**: TypeScript, AWS Lambda, DynamoDB

## 重要な開発ルール

### 確認が必要な操作

以下の操作を行う前には、必ずユーザーに確認を求めること:

- 既存ファイルの書き換え・変更
- ファイルの削除
- Terraformの`apply`や`destroy`コマンド実行
- `git push`などのリモートへの変更
- `npm publish`などのパッケージ公開
- 本番環境に影響する可能性のある操作

### 確認不要な操作

以下の操作は確認なしで実行可能:

- 新規ファイルの作成
- ファイルの読み取り
- `terraform init`, `terraform plan`
- `npm install`, `npm run build`, `npm test`
- ローカルでの開発サーバー起動
- コードのフォーマット・リント

## よく使うコマンド

### Infrastructure (Terraform)

```bash
cd infrastructure
terraform init          # 初期化
terraform plan          # 実行計画の確認
terraform apply         # インフラの適用（要確認）
terraform destroy       # インフラの削除（要確認）
```

### Frontend

```bash
cd frontend
npm install            # 依存関係のインストール
npm run dev            # 開発サーバー起動
npm run build          # ビルド
npm run test           # テスト実行
npm run lint           # リント
```

### Backend

```bash
cd backend
npm install            # 依存関係のインストール
npm run build          # ビルド
npm run test           # テスト実行
npm run lint           # リント
```

## コーディング規約

- TypeScriptを使用
- ESLintとPrettierでコード品質を維持
- 関数とコンポーネントには適切な型定義を付ける
- テストコードも併せて作成する

## 注意事項

- `.env`ファイルや機密情報を含むファイルは変更しない
- `package-lock.json`や`yarn.lock`は直接編集しない
- 本番環境の設定ファイルには特に注意する
