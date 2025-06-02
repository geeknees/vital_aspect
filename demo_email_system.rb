#!/usr/bin/env ruby

# Demo script to test the email notification system
# Usage: rails runner demo_email_system.rb

puts "=== 360度評価 Email Notification System Demo ==="
puts

# Check if we have the necessary data
organizations = Organization.includes(:users, :evaluations).limit(3)

if organizations.empty?
  puts "No organizations found. Creating sample data..."

  # Create sample organization
  org = Organization.create!(
    name: "サンプル株式会社",
    description: "メール通知システムのデモ用組織"
  )

  # Create sample users
  user1 = User.create!(
    email: "taro@example.com",
    first_name: "太郎",
    last_name: "田中",
    password: "password123"
  )

  user2 = User.create!(
    email: "hanako@example.com",
    first_name: "花子",
    last_name: "佐藤",
    password: "password123"
  )

  # Create memberships
  org.memberships.create!(user: user1, role: 'owner')
  org.memberships.create!(user: user2, role: 'member')

  puts "✓ Sample organization and users created"
else
  org = organizations.first
  puts "Using existing organization: #{org.name}"
end

# Create a sample evaluation if none exists
evaluation = org.evaluations.active.first

if evaluation.nil?
  evaluation = org.evaluations.create!(
    name: "2024年Q2 360度評価",
    description: "第2四半期の包括的な360度フィードバック評価",
    start_date: 1.week.ago,
    due_date: 1.week.from_now,
    status: 'active'
  )

  # Add some questions
  evaluation.questions.create!([
    {
      text: "この人のリーダーシップ能力をどう評価しますか？",
      question_type: "scale",
      is_required: true
    },
    {
      text: "改善すべき点があれば教えてください。",
      question_type: "text",
      is_required: false
    }
  ])

  puts "✓ Sample evaluation created: #{evaluation.name}"
else
  puts "Using existing evaluation: #{evaluation.name}"
end

# Create sample participants if none exist
if evaluation.evaluation_participants.empty?
  users = org.users.limit(2)

  if users.count >= 2
    participant1 = evaluation.evaluation_participants.create!(
      user: users.first,
      role: 'self_evaluator',
      status: 'invited'
    )

    participant2 = evaluation.evaluation_participants.create!(
      user: users.second,
      role: 'peer',
      status: 'in_progress'
    )

    puts "✓ Sample participants created"
  end
end

puts "\n=== Testing Email Templates ==="

# Test invitation email
participant = evaluation.evaluation_participants.first
if participant
  puts "\n1. Testing Invitation Email..."
  puts "   Recipient: #{participant.user.full_name} (#{participant.user.email})"
  puts "   Role: #{participant.role}"
  puts "   Evaluation: #{evaluation.name}"

  begin
    mail = EvaluationMailer.invitation(participant)
    puts "   ✓ Invitation email generated successfully"
    puts "   Subject: #{mail.subject}"
  rescue => e
    puts "   ✗ Error generating invitation email: #{e.message}"
  end

  # Test reminder email
  puts "\n2. Testing Reminder Email..."
  begin
    mail = EvaluationMailer.reminder(participant)
    puts "   ✓ Reminder email generated successfully"
    puts "   Subject: #{mail.subject}"
  rescue => e
    puts "   ✗ Error generating reminder email: #{e.message}"
  end
end

# Test completion notification email
puts "\n3. Testing Completion Notification Email..."
begin
  mail = EvaluationMailer.completion_notification(evaluation)
  puts "   ✓ Completion notification generated successfully"
  puts "   Subject: #{mail.subject}"
rescue => e
  puts "   ✗ Error generating completion notification: #{e.message}"
end

puts "\n=== Email System Status ==="
puts "Delivery method: #{ActionMailer::Base.delivery_method}"
puts "SMTP settings: #{ActionMailer::Base.smtp_settings}" if ActionMailer::Base.delivery_method == :smtp

puts "\n=== Mailer Preview URLs ==="
puts "Visit these URLs in your browser to preview emails:"
puts "• Invitation: http://localhost:3000/rails/mailers/evaluation_mailer/invitation"
puts "• Reminder: http://localhost:3000/rails/mailers/evaluation_mailer/reminder"
puts "• Completion: http://localhost:3000/rails/mailers/evaluation_mailer/completion_notification"

puts "\n=== Available Rake Tasks ==="
puts "Run these commands to manage email notifications:"
puts "• rails evaluation:send_reminders - Send reminder emails"
puts "• rails evaluation:send_completion_notifications - Send completion notifications"
puts "• rails evaluation:stats - Show evaluation statistics"

puts "\n=== Next Steps ==="
puts "1. Start the Rails server: rails server"
puts "2. Visit the mailer preview URLs above to see email templates"
puts "3. Configure SMTP settings for production in config/environments/production.rb"
puts "4. Set up a cron job or scheduled task to run reminder emails automatically"

puts "\nEmail notification system is ready! 📧✨"
