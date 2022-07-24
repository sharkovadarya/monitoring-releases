require "test_helper"

class RepositoriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get repositories_index_url
    assert_response :success
  end

  test "should get show" do
    get repositories_show_url
    assert_response :success
  end

  test "should get new" do
    get repositories_new_url
    assert_response :success
  end

  test "should get create" do
    get repositories_create_url
    assert_response :success
  end

  test "should get destroy" do
    get repositories_destroy_url
    assert_response :success
  end
end
