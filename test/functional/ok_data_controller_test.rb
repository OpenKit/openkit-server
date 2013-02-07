require 'test_helper'

class OKDataControllerTest < ActionController::TestCase
  setup do
    @developer_data = developer_data(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:developer_data)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create developer_data" do
    assert_difference('OKData.count') do
      post :create, developer_data: {  }
    end

    assert_redirected_to developer_data_path(assigns(:developer_data))
  end

  test "should show developer_data" do
    get :show, id: @developer_data
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @developer_data
    assert_response :success
  end

  test "should update developer_data" do
    put :update, id: @developer_data, developer_data: {  }
    assert_redirected_to developer_data_path(assigns(:developer_data))
  end

  test "should destroy developer_data" do
    assert_difference('OKData.count', -1) do
      delete :destroy, id: @developer_data
    end

    assert_redirected_to developer_data_path
  end
end
