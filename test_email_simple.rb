puts 'Testing Email Notification System...'

# Check if mailer exists
puts "EvaluationMailer loaded: #{defined?(EvaluationMailer)}"

# Try to generate a simple test email
begin
  puts "Testing mailer methods..."
  puts "Available methods: #{EvaluationMailer.instance_methods(false)}"
rescue => e
  puts "Error: #{e.message}"
end

puts 'Email system test completed.'
