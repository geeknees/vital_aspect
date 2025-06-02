class DashboardController < ApplicationController
  before_action :authenticate_user!
  def index
    user = Current.user
    @organizations = user.organizations.includes(:evaluations)
    @pending_evaluations = user.pending_evaluations.includes(:evaluation, :user)
    @completed_evaluations = user.completed_evaluations.includes(:evaluation, :user).limit(5)
    @owned_organizations = user.owned_organizations
  end
end
