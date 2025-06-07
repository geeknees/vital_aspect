require "test_helper"

class OkrsAiAssistTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:test_org)
    @user = users(:owner)
    post session_path(locale: I18n.default_locale), params: { email_address: @user.email_address, password: "password" }
  end

  teardown do
    delete session_path(locale: I18n.default_locale)
    Current.reset_all
  end

  test "suggest_key_results returns suggestions" do
    fake_service = Class.new do
      def suggest_key_results(_)
        [ "KR1", "KR2" ]
      end
    end.new

    OkrAiService.stub :new, fake_service do
      post suggest_key_results_organization_okrs_path(@organization, locale: I18n.default_locale),
           params: { objective: "test" }, as: :json
    end

    assert_response :success
    assert_equal [ "KR1", "KR2" ], response.parsed_body
  end
end
