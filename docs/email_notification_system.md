# 360度評価システム - メール通知機能

## 概要

360度評価システムに統合されたメール通知機能により、評価プロセス全体を通じて参加者に自動的に通知を送信します。

## 実装されている機能

### 1. 招待メール (Invitation Email)
- **送信タイミング**: 評価参加者が追加されたとき
- **対象者**: 新しく評価に招待されたすべての参加者
- **内容**:
  - 評価の詳細情報
  - 参加者の役割
  - 回答期限
  - 評価参加用のリンク

### 2. リマインダーメール (Reminder Email)
- **送信タイミング**: 回答期限の3日前まで
- **対象者**: まだ回答を完了していない参加者
- **内容**:
  - 期限が近づいている旨の警告
  - 現在のステータス
  - 回答用のリンク

### 3. 完了通知メール (Completion Notification)
- **送信タイミング**: 評価が完了したとき
- **対象者**: 評価管理者
- **内容**:
  - 評価完了の通知
  - 参加統計（完了率、参加者数など）
  - 結果確認用のリンク

## ファイル構成

### メーラークラス
- `app/mailers/evaluation_mailer.rb` - メイン メーラークラス

### メールテンプレート
- `app/views/evaluation_mailer/invitation.html.erb` - 招待メール（HTML版）
- `app/views/evaluation_mailer/invitation.text.erb` - 招待メール（テキスト版）
- `app/views/evaluation_mailer/reminder.html.erb` - リマインダーメール（HTML版）
- `app/views/evaluation_mailer/reminder.text.erb` - リマインダーメール（テキスト版）
- `app/views/evaluation_mailer/completion_notification.html.erb` - 完了通知（HTML版）
- `app/views/evaluation_mailer/completion_notification.text.erb` - 完了通知（テキスト版）

### バックグラウンドジョブ
- `app/jobs/evaluation_reminder_job.rb` - リマインダーメール送信ジョブ

### Rakeタスク
- `lib/tasks/evaluation.rake` - メール送信とシステム管理用タスク

### プレビュー
- `test/mailers/previews/evaluation_mailer_preview.rb` - メール開発用プレビュー

## 設定

### 開発環境
開発環境では、ローカルのSMTPサーバー（ポート1025）を使用するように設定されています：

```ruby
# config/environments/development.rb
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: 'localhost',
  port: 1025,
  domain: 'localhost'
}
```

### 本番環境
本番環境用のSMTP設定は `config/environments/production.rb` で設定してください。

## 使用方法

### 1. 自動送信（推奨）
評価参加者の作成時に自動的に招待メールが送信されます：

```ruby
# app/controllers/evaluation_participants_controller.rb
EvaluationMailer.invitation(@evaluation_participant).deliver_later
```

### 2. 手動送信
Rakeタスクを使用して手動でメールを送信できます：

```bash
# リマインダーメールの送信
rails evaluation:send_reminders

# 完了通知の送信
rails evaluation:send_completion_notifications

# 統計情報の表示
rails evaluation:stats
```

### 3. メールプレビュー
開発中にメールテンプレートをプレビューできます：

- すべてのメーラー: http://localhost:3000/rails/mailers
- 招待メール: http://localhost:3000/rails/mailers/evaluation_mailer/invitation
- リマインダーメール: http://localhost:3000/rails/mailers/evaluation_mailer/reminder
- 完了通知: http://localhost:3000/rails/mailers/evaluation_mailer/completion_notification

## 国際化（i18n）

すべてのメールテンプレートは国際化に対応しており、日本語翻訳が `config/locales/ja.yml` に含まれています。

主な翻訳キー：
- `evaluation_mailer.invitation.*` - 招待メール関連
- `evaluation_mailer.reminder.*` - リマインダーメール関連
- `evaluation_mailer.completion_notification.*` - 完了通知関連

## カスタマイズ

### メールテンプレートのカスタマイズ
HTMLテンプレートはインラインCSSでスタイリングされており、以下の要素をカスタマイズできます：

- カラーテーマ（各メールタイプで異なる色）
- ロゴとブランディング
- レイアウトとデザイン
- コンテンツの構成

### 追加の通知タイプ
新しい通知タイプを追加する場合：

1. `EvaluationMailer` にメソッドを追加
2. HTMLとテキストテンプレートを作成
3. 翻訳を `config/locales/ja.yml` に追加
4. プレビューを `evaluation_mailer_preview.rb` に追加

## トラブルシューティング

### メール送信のテスト
開発環境でのメール送信をテストするには、MailCatcherなどのツールを使用してください：

```bash
gem install mailcatcher
mailcatcher
```

その後、http://localhost:1080 でメールの受信を確認できます。

### ログの確認
メール送信のログは Rails ログで確認できます：

```bash
tail -f log/development.log
```

### よくある問題
1. **メールが送信されない**: SMTP設定を確認してください
2. **テンプレートエラー**: プレビューURLで構文エラーをチェック
3. **翻訳の問題**: `config/locales/ja.yml` のキーが正しいか確認

## セキュリティ

- すべてのメールにはCSRF保護されたURLが含まれています
- 個人情報は適切にエスケープされています
- 配信停止機能の実装を推奨します（将来の拡張）

## パフォーマンス

- メール送信は `deliver_later` でバックグラウンド処理されます
- 大量の参加者に対する一括送信は `EvaluationReminderJob` で最適化されています
- メール送信の頻度制限を設けることを推奨します

## 今後の拡張予定

1. 配信停止機能
2. メール配信状況の追跡
3. 組織ごとのメールテンプレートカスタマイズ
4. 自動リマインダーのスケジューリング（cron設定）
5. メール配信統計とレポート機能
