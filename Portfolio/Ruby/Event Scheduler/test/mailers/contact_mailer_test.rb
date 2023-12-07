require 'test_helper'

class ContactMailerTest < ActionMailer::TestCase
  test "contact_email" do

    # Set up an email using the contact contents
    email = ContactMailer.contact_email("Tommy@gmail.com","Tom Hick", "1234567890", @message = "Hello")

    # Check if the email is sent
    assert_emails 1 do
      email.deliver_now
    end

    # Check the contents are correct
    assert_equal ['ns01100@surrey.ac.uk'], email.to
    assert_equal ['ns01100@surrey.ac.uk'], email.from

  end
end
