require "test_helper"

class EvaluationResponsesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get evaluation_responses_index_url
    assert_response :success
  end

  test "should get show" do
    get evaluation_responses_show_url
    assert_response :success
  end

  test "should get edit" do
    get evaluation_responses_edit_url
    assert_response :success
  end

  test "should get update" do
    get evaluation_responses_update_url
    assert_response :success
  end
end
