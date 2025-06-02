class DashboardController < ApplicationController
  before_action :authenticate_user!
  def index
    user = Current.user
    @organizations = user.organizations.includes(:evaluations)
    @pending_evaluations = user.pending_evaluations.includes(:evaluation, :user)
    @completed_evaluations = user.completed_evaluations.includes(:evaluation, :user).limit(5)
    @owned_organizations = user.owned_organizations
    
    # OKR Data
    @my_okrs = user.okrs.includes(:key_results, :organization).limit(5)
    @recent_okr_progresses = OkrProgress.joins(:okr)
                                       .where(okr: { user: user })
                                       .includes(:okr)
                                       .order(reported_at: :desc)
                                       .limit(3)
    @active_okrs_count = user.okrs.active.count
    @completed_okrs_count = user.okrs.completed.count
  end
end
