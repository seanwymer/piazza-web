require 'test_helper'

class AuthenticateTestsController < TestController
  include Authenticate

  skip_authentication only: [:new, :create]
  allow_unauthenticated only: :show

  def show
    render plain: "User: #{Current.user&.id&.to_s}"
  end
end

class AuthenticateTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:jerry)
    draw_test_routes do
      resource :authenticate_test,
        only: [:new, :create, :show, :edit]
    end
  end

  teardown do
    reload_routes!
  end

  test "request authenticated by cookie gets valid response" do
    @user.app_sessions.destroy_all
    log_in(@user)

    get edit_authenticate_test_path

    assert_response :ok
    assert_match(/authenticate_tests#edit/, response.body)
  end

  test "unauthenticated request renders login page" do
    get edit_authenticate_test_path

    assert_response :unauthorized
    assert_equal I18n.t("login_required"), flash[:notice]
    assert_select "form[action='#{login_path}']"
  end

  # Ensures you can access the 'new' and 'create' actions without needing to be logged in
  test "authentication is skipped for actions marked to do so" do
    get new_authenticate_test_path
    assert_response :ok
    assert_match(/authenticate_tests#new/, response.body)

    post authenticate_test_path
    assert_response :ok
    assert_match(/authenticate_tests#create/, response.body)
  end

  test "unauthenticated requests are allowed when marked" do
    get authenticate_test_path
    assert_response :ok
    assert_equal "User: ", response.body

    log_in(@user)
    get authenticate_test_path
    assert_response :ok
    assert_equal "User: #{@user.id}", response.body
  end

  private

    def log_in(user, password: "password")
      post login_path, params: {
        user: {
          email: user.email,
          password: password
        }
      }
    end
end
