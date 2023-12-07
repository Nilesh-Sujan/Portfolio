#Contact class that handles the contact form

class ContactController < ApplicationController
    def request_contact
        name = params[:name]
        email = params[:email]
        telephone = params[:telephone]
        message = params[:message]
        if email.blank?
            flash[:alert] = I18n.t('contact.request_contact.no_email',default: 'contact.request_contact.no_email')
        else
            ContactMailer.contact_email(email, name, telephone, message).deliver_now
            flash[:notice] = I18n.t('contact.request_contact.email_sent',default: 'contact.request_contact.email_sent')
        end
        if current_user.present? 
            redirect_to root_path
        else
            redirect_to  new_user_session_path
        end
    end
end