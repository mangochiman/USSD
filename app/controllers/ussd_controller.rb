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

    if (text == "" )
      # This is the first request. Note how we start the response with CON
      response  = "CON What would you want to check \n";
      response += "1. My Account \n";
      response += "2. My phone number";
    elsif (text == "1" )
      #Business logic for first level response
      response = "CON Choose account information you want to view \n";
      response += "1. Account number \n";
      response += "2. Account balance";

    elsif (text == "2")

      #Business logic for first level response
      #This is a terminal request. Note how we start the response with END
      response = "END Your phone number is #{phone_number}";

    elsif (text == "1*1")

      #This is a second level response where the user selected 1 in the first instance
      account_number  = "ACC1001";
      #This is a terminal request. Note how we start the response with END
      response = "END Your account number is #{account_number}";

    elsif ( text == "1*2" )

      #This is a second level response where the user selected 1 in the first instance
      balance  = "NGN 10,000";
      #This is a terminal request. Note how we start the response with END
      response = "END Your balance is #{balance}";

      #Print the response onto the page so that our gateway can read it
      #header('Content-type: text/plain');
      puts response;

    end
  end

end