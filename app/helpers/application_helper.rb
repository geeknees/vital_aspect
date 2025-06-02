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
end
