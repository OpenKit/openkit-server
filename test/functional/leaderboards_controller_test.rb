require 'test_helper'

class LeaderboardsControllerTest < ActionController::TestCase
  setup do
    @leaderboard = leaderboards(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:leaderboards)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create leaderboard" do
    assert_difference('Leaderboard.count') do
      post :create, leaderboard: { name: @leaderboard.name }
    end

    assert_redirected_to leaderboard_path(assigns(:leaderboard))
  end

  test "should show leaderboard" do
    get :show, id: @leaderboard
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @leaderboard
    assert_response :success
  end

  test "should update leaderboard" do
    put :update, id: @leaderboard, leaderboard: { name: @leaderboard.name }
    assert_redirected_to leaderboard_path(assigns(:leaderboard))
  end

  test "should destroy leaderboard" do
    assert_difference('Leaderboard.count', -1) do
      delete :destroy, id: @leaderboard
    end

    assert_redirected_to leaderboards_path
  end
end
