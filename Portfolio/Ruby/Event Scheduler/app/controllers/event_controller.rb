#Main Event class that handles the events

class EventController < ApplicationController
  before_action :authenticate_user! #Make sure the user is logged in
  
  def index
  end

  def data
   events = Event.all
   render json: events.map {|event| {
            id: event.id,
            start_date: event.start_date.to_formatted_s(:db),
            end_date: event.end_date.to_formatted_s(:db),
            text: event.text
          }}
 end

 def db_action
   mode = params["!nativeeditor_status"]
   id = params["id"]
   start_date = params["start_date"]
   end_date = params["end_date"]
   text = params["text"]

   case mode
   when "inserted"
    event = Event.create :start_date => start_date, :end_date => end_date, :text => text #Create Event
    tid = event.id

    EventConfirmationMailer.with(event: event,user: current_user).event_creation.deliver_now #Email confirmation


     when "deleted"
      EventConfirmationMailer.with(event: event,user: current_user).event_deleted.deliver_now #Email confirmation
       Event.find(id).destroy #Delete event
       tid = id     

     when "updated"
       event = Event.find(id)
       event.start_date = start_date
       event.end_date = end_date
       event.text = text
       event.save
       tid = id #Update event

       EventConfirmationMailer.with(event: event,user: current_user).event_updated.deliver_now #Email confirmation

   end
   render :json => {
              :type => mode,
              :sid => id,
              :tid => tid,
          }
end
end