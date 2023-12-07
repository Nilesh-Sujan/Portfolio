class ContactMailer < ApplicationMailer

    #Email handler for cotnact form

    def contact_email(email, name, telephone, message)
        @email = email #Email param
        @name = name #Name param
        @telephone = telephone #Telephone param
        @message = message #Message param
        mail cc: @email #CC 
        mail to: 'ns01100@surrey.ac.uk' #Who to email to
        end
end
