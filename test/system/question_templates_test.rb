require "application_system_test_case"

class QuestionTemplatesTest < ApplicationSystemTestCase
  setup do
    @organization = organizations(:test_org)
    @user = users(:owner)
  end

  def sign_in(user)
    visit new_session_path(locale: "en")
    fill_in "email_address", with: user.email_address
    fill_in "password", with: "password"
    click_on "Sign in"
  end

  test "shows rating options when rating type selected" do
    sign_in(@user)
    visit new_organization_question_template_path(@organization, locale: "en")
    select I18n.t("questions.type.rating"), from: "question_template_question_type"

    assert_selector "#options-section", visible: true
    assert_selector "#options-container .option-row", count: 5
  end
end
