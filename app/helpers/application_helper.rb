module ApplicationHelper
  def status_badge_class(status)
    case status.to_s
    when "draft"
      "bg-gray-100 text-gray-800"
    when "active"
      "bg-green-100 text-green-800"
    when "completed"
      "bg-blue-100 text-blue-800"
    when "cancelled"
      "bg-red-100 text-red-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end

  def participant_status_badge_class(status)
    case status.to_s
    when "invited"
      "bg-yellow-100 text-yellow-800"
    when "in_progress"
      "bg-blue-100 text-blue-800"
    when "completed"
      "bg-green-100 text-green-800"
    when "declined"
      "bg-red-100 text-red-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end

  def can_manage_evaluation?(evaluation)
    Current.user == evaluation.created_by ||
    Current.user.can_create_evaluation?(evaluation.organization)
  end

  def get_rating_label(rating)
    case rating
    when 1
      t("questions.rating.very_poor")
    when 2
      t("questions.rating.poor")
    when 3
      t("questions.rating.average")
    when 4
      t("questions.rating.good")
    when 5
      t("questions.rating.excellent")
    else
      ""
    end
  end

  # OKR Helper Methods
  def can_edit_okr?(okr)
    return false unless Current.user

    # OKR owner can always edit
    return true if Current.user == okr.user

    # Organization admins can edit any OKR in their organization
    membership = Current.user.memberships.find_by(organization: okr.organization)
    membership&.role == "admin"
  end

  def can_view_okr?(okr)
    return false unless Current.user

    # Members of the organization can view OKRs
    Current.user.memberships.exists?(organization: okr.organization)
  end

  def okr_status_badge_class(status)
    case status.to_s
    when "draft"
      "bg-gray-100 text-gray-800"
    when "active"
      "bg-green-100 text-green-800"
    when "completed"
      "bg-blue-100 text-blue-800"
    when "cancelled"
      "bg-red-100 text-red-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end

  def key_result_status_badge_class(status)
    case status.to_s
    when "not_started"
      "bg-gray-100 text-gray-800"
    when "in_progress"
      "bg-yellow-100 text-yellow-800"
    when "completed"
      "bg-green-100 text-green-800"
    when "at_risk"
      "bg-red-100 text-red-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end

  def format_okr_progress(percentage)
    return "0%" if percentage.nil?
    "#{percentage.round(1)}%"
  end

  def okr_time_remaining(okr)
    return "No deadline" unless okr.end_date

    days_remaining = (okr.end_date - Date.current).to_i

    if days_remaining < 0
      "#{days_remaining.abs} days overdue"
    elsif days_remaining == 0
      "Due today"
    elsif days_remaining == 1
      "1 day remaining"
    else
      "#{days_remaining} days remaining"
    end
  end

  def okr_progress_color_class(percentage)
    case percentage
    when 0...25
      "bg-red-500"
    when 25...50
      "bg-yellow-500"
    when 50...75
      "bg-blue-500"
    when 75..100
      "bg-green-500"
    else
      "bg-gray-500"
    end
  end

  def okr_status_color(status)
    case status.to_s
    when "draft"
      "bg-gray-100 text-gray-800"
    when "active"
      "bg-green-100 text-green-800"
    when "completed"
      "bg-blue-100 text-blue-800"
    when "cancelled"
      "bg-red-100 text-red-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end
end
