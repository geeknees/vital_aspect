# Preview all emails at http://localhost:3000/rails/mailers/evaluation_mailer
class EvaluationMailerPreview < ActionMailer::Preview
  # Preview invitation email
  # Visit http://localhost:3000/rails/mailers/evaluation_mailer/invitation
  def invitation
    evaluation_participant = EvaluationParticipant.joins(:evaluation, :user)
                                                 .includes(:evaluation, :user)
                                                 .first

    # Create a sample participant if none exists
    if evaluation_participant.nil?
      organization = Organization.first || Organization.create!(
        name: "Sample Organization",
        description: "A sample organization for email preview"
      )

      user = User.first || User.create!(
        email_address: "sample@example.com",
        password: "password123",
      )

      evaluation = organization.evaluations.first || organization.evaluations.create!(
        name: "Sample 360 Evaluation",
        description: "A sample evaluation for email preview",
        start_date: 1.week.ago,
        due_date: 1.week.from_now,
        status: "active"
      )

      evaluation_participant = evaluation.evaluation_participants.create!(
        user: user,
        role: "peer",
        status: "invited"
      )
    end

    EvaluationMailer.invitation(evaluation_participant)
  end

  # Preview reminder email
  # Visit http://localhost:3000/rails/mailers/evaluation_mailer/reminder
  def reminder
    evaluation_participant = EvaluationParticipant.joins(:evaluation, :user)
                                                 .includes(:evaluation, :user)
                                                 .where(status: [ "invited", "in_progress" ])
                                                 .first

    # Create a sample participant if none exists
    if evaluation_participant.nil?
      organization = Organization.first || Organization.create!(
        name: "Sample Organization",
        description: "A sample organization for email preview"
      )

      user = User.first || User.create!(
        email_address: "sample@example.com",
        password: "password123",
      )

      evaluation = organization.evaluations.first || organization.evaluations.create!(
        name: "Sample 360 Evaluation",
        description: "A sample evaluation for email preview",
        start_date: 2.weeks.ago,
        due_date: 2.days.from_now,
        status: "active"
      )

      evaluation_participant = evaluation.evaluation_participants.create!(
        user: user,
        role: "supervisor",
        status: "in_progress"
      )
    end

    EvaluationMailer.reminder(evaluation_participant)
  end

  # Preview completion notification email
  # Visit http://localhost:3000/rails/mailers/evaluation_mailer/completion_notification
  def completion_notification
    evaluation = Evaluation.joins(:organization)
                          .includes(:evaluation_participants, :organization)
                          .where(status: "completed")
                          .first

    # Create a sample evaluation if none exists
    if evaluation.nil?
      organization = Organization.first || Organization.create!(
        name: "Sample Organization",
        description: "A sample organization for email preview"
      )

      user1 = User.first || User.create!(
        email_address: "user1@example.com",
        password: "password123",
      )

      user2 = User.find_by(email_address: "user2@example.com") || User.create!(
        email_address: "user2@example.com",
        password: "password123",
      )

      evaluation = organization.evaluations.create!(
        name: "Q4 Performance Review",
        description: "Quarterly 360-degree performance evaluation",
        start_date: 1.month.ago,
        due_date: 1.day.ago,
        status: "completed"
      )

      # Create some participants with different statuses
      evaluation.evaluation_participants.create!([
        { user: user1, role: "self_evaluator", status: "completed" },
        { user: user2, role: "peer", status: "completed" }
      ])
    end

    EvaluationMailer.completion_notification(evaluation)
  end
end
