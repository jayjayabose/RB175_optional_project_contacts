ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"
require_relative '../contacts'

require "minitest/reporters"
Minitest::Reporters.use!

class ContactsTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    @contacts_from_file = load_contacts_from_file
  end

  def session  
    last_request.env["rack.session"]
  end

  def test_display_contacts
    get "/"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "Create New Contact"
    assert_includes last_response.body, "Edit Contact"
    assert_includes last_response.body, "name1"
    assert_includes last_response.body, "name1@email.com"
    assert_includes last_response.body, "111 111 1111"
    assert_includes last_response.body, "name1 notes"
    assert_includes last_response.body, "<li>"
  end

  def test_flash_message
    get "/", {}, {"rack.session" => { message: "TEST FLASH MESSAGE"} }
    assert_equal 200, last_response.status
    assert_includes last_response.body, "TEST FLASH MESSAGE"

    get "/"
    assert_equal 200, last_response.status
    refute_includes last_response.body, "TEST FLASH MESSAGE"

  end

  def test_display_edit_contact_form
    get "/edit/name2@email.com", {}, {"rack.session" => { contacts: @contacts_from_file} }

    assert_equal 200, last_response.status
    assert_includes last_response.body, "name2"
    assert_includes last_response.body, "name2@email.com"
    assert_includes last_response.body, "222 222 2222"
    assert_includes last_response.body, "name2 notes"
    assert_includes last_response.body, %q(<button type="submit")
  end

  def test_handle_edit_contact
    params = {
      "name"=>"name2x", 
      "email"=>"name2x@email.com", 
      "phone"=>"222x 222x 2222x", 
      "notes"=>"name2x notes", 
      "id"=>"name2x@email.com"
    }

    post "/edit/name2@email.com", params, {"rack.session" => { contacts: @contacts_from_file} } do
      assert_equal 302, last_response.status
      assert_equal "Contact updated.", session[:message]

      get last_response["Location"]
      assert_equal 200, last_response.status

      assert_includes last_response.body, "name2x"
      assert_includes last_response.body, "name2x@email.com"
      assert_includes last_response.body, "222x 222x 2222x"
      assert_includes last_response.body, "name2x notes"
    end
  end
end