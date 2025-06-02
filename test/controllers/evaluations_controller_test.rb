require "test_helper"

class EvaluationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get evaluations_index_url
    assert_response :success
  end

  test "should get show" do
    get evaluations_show_url
    assert_response :success
  end

  test "should get new" do
    get evaluations_new_url
    assert_response :success
  end

  test "should get create" do
    get evaluations_create_url
    assert_response :success
  end

  test "should get edit" do
    get evaluations_edit_url
    assert_response :success
  end

  test "should get update" do
    get evaluations_update_url
    assert_response :success
  end

  test "should get destroy" do
    get evaluations_destroy_url
    assert_response :success
  end

  test "should get start" do
    get evaluations_start_url
    assert_response :success
  end

  test "should get complete" do
    get evaluations_complete_url
    assert_response :success
  end
end
