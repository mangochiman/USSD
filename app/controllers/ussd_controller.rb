require "AfricasTalking"
class UssdController < ApplicationController
  def ussd
    username = 'sandbox' # use 'sandbox' for development in the test environment
    api_key 	= '8a9199bf903a9cb57b3d9e39f9a937de683b531bcce1a346b332ee617e26002e' # use your sandbox app API key for development in the test environment
    at = AfricasTalking::Initialize.new(username, api_key)


    session_id   = params["sessionId"]
    service_code = params["serviceCode"]
    phone_number = params["phoneNumber"]
    text        = params["text"]

    if text.split("*").include?("#")
      if text.split("*").last == "#"
        text = ""
      end
      text = text.split("*").delete_if{|x|x== "#"}.join("*")
    end
    
    member = Member.find_by_phone_number(phone_number)

    if member.blank? ############ New members
      if (text == "" )
        response  = "CON Welcome #{phone_number}. Your phone number is not registered to Wella Funeral Services. Select action \n";
        response += "1. Register \n"
        response += "2. Check premiums \n"
        response += "3. Exit \n"
        
      elsif (text == "1" )
        response  = "CON Registration: \n Please enter your full name\n";
      elsif (text.match(/1*/i)) && (text.split("*").length == 2)
        response  = "CON Please select gender: \n"
        response += "1. Male \n"
        response += "2. Female \n"
      elsif (text.match(/1*/i)) && (text.split("*").length == 3) && [1,2].exclude?(text.split("*").last.to_i)
        response  = "END Uknown option selected: Available options are \n"
        response += "1. Male \n"
        response += "2. Female \n"
      elsif (text.match(/1*/i)) && (text.split("*").length == 3)
        response  = "CON District you are currently staying: \n"
      elsif (text.match(/1*/i)) && (text.split("*").length == 4)
        Member.enroll_in_program(params)
        response  = "CON We have successfully registered your phone number. Type # to go to main menu: \n";
      elsif (text == "2" )
        #Check premiums
        response  = "CON Premiums: \n Below are the premiums that you can pay. ****************************\n";
        response += "Choose the one you are comfortable with\n"
        response += "Press # to go to the main menu"
      elsif (text == "3" )
        #Exit
        response = "END Sesssion terminated"
      else
        response  = "END Uknown option selected: Available options are \n"
        response += "1. Register \n"
        response += "2. Check premiums \n"
        response += "3. Exit \n"
      end
    end
    
    unless member.blank?
      if (text == "" )
        response  = "CON Welcome #{phone_number} to Wella Funeral Services. Select action \n"
        response += "1. My account \n"
        response += "2. Exit \n"
      elsif (text == "1" )
        response  = "CON My account \n"
        response += "1. Premiums \n"
        response += "2. Dependants \n"
        response += "3. Claims \n"
      elsif (text == "2" )
        response  = "END session terminated \n"
      elsif (text == "1*1" )
        response  = "CON Premiums \n"
        response += "1. Check balance \n"
        response += "2. Pay premiums \n"
      elsif (text == "1*2" )
        response  = "CON Dependants \n"
        response += "1. Add dependant \n"
        response += "2. Remove dependants \n"
        response += "3. View dependants \n"
      elsif (text == "1*3" )
        response  = "CON Claims \n"
        response += "1. Make claim \n"
        response += "2. My claims \n"
      end
    end
    
    render :text => response
  end

end
