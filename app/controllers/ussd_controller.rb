require "AfricasTalking"
class UssdController < ApplicationController
  def ussd
    username = 'sandbox' # use 'sandbox' for development in the test environment
    api_key 	= '8a9199bf903a9cb57b3d9e39f9a937de683b531bcce1a346b332ee617e26002e' # use your sandbox app API key for development in the test environment
    at = AfricasTalking::Initialize.new(username, api_key)


    session_id   = params["sessionId"];
    service_code = params["serviceCode"];
    phone_number = params["phoneNumber"];
    text        = params["text"];

    member = Member.find_by_phone_number(phone_number)
    if member.blank? ############ New members
      if (text == "" )
        # This is the first request. Note how we start the response with CON
        response  = "CON Welcome #{phone_number}. Your phone number is not registered to Wella Funeral Services. Select action \n";
        response += "1. Register \n";
        response += "2. Check premiums \n";
        response += "3. Exit \n";
        
      elsif (text == "1" )
        #Regiter member
        response  = "CON Registration: \n Please enter your name\n";
      elsif (text == "2" )
        #Check premiums
      elsif (text == "3" )
        #Exit
        response = "END Sesssion terminated";
      end
      render :text => response
    end
    
    unless member.blank?
      if (text == "" )
        response  = "CON Welcome #{phone_number} to Wella Funeral Services. Select action \n";
        response += "1. My account \n";
        response += "2. Exit \n";
      elsif (text == "1" )
        response  = "CON My account \n";
        response += "1. Premiums \n";
        response += "2. Dependants \n";
        response += "3. Claims \n";
      elsif (text == "2" )
        response  = "END session terminated \n";
      elsif (text == "1*1" )
        response  = "CON Premiums \n";
        response += "1. Check balance \n";
        response += "2. Pay premiums \n";
      elsif (text == "1*2" )
        response  = "CON Dependants \n";
        response += "1. Add dependant \n";
        response += "2. Remove dependants \n";
        response += "3. View dependants \n";
      elsif (text == "1*3" )
        response  = "CON Claims \n";
        response += "1. Make claim \n";
        response += "2. My claims \n";
      end
      render :text => response
    end
    
    render :text => response
  end

end
