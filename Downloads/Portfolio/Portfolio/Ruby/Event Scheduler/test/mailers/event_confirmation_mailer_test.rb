require 'test_helper'

class EventConfirmationMailerTest < ActionMailer::TestCase
  test "event_creation" do

    event = events(:one)
    user = users(:user1)

    # Set up an email using the order contents
    email = EventConfirmationMailer.with(event: event, user:user).event_creation

    # Check if the email is sent
    assert_emails 1 do
      email.deliver_now
    end

    # Check the contents are correct
    assert_equal email.to, [user.email]
    assert_equal email.from, ['ns01100@surrey.ac.uk']
    assert_equal email.subject, 'Event Scheduled'

  end

  test "event_updated" do

    event = events(:one)
    user = users(:user1)

    # Set up an email using the order contents
    email = EventConfirmationMailer.with(event: event, user:user).event_updated

    # Check if the email is sent
    assert_emails 1 do
      email.deliver_now
    end

    # Check the contents are correct
    assert_equal email.to, [user.email]
    assert_equal email.from, ['ns01100@surrey.ac.uk']
    assert_equal email.subject, 'Event Updated'

  end

  test "event_deleted" do

    event = events(:one)
    user = users(:user1)

    # Set up an email using the order contents
    email = EventConfirmationMailer.with(event: event, user:user).event_deleted

    # Check if the email is sent
    assert_emails 1 do
      email.deliver_now
    end

    # Check the contents are correct
    assert_equal email.to, [user.email]
    assert_equal email.from, ['ns01100@surrey.ac.uk']
    assert_equal email.subject, 'Event Deleted'

  end
end
