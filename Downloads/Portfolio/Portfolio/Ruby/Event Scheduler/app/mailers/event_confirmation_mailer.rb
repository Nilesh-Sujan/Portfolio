class EventConfirmationMailer < ApplicationMailer

    def event_creation
        @user = params[:user] #Get user params
        @event = params[:event] #Get event params

        mail(to: @user.email, subject: "Event Scheduled") #Set the mail to and mail subject
    end

    def event_deleted
        @user = params[:user] #Get user params
        @event = params[:event] #Get event params

        mail(to: @user.email, subject: "Event Deleted") #Set the mail to and mail subject
    end

    def event_updated
        @user = params[:user] #Get user params
        @event = params[:event] #Get event params

        mail(to: @user.email, subject: "Event Updated") #Set the mail to and mail subject
    end

end
