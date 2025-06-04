# Kamalデプロイフローガイド

このドキュメントでは、Vital AspectアプリケーションのKamalを使用したデプロイフローについて説明します。

### 環境変数

#### シークレット環境変数
- `RAILS_MASTER_KEY`: Railsのマスターキー
- `KAMAL_REGISTRY_PASSWORD`: Dockerレジストリのパスワード

#### 一般環境変数
- `SOLID_QUEUE_IN_PUMA`: true（Pumaプロセス内でジョブ処理）

## デプロイコマンド

### 初回セットアップ

```bash
# サーバーの初期設定（初回のみ）
bin/kamal setup
```

### 通常のデプロイ

```bash
# アプリケーションのデプロイ
bin/kamal deploy
```

### その他の便利なコマンド

```bash
# アプリケーションのログを確認
bin/kamal logs

# Railsコンソールにアクセス
bin/kamal console

# シェルにアクセス
bin/kamal shell

# データベースコンソールにアクセス
bin/kamal dbc

# アプリケーションの再起動
bin/kamal app restart

# 前のバージョンにロールバック
bin/kamal rollback
```
## トラブルシューティング

### よくある問題と解決方法

1. **ビルドエラー**
   ```bash
   # ローカルでビルドテスト
   docker build -t vital_aspect .
   ```

2. **デプロイ失敗**
   ```bash
   # 現在の状態確認
   bin/kamal app details

   # ログ確認
   bin/kamal logs
   ```

3. **ロールバック**
   ```bash
   # 前のバージョンに戻す
   bin/kamal rollback
   ```

4. **コンテナの再起動**
   ```bash
   # アプリケーションの再起動
   bin/kamal app restart
   ```

### ログの確認方法

```bash
# リアルタイムログ
bin/kamal logs -f

# 特定の行数のログ
bin/kamal logs --lines 100

# エラーログのみ
bin/kamal logs | grep ERROR
```

## メンテナンス

### 定期的なメンテナンス作業

1. **古いDockerイメージの削除**
   ```bash
   bin/kamal prune all
   ```

2. **システムの健全性チェック**
   ```bash
   bin/kamal app details
   bin/kamal proxy details
   ```

3. **セキュリティアップデート**
   - 定期的なbase imageの更新
   - 依存関係の脆弱性チェック
