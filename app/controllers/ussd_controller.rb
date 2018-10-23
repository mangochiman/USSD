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

    menu = Menu.order("menu_number").map(&:name)

    if text.split("*").include?("#")
      if text.split("*").last == "#"
        text = ""
      end
      text = text.split("*").delete_if{|x|x== "#"}.join("*")
    end
    
    member = Member.find_by_phone_number(phone_number)
    latest_user_menu = UserMenu.where(["user_id =?", session_id]).last
    #menu_number = params["text"].split("*").last
    last_response = params["text"].split("*").last

    user_log = UserLog.where(["user_id =?", session_id]).last
    user_log = UserLog.new if user_log.blank?
    
    if member.blank?
      if latest_user_menu.blank?
        response  = "CON Welcome #{phone_number}. Your phone number is not registered to Wella Funeral Services. Select action \n";

        count = 1
        menu.each do |name|
          response += "#{count}. #{name} \n"
          count += 1
        end

        menu = Menu.where(["menu_number =?", last_response]).last

        unless menu.blank?
          um = UserMenu.new
          um.user_id = session_id
          um.menu_id = menu.menu_id
          um.save

          if (menu.name.match(/EXIT/i))
            response = "END Sesssion terminated"
          end
        end

        render :text => response and return
      end

      unless latest_user_menu.blank?
        menu = latest_user_menu.menu
        full_name_sub_menu = SubMenu.find_by_name("Full name")
        gender_sub_menu = SubMenu.find_by_name("gender")
        current_district_sub_menu = SubMenu.find_by_name("District")

        if menu.name.match(/EXIT/i)
          response = "END Sesssion terminated"
          latest_user_menu.delete
          render :text => response and return
        end

        if menu.name.match(/CHECK PREMIUMS/i)
          response  = "CON Premiums: \n Below are the premiums that you can pay. \n\n\n";
          response += "Press # to go to the main menu"
          latest_user_menu.delete
          render :text => response and return
        end

        if menu.name.match(/REGISTER/i)
          fullname_answer = SubMenu.where(["user_id =? AND sub_menu_id =?", session_id, full_name_sub_menu.id]).last
          gender_answer = SubMenu.where(["user_id =? AND sub_menu_id =?", session_id, gender_sub_menu.id]).last
          current_district_answer = SubMenu.where(["user_id =? AND sub_menu_id =?", session_id, current_district_sub_menu.id]).last

          if fullname_answer.blank?
            response  = "CON Registration: \n Please enter your full name\n"
            render :text => response and return
          else
            fullname_answer.sub_menu_id = full_name_sub_menu.id
            fullname_answer.save
          end

          if gender_answer.blank?
            user_log.name = last_response
            user_log.save
            
            response  = "CON Please select gender: \n"
            response += "1. Male \n"
            response += "2. Female \n"
            render :text => response and return
          else
            gender_answer.sub_menu_id = gender_sub_menu.id
            gender_answer.save
          end

          if current_district_answer.blank?
            gender = ""
            gender = "Male" if last_response.to_s == "1"
            gender = "Female" if last_response.to_s == "2"

            user_log.gender = gender
            user_log.save
            response  = "CON District you are currently staying: \n"
            render :text => response and return
          else
            current_district_answer.sub_menu_id = current_district_sub_menu.id
            current_district_answer.save
          end

          if user_log.district.blank?
            user_log.district = last_response
            user_log.save

            new_member = Member.new
            new_member.phone_number = phone_number
            new_member.name = user_log.name
            new_member.gender = user_log.gender
            new_member.district = user_log.district
            new_member.save

            response  = "CON We have successfully registered your phone number. Type # to go to main menu: \n";
          end

        end
 
      end
      
    end


    ############# Existing member #####
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
