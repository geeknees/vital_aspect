# OKR作成支援AI

## 概要
OpenAI API を利用して、Objective から Key Result を自動生成するサービス `OkrAiService` を追加しました。これにより、目標設定時にAIからのサジェスチョンを受け取れます。

## 使い方
```ruby
service = OkrAiService.new
krs = service.suggest_key_results("売上向上")
#=> ["売上を50%向上", "新規顧客を30社獲得"]
```
`OPENAI_API_KEY` 環境変数にAPIキーを設定してください。モデルは `OPENAI_MODEL` で変更できます(デフォルトは `gpt-4o`)。
