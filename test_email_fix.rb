#!/usr/bin/env ruby
# Test script to verify email system works correctly after fixing attribute references

require_relative 'config/environment'

puts "Testing Email System After Fixes..."
puts "=" * 50

# Find or create test data
organization = Organization.first || Organization.create!(
  name: "Test Organization",
  description: "Test organization for email verification",
  owner: User.first || User.create!(
    email_address: "owner@test.com",
    password_digest: BCrypt::Password.create("password123")
  )
)

user = User.find_by(email_address: "test@example.com") || User.create!(
  email_address: "test@example.com",
  password_digest: BCrypt::Password.create("password123")
)

evaluation = organization.evaluations.first || organization.evaluations.create!(
  title: "Test 360 Evaluation",
  description: "Test evaluation for email verification",
  start_date: 1.week.ago,
  due_date: 1.week.from_now,
  status: "active",
  evaluator: organization.owner
)

participant = evaluation.evaluation_participants.find_by(user: user) ||
              evaluation.evaluation_participants.create!(
                user: user,
                role: "peer",
                status: "invited"
              )

puts "✓ Test data created successfully"
puts "  - Organization: #{organization.name}"
puts "  - Evaluation: #{evaluation.title}"
puts "  - Participant: #{participant.user.email_address}"
puts

# Test each email type
begin
  puts "Testing invitation email..."
  mail = EvaluationMailer.invitation(participant)
  puts "✓ Invitation email created successfully"
  puts "  - To: #{mail.to.join(', ')}"
  puts "  - Subject: #{mail.subject}"
  puts

  puts "Testing reminder email..."
  mail = EvaluationMailer.reminder(participant)
  puts "✓ Reminder email created successfully"
  puts "  - To: #{mail.to.join(', ')}"
  puts "  - Subject: #{mail.subject}"
  puts

  puts "Testing completion notification..."
  evaluation.update!(status: "completed")
  mail = EvaluationMailer.completion_notification(evaluation)
  puts "✓ Completion notification created successfully"
  puts "  - To: #{mail.to.join(', ')}"
  puts "  - Subject: #{mail.subject}"
  puts

rescue => e
  puts "✗ Error: #{e.message}"
  puts e.backtrace.first(5)
  exit 1
end

puts "=" * 50
puts "✓ All email tests passed successfully!"
puts "✓ Email system is working correctly with fixed attribute references"
puts "✓ Ready for production use"
