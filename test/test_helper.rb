ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

# Sign-in helpers for integration tests
module SignInHelper
  def sign_in_as(user, password: "password123")
    post user_session_path, params: {
      user: { email: user.email, password: password }
    }
    follow_redirect!
  end

  def sign_in_admin
    sign_in_as(users(:admin_user))
  end

  def sign_in_regular_user
    sign_in_as(users(:regular_user))
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
