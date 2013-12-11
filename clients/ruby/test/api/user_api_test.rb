require 'test_helper.rb'

class UserApiTest < ApiTest
  def test_create
    custom_id = random_alphanumeric(7)
    nick = "guest-#{custom_id}"

    request = Post.new '/v1/users', {user: {custom_id: custom_id, nick: nick}}
    response = request.perform
    assert response.code =~ /^20\d/

    user = JSON.parse(response.body)
    assert user['id']
  end
end

