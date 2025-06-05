# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Starting seed data creation..."

# Create users
users_data = [
  { email: "admin@example.com", password: "password" },
  { email: "ceo@example.com", password: "password" },
  { email: "cto@example.com", password: "password" },
  { email: "hr.manager@example.com", password: "password" },
  { email: "dev.lead@example.com", password: "password" },
  { email: "marketing.lead@example.com", password: "password" },
  { email: "sales.manager@example.com", password: "password" },
  { email: "product.manager@example.com", password: "password" },
  { email: "designer@example.com", password: "password" },
  { email: "engineer1@example.com", password: "password" },
  { email: "engineer2@example.com", password: "password" },
  { email: "marketer1@example.com", password: "password" },
  { email: "sales1@example.com", password: "password" },
  { email: "intern@example.com", password: "password" }
]

users = {}
users_data.each do |user_data|
  user = User.find_or_create_by!(email_address: user_data[:email]) do |u|
    u.password = user_data[:password]
  end
  users[user_data[:email]] = user
end

puts "✅ Created #{users.count} users"

# Create organizations
organizations_data = [
  {
    name: "VitalAspect株式会社",
    description: "OKR・360度評価システムを開発・提供する企業です。組織の透明性と成長を支援しています。",
    owner: users["admin@example.com"]
  },
  {
    name: "テクノロジー部門",
    description: "プロダクト開発・インフラ構築・技術戦略を担当する部門です。",
    owner: users["cto@example.com"]
  },
  {
    name: "マーケティング・セールス部門",
    description: "マーケティング戦略立案・営業活動・顧客関係管理を行う部門です。",
    owner: users["marketing.lead@example.com"]
  },
  {
    name: "人事・組織開発部門",
    description: "人材採用・組織文化構築・社員評価制度の運用を担当する部門です。",
    owner: users["hr.manager@example.com"]
  }
]

organizations = {}
organizations_data.each do |org_data|
  org = Organization.find_or_create_by!(name: org_data[:name]) do |o|
    o.description = org_data[:description]
    o.owner = org_data[:owner]
  end
  organizations[org_data[:name]] = org
end

puts "✅ Created #{organizations.count} organizations"

# Create memberships
memberships_data = [
  # VitalAspect株式会社のメンバーシップ
  { org: "VitalAspect株式会社", user: "admin@example.com", role: "owner", status: "active" },
  { org: "VitalAspect株式会社", user: "ceo@example.com", role: "admin", status: "active" },
  { org: "VitalAspect株式会社", user: "cto@example.com", role: "admin", status: "active" },
  { org: "VitalAspect株式会社", user: "hr.manager@example.com", role: "admin", status: "active" },
  { org: "VitalAspect株式会社", user: "marketing.lead@example.com", role: "admin", status: "active" },

  # テクノロジー部門のメンバーシップ
  { org: "テクノロジー部門", user: "cto@example.com", role: "owner", status: "active" },
  { org: "テクノロジー部門", user: "dev.lead@example.com", role: "admin", status: "active" },
  { org: "テクノロジー部門", user: "product.manager@example.com", role: "member", status: "active" },
  { org: "テクノロジー部門", user: "designer@example.com", role: "member", status: "active" },
  { org: "テクノロジー部門", user: "engineer1@example.com", role: "member", status: "active" },
  { org: "テクノロジー部門", user: "engineer2@example.com", role: "member", status: "active" },
  { org: "テクノロジー部門", user: "intern@example.com", role: "member", status: "active" },

  # マーケティング・セールス部門のメンバーシップ
  { org: "マーケティング・セールス部門", user: "marketing.lead@example.com", role: "owner", status: "active" },
  { org: "マーケティング・セールス部門", user: "sales.manager@example.com", role: "admin", status: "active" },
  { org: "マーケティング・セールス部門", user: "marketer1@example.com", role: "member", status: "active" },
  { org: "マーケティング・セールス部門", user: "sales1@example.com", role: "member", status: "active" },

  # 人事・組織開発部門のメンバーシップ
  { org: "人事・組織開発部門", user: "hr.manager@example.com", role: "owner", status: "active" },
  { org: "人事・組織開発部門", user: "ceo@example.com", role: "admin", status: "active" },
  { org: "人事・組織開発部門", user: "admin@example.com", role: "member", status: "active" }
]

memberships_data.each do |membership_data|
  org = organizations[membership_data[:org]]
  user = users[membership_data[:user]]

  # Skip if user is already the owner of the organization
  next if org.owner == user

  Membership.find_or_create_by!(
    organization: org,
    user: user
  ) do |m|
    m.role = membership_data[:role]
    m.status = membership_data[:status]
  end
end

puts "✅ Created memberships"

# Create OKRs for different quarters and different users
current_year = Date.current.year
last_quarter_start = Date.new(current_year, 4, 1)
last_quarter_end = Date.new(current_year, 6, 30)
current_quarter_start = Date.new(current_year, 7, 1)
current_quarter_end = Date.new(current_year, 9, 30)
next_quarter_start = Date.new(current_year, 10, 1)
next_quarter_end = Date.new(current_year, 12, 31)

okrs_data = [
  # CEO's OKRs
  {
    organization: organizations["VitalAspect株式会社"],
    user: users["ceo@example.com"],
    title: "Q3 2025 全社売上目標達成",
    description: "全社的な売上目標を達成し、持続可能な成長基盤を構築する",
    status: "active",
    start_date: current_quarter_start,
    end_date: current_quarter_end,
    key_results: [
      { title: "月次経常収益1000万円達成", description: "SaaS売上を中心とした安定収益の確保", target_value: 1000, current_value: 750, unit: "万円", status: "in_progress" },
      { title: "新規顧客獲得数50社", description: "エンタープライズ顧客を中心とした新規開拓", target_value: 50, current_value: 32, unit: "社", status: "in_progress" },
      { title: "顧客満足度スコア4.5以上", description: "NPS調査による顧客満足度向上", target_value: 4.5, current_value: 4.2, unit: "点", status: "in_progress" }
    ]
  },

  # CTO's OKRs
  {
    organization: organizations["テクノロジー部門"],
    user: users["cto@example.com"],
    title: "Q3 2025 プロダクト品質・パフォーマンス向上",
    description: "システムの安定性とユーザー体験を大幅に改善する",
    status: "active",
    start_date: current_quarter_start,
    end_date: current_quarter_end,
    key_results: [
      { title: "システム稼働率99.9%達成", description: "インフラ安定性とモニタリング強化", target_value: 99.9, current_value: 99.5, unit: "%", status: "in_progress" },
      { title: "ページ表示速度2秒以内", description: "フロントエンド・バックエンド最適化", target_value: 2.0, current_value: 3.2, unit: "秒", status: "at_risk" },
      { title: "バグ発生率30%削減", description: "自動テスト・コードレビュー強化", target_value: 70, current_value: 85, unit: "%", status: "in_progress" }
    ]
  },

  # Development Lead's OKRs
  {
    organization: organizations["テクノロジー部門"],
    user: users["dev.lead@example.com"],
    title: "Q3 2025 開発チーム生産性向上",
    description: "開発プロセスの効率化とチームのスキル向上を図る",
    status: "active",
    start_date: current_quarter_start,
    end_date: current_quarter_end,
    key_results: [
      { title: "スプリント完了率90%以上", description: "計画精度向上とタスク管理最適化", target_value: 90, current_value: 82, unit: "%", status: "in_progress" },
      { title: "コードレビュー時間24時間以内", description: "レビュープロセス効率化", target_value: 24, current_value: 36, unit: "時間", status: "in_progress" },
      { title: "技術勉強会月2回開催", description: "チーム全体のスキルアップ支援", target_value: 6, current_value: 4, unit: "回", status: "in_progress" }
    ]
  },

  # Marketing Lead's OKRs
  {
    organization: organizations["マーケティング・セールス部門"],
    user: users["marketing.lead@example.com"],
    title: "Q3 2025 マーケティング成果最大化",
    description: "リードジェネレーションとブランド認知度向上を実現する",
    status: "active",
    start_date: current_quarter_start,
    end_date: current_quarter_end,
    key_results: [
      { title: "月間リード獲得数200件", description: "コンテンツマーケティング・広告最適化", target_value: 600, current_value: 380, unit: "件", status: "in_progress" },
      { title: "ウェブサイト訪問者数50%増", description: "SEO・SEM戦略実行", target_value: 150, current_value: 125, unit: "%", status: "in_progress" },
      { title: "ソーシャルメディアフォロワー1万人", description: "SNS戦略強化とコミュニティ構築", target_value: 10000, current_value: 7500, unit: "人", status: "in_progress" }
    ]
  },

  # Product Manager's OKRs
  {
    organization: organizations["テクノロジー部門"],
    user: users["product.manager@example.com"],
    title: "Q3 2025 プロダクト機能拡充",
    description: "ユーザーニーズに基づく新機能開発とUX改善",
    status: "active",
    start_date: current_quarter_start,
    end_date: current_quarter_end,
    key_results: [
      { title: "新機能リリース5件", description: "ユーザーフィードバック基づく機能開発", target_value: 5, current_value: 3, unit: "件", status: "in_progress" },
      { title: "ユーザビリティテストスコア80点", description: "UI/UX改善とユーザー体験最適化", target_value: 80, current_value: 72, unit: "点", status: "in_progress" },
      { title: "機能利用率60%以上", description: "既存機能の活用促進", target_value: 60, current_value: 45, unit: "%", status: "at_risk" }
    ]
  },

  # Engineer's OKRs
  {
    organization: organizations["テクノロジー部門"],
    user: users["engineer1@example.com"],
    title: "Q3 2025 個人スキル向上とコード品質改善",
    description: "技術スキルの向上とより良いコードの実装",
    status: "active",
    start_date: current_quarter_start,
    end_date: current_quarter_end,
    key_results: [
      { title: "技術書読了3冊", description: "最新技術動向のキャッチアップ", target_value: 3, current_value: 2, unit: "冊", status: "in_progress" },
      { title: "OSS貢献10回", description: "オープンソースプロジェクトへの貢献", target_value: 10, current_value: 6, unit: "回", status: "in_progress" },
      { title: "コードカバレッジ80%達成", description: "担当モジュールのテストカバレッジ向上", target_value: 80, current_value: 65, unit: "%", status: "in_progress" }
    ]
  },

  # Previous Quarter (Completed)
  {
    organization: organizations["VitalAspect株式会社"],
    user: users["ceo@example.com"],
    title: "Q2 2025 組織基盤強化",
    description: "組織体制とプロセスの整備による成長基盤構築",
    status: "completed",
    start_date: last_quarter_start,
    end_date: last_quarter_end,
    key_results: [
      { title: "新規採用15名", description: "各部門での人材強化", target_value: 15, current_value: 18, unit: "名", status: "completed" },
      { title: "評価制度導入完了", description: "OKR・360度評価制度の全社展開", target_value: 100, current_value: 100, unit: "%", status: "completed" },
      { title: "社内研修プログラム構築", description: "継続的学習文化の醸成", target_value: 100, current_value: 95, unit: "%", status: "completed" }
    ]
  }
]

okrs_data.each do |okr_data|
  okr = Okr.find_or_create_by!(
    organization: okr_data[:organization],
    user: okr_data[:user],
    title: okr_data[:title]
  ) do |o|
    o.description = okr_data[:description]
    o.status = okr_data[:status]
    o.start_date = okr_data[:start_date]
    o.end_date = okr_data[:end_date]
  end

  okr_data[:key_results].each do |kr_data|
    KeyResult.find_or_create_by!(
      okr: okr,
      title: kr_data[:title]
    ) do |kr|
      kr.description = kr_data[:description]
      kr.target_value = kr_data[:target_value]
      kr.current_value = kr_data[:current_value]
      kr.unit = kr_data[:unit]
      kr.status = kr_data[:status]
    end
  end
end

puts "✅ Created #{okrs_data.count} OKRs with Key Results"

# Create OKR Progress entries
okrs_with_progress = Okr.where(status: [ "active", "completed" ]).includes(:user, :key_results)
okrs_with_progress.each do |okr|
  # Create 2-4 progress entries for each OKR
  progress_count = rand(2..4)
  progress_count.times do |i|
    days_ago = (progress_count - i) * 7 # Weekly progress updates
    reported_date = okr.start_date + days_ago.days

    next if reported_date > Date.current

    completion_percentage = case okr.status
    when "completed"
      [ 80 + i * 5, 100 ].min
    when "active"
      [ 20 + i * 15, 85 ].min
    end

    progress_notes = [
      "今週は#{okr.key_results.sample.title}について重点的に取り組みました。予定通り進捗しており、来週も継続して注力します。",
      "#{okr.key_results.sample.title}で一部想定より時間がかかっていますが、チームで対策を検討し改善策を実行中です。",
      "順調に進捗しています。特に#{okr.key_results.sample.title}で大きな成果が出ており、目標達成に向けて良いペースを保てています。",
      "#{okr.key_results.sample.title}について新しいアプローチを試行中です。来週にはより具体的な成果が見込めそうです。",
      "チーム全体での協力により、#{okr.key_results.sample.title}で想定以上の進捗を達成できました。"
    ]

    OkrProgress.find_or_create_by!(
      okr: okr,
      reported_at: reported_date
    ) do |progress|
      progress.progress_note = progress_notes.sample
      progress.completion_percentage = completion_percentage
    end
  end
end

puts "✅ Created OKR progress entries"

# Create 360-degree evaluations
evaluations_data = [
  {
    organization: organizations["テクノロジー部門"],
    evaluator: users["cto@example.com"],
    title: "エンジニア四半期評価 - 山田太郎",
    description: "Q2の成果と今後の成長に向けた360度評価を実施します",
    status: "completed",
    start_date: 1.month.ago,
    due_date: 2.weeks.ago,
    is_anonymous: false
  },
  {
    organization: organizations["テクノロジー部門"],
    evaluator: users["dev.lead@example.com"],
    title: "プロダクトマネージャー評価 - 佐藤花子",
    description: "プロダクト開発における成果と今後の課題について評価",
    status: "active",
    start_date: 1.week.ago,
    due_date: 1.week.from_now,
    is_anonymous: true
  },
  {
    organization: organizations["マーケティング・セールス部門"],
    evaluator: users["marketing.lead@example.com"],
    title: "営業チーム四半期評価",
    description: "Q3営業成果とチーム連携について包括的評価",
    status: "active",
    start_date: 3.days.ago,
    due_date: 10.days.from_now,
    is_anonymous: false
  },
  {
    organization: organizations["VitalAspect株式会社"],
    evaluator: users["hr.manager@example.com"],
    title: "新入社員半期評価",
    description: "入社半年での成長と今後の支援について評価",
    status: "draft",
    start_date: 1.week.from_now,
    due_date: 3.weeks.from_now,
    is_anonymous: false
  },
  {
    organization: organizations["テクノロジー部門"],
    evaluator: users["cto@example.com"],
    title: "リーダーシップ評価 - 開発チームリード",
    description: "チームリーダーとしての成果とマネジメント能力について",
    status: "completed",
    start_date: 6.weeks.ago,
    due_date: 4.weeks.ago,
    is_anonymous: true
  }
]

evaluations = []
evaluations_data.each do |eval_data|
  evaluation = Evaluation.find_or_create_by!(
    organization: eval_data[:organization],
    evaluator: eval_data[:evaluator],
    title: eval_data[:title]
  ) do |e|
    e.description = eval_data[:description]
    e.status = eval_data[:status]
    e.start_date = eval_data[:start_date]
    e.due_date = eval_data[:due_date]
    e.is_anonymous = eval_data[:is_anonymous]
  end
  evaluations << evaluation
end

puts "✅ Created #{evaluations.count} evaluations"

# Create questions for evaluations
questions_templates = [
  {
    content: "この四半期で最も優れていた成果や貢献について教えてください。",
    question_type: "text",
    is_required: true
  },
  {
    content: "今後さらに成長・改善できる領域はどこだと思いますか？",
    question_type: "text",
    is_required: true
  },
  {
    content: "チームワークや協調性について評価してください。",
    question_type: "rating",
    is_required: true
  },
  {
    content: "専門スキルや業務遂行能力について評価してください。",
    question_type: "rating",
    is_required: true
  },
  {
    content: "コミュニケーション能力について評価してください。",
    question_type: "rating",
    is_required: true
  },
  {
    content: "問題解決能力について評価してください。",
    question_type: "rating",
    is_required: true
  },
  {
    content: "この方と一緒に働くことについて",
    question_type: "multiple_choice",
    is_required: false,
    options: [ "とても満足", "満足", "普通", "やや不満", "不満" ]
  },
  {
    content: "今後期待する成長領域について教えてください。",
    question_type: "text",
    is_required: false
  }
]

evaluations.each do |evaluation|
  # Skip if evaluation already has questions
  next if evaluation.questions.any?

  # Each evaluation gets 4-6 questions
  selected_questions = questions_templates.sample(rand(4..6))
  selected_questions.each_with_index do |question_data, index|
    begin
      Question.find_or_create_by!(
        evaluation: evaluation,
        content: question_data[:content],
        order_index: index + 1
      ) do |q|
        q.question_type = question_data[:question_type]
        q.is_required = question_data[:is_required]
        q.options = question_data[:options] if question_data[:options]
      end
    rescue ActiveRecord::RecordInvalid => e
      puts "❌ Error creating question: #{e.record.errors.full_messages.join(', ')}"
      puts "Question data: #{question_data}"
      puts "Order index: #{index + 1}"
      puts "Evaluation: #{evaluation.title}"
      raise e
    end
  end
end

puts "✅ Created evaluation questions"

# Create evaluation participants
participant_roles = [ "peer", "supervisor", "subordinate" ]

evaluations.each do |evaluation|
  # Get organization members excluding the evaluator
  org_members = evaluation.organization.users.where.not(id: evaluation.evaluator.id)

  # Select 3-5 participants randomly
  participants = org_members.sample(rand(3..5))

  participants.each do |participant|
    role = participant_roles.sample
    status = case evaluation.status
    when "completed"
      "completed"
    when "active"
      [ "invited", "in_progress", "completed" ].sample
    else
      "invited"
    end

    EvaluationParticipant.find_or_create_by!(
      evaluation: evaluation,
      user: participant
    ) do |ep|
      ep.role = role
      ep.status = status
    end
  end
end

puts "✅ Created evaluation participants"

# Create responses for completed evaluations and participants
completed_evaluations = evaluations.select { |e| e.status == "completed" }
active_evaluations = evaluations.select { |e| e.status == "active" }

# Responses for completed evaluations
completed_evaluations.each do |evaluation|
  evaluation.evaluation_participants.each do |participant|
    evaluation.questions.each do |question|
      content = case question.question_type
      when "text"
        case question.content
        when /最も優れていた成果/
          [
            "プロジェクトマネジメント能力が向上し、チーム全体の生産性向上に大きく貢献されました。特に定期的な進捗共有と課題の早期発見により、スケジュール通りの完成を実現できました。",
            "技術的な課題解決において優れた能力を発揮され、他のメンバーへの技術指導も積極的に行っていただきました。",
            "新機能の企画から実装まで一貫して担当し、ユーザーから高い評価を得る成果を出されました。",
            "チーム内のコミュニケーション活性化に努めていただき、風通しの良い職場環境づくりに貢献されました。"
          ].sample
        when /成長・改善できる領域/
          [
            "より積極的な提案や新しいアイデアの発信を期待しています。現在の安定した業務遂行に加えて、イノベーションの創出にも挑戦していただきたいです。",
            "他部門との連携において、さらなる調整力の向上が期待されます。",
            "プレゼンテーション能力や外部への発信力をより強化していただければと思います。",
            "長期的な視点での戦略立案能力の向上に取り組んでいただきたいです。"
          ].sample
        when /今後期待する成長領域/
          [
            "リーダーシップスキルのさらなる向上を期待しています。",
            "新しい技術領域への挑戦を続けていただきたいです。",
            "メンタリング能力の強化により、チーム全体の底上げに貢献していただきたいです。"
          ].sample
        end
      when "rating"
        rand(3..5)
      when "multiple_choice"
        question.options.sample if question.options
      end

      Response.find_or_create_by!(
        question: question,
        participant_id: participant.id
      ) do |r|
        if question.question_type == "rating"
          r.score = content
        else
          r.content = content
        end
      end
    end
  end
end

# Some responses for active evaluations (partially completed)
active_evaluations.each do |evaluation|
  completed_participants = evaluation.evaluation_participants.where(status: "completed")
  in_progress_participants = evaluation.evaluation_participants.where(status: "in_progress")

  # Completed participants have all responses
  completed_participants.each do |participant|
    evaluation.questions.each do |question|
      content = case question.question_type
      when "text"
        "進行中の評価のため、詳細な回答を準備中です。"
      when "rating"
        rand(3..5)
      when "multiple_choice"
        question.options.sample if question.options
      end

      Response.find_or_create_by!(
        question: question,
        participant_id: participant.id
      ) do |r|
        if question.question_type == "rating"
          r.score = content
        else
          r.content = content
        end
      end
    end
  end

  # In-progress participants have partial responses
  in_progress_participants.each do |participant|
    answered_questions = evaluation.questions.sample(rand(1..evaluation.questions.count-1))
    answered_questions.each do |question|
      content = case question.question_type
      when "text"
        "部分的な回答として記載します。詳細は後日追記予定です。"
      when "rating"
        rand(3..5)
      when "multiple_choice"
        question.options.sample if question.options
      end

      Response.find_or_create_by!(
        question: question,
        participant_id: participant.id
      ) do |r|
        if question.question_type == "rating"
          r.score = content
        else
          r.content = content
        end
      end
    end
  end
end

puts "✅ Created evaluation responses"

puts ""
puts "🎉 Seed data creation completed!"
puts ""
puts "📊 Summary:"
puts "  👥 Users: #{User.count}"
puts "  🏢 Organizations: #{Organization.count}"
puts "  🎯 OKRs: #{Okr.count}"
puts "  📈 Key Results: #{KeyResult.count}"
puts "  📝 OKR Progress Entries: #{OkrProgress.count}"
puts "  📋 Evaluations: #{Evaluation.count}"
puts "  ❓ Questions: #{Question.count}"
puts "  👤 Evaluation Participants: #{EvaluationParticipant.count}"
puts "  💬 Responses: #{Response.count}"
puts ""
puts "🔑 Login credentials (all passwords are 'password'):"
puts "  CEO: ceo@example.com"
puts "  CTO: cto@example.com"
puts "  Admin: admin@example.com"
puts "  HR Manager: hr.manager@example.com"
puts "  Development Lead: dev.lead@example.com"
puts "  Marketing Lead: marketing.lead@example.com"
puts ""
puts "📝 Features available in the seed data:"
puts "  ✅ Multiple realistic organizations and departments"
puts "  ✅ Active and completed OKRs across different quarters"
puts "  ✅ Key Results with various progress levels"
puts "  ✅ Weekly progress reports for OKRs"
puts "  ✅ 360-degree evaluations in different statuses"
puts "  ✅ Comprehensive evaluation questions"
puts "  ✅ Realistic participant responses"
puts "  ✅ Multiple user roles and permissions"
puts ""
