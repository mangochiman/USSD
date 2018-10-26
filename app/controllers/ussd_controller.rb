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
    main_menu = MainMenu.order("menu_number").map(&:name)

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

    if user_log.blank?
      user_log = UserLog.new
      user_log.user_id = session_id
      user_log.save
    end
    
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
        end

        latest_user_menu = UserMenu.where(["user_id =?", session_id]).last
        unless latest_user_menu.blank?
          response = ussd_logic(latest_user_menu, user_log, last_response, phone_number, session_id)
          render :text => response and return if response
        end
      else
        response = ussd_logic(latest_user_menu, user_log, last_response, phone_number, session_id)
        render :text => response and return if response
      end
  
    end


    ############# Existing member #####
    unless member.blank?
      main_latest_user_menu = MainUserMenu.where(["user_id =?", session_id]).last
      user_parent_menu = UserParentMenu.where(["user_id =?", session_id]).last

      if user_parent_menu.blank?
        user_parent_menu = UserParentMenu.new
        user_parent_menu.user_id = session_id
        user_parent_menu.save
        response  = "CON Welcome #{member.name} to Wella Insurance Services. Select action \n";

        response += "0. My Account\n"
        response += "1. Exit\n"
        render :text => response and return
      end

      unless user_parent_menu.blank?
        if main_latest_user_menu.blank?

          response  = "CON My account. Select action \n";

          count = 1
          main_menu.each do |name|
            response += "#{count}. #{name} \n"
            count += 1
          end

          if last_response.to_s != "0"
            menu = MainMenu.where(["menu_number =?", last_response]).last
            unless menu.blank?
              main_user_menu = MainUserMenu.new
              main_user_menu.user_id = session_id
              main_user_menu.main_menu_id = menu.main_menu_id
              main_user_menu.save
            end
          end

          if last_response.to_s == 1
            response  = "END Session terminated";
          end
          
          render :text => response and return if response
        end
      end
      
      unless user_parent_menu.blank?
        if main_latest_user_menu.blank?

          response  = "My account. Select action \n";

          count = 1
          main_menu.each do |name|
            response += "#{count}. #{name} \n"
            count += 1
          end

          menu = MainMenu.where(["menu_number =?", last_response]).last

          unless menu.blank?
            main_user_menu = MainUserMenu.new
            main_user_menu.user_id = session_id
            main_user_menu.main_menu_id = menu.main_menu_id
            main_user_menu.save if last_response.to_s != "0"
          end

          main_latest_user_menu = MainUserMenu.where(["user_id =?", session_id]).last
          unless main_latest_user_menu.blank?
            response = existing_client_workflow(latest_user_menu, user_log, last_response, phone_number, session_id)
            render :text => response and return if response
          end
        else
          response = existing_client_workflow(latest_user_menu, user_log, last_response, phone_number, session_id)
          render :text => response and return if response
        end
      end
      render :text => response and return if response
      
    end

    render :text => response and return
  end

  def first_level_ussd_menu_hash
    data = {
      "1" => "My account",
      "2" => "Exit"
    }
    return data
  end


  def clean_db(session_id)

  end

  def ussd_logic(latest_user_menu, user_log, last_response, phone_number, session_id)
    unless latest_user_menu.blank?
      menu = latest_user_menu.menu
      full_name_sub_menu = SubMenu.find_by_name("Full name")
      gender_sub_menu = SubMenu.find_by_name("gender")
      current_district_sub_menu = SubMenu.find_by_name("District")
      seen_status = SeenStatus.where(["user_id =?", session_id]).last
      

      if seen_status.blank?
        seen_status = SeenStatus.new
        seen_status.user_id = session_id
        seen_status.save
      end

      if menu.name.match(/EXIT/i)
        response = "END Sesssion terminated"
        latest_user_menu.delete
        return response
      end

      if menu.name.match(/CHECK PREMIUMS/i)
        response  = "CON Premiums: \n Below are the premiums that you can pay. \n\n\n";
        response += "Press # to go to the main menu"
        latest_user_menu.delete
        return response
      end

      if menu.name.match(/REGISTER/i)
        fullname_answer = UserMenu.where(["user_id =? AND sub_menu_id =?", session_id, full_name_sub_menu.id]).last
        gender_answer = UserMenu.where(["user_id =? AND sub_menu_id =?", session_id, gender_sub_menu.id]).last
        current_district_answer = UserMenu.where(["user_id =? AND sub_menu_id =?", session_id, current_district_sub_menu.id]).last

        seen_status = SeenStatus.where(["user_id =?", session_id]).last
        fullname_asked = (seen_status.name == true)
        gender_asked = (seen_status.gender == true)
        district_asked = (seen_status.district == true)

        if user_log.name.blank?
          if fullname_answer.blank? && !fullname_asked
            response  = "CON Registration: \n Please enter your full name\n"
            seen_status.name = true
            seen_status.save
          
            fullname_answer = UserMenu.new
            fullname_answer.user_id = session_id
            fullname_answer.menu_id = menu.menu_id
            fullname_answer.sub_menu_id = full_name_sub_menu.id
            fullname_answer.save
          
            return response
          else
            if (params[:text].last == "*")
              seen_status.name = false
              seen_status.save
              fullname_answer.delete

              response  = "CON Name can not be blank: \n\n"
              response += "Press any key to go to name input"
              return response
            end
            if user_log.name.blank?
              user_log.name = params[:text].split("*").last
              user_log.save
            end
          end
        end

        if user_log.gender.blank?
          if gender_answer.blank? && !gender_asked
            response  = "CON Please select gender: \n"
            response += "1. Male \n"
            response += "2. Female \n"
          
            seen_status.gender = true
            seen_status.save

            gender_answer = UserMenu.new
            gender_answer.user_id = session_id
            gender_answer.menu_id = menu.menu_id
            gender_answer.sub_menu_id = gender_sub_menu.id
            gender_answer.save
          
            return response
          else
            gender = ""
            gender = "Male" if params[:text].split("*").last.to_s == "1"
            gender = "Female" if params[:text].split("*").last.to_s == "2"
            
            if (params[:text].last == "*")
              seen_status.gender = false
              seen_status.save
              gender_answer.delete

              response  = "CON Gender can not be blank: \n\n"
              response += "Press any key to go to gender menu"
              return response
            end

            if (gender.blank?)
              seen_status.gender = false
              seen_status.save
              gender_answer.delete

              response  = "CON Invalid gender selected: \n\n"
              response += "Press any key to go to gender menu"
              return response
            end

            if user_log.gender.blank?
              user_log.gender = gender
              user_log.save
            end
          end
        end

        if user_log.district.blank?
          if current_district_answer.blank? && !district_asked
            response  = "CON District you are currently staying: \n"
          
            seen_status.district = true
            seen_status.save

            current_district_answer = UserMenu.new
            current_district_answer.user_id = session_id
            current_district_answer.menu_id = menu.menu_id
            current_district_answer.sub_menu_id = current_district_sub_menu.id
            current_district_answer.save
          
            return response
          else
            if (params[:text].last == "*")
              seen_status.district = false
              seen_status.save
              current_district_answer.delete

              response  = "CON District can not be blank: \n\n"
              response += "Press any key to go to district input"
              return response
            end
            if user_log.district.blank?
              user_log.district = params[:text].split("*").last
              user_log.save
            end
          end
        end

        user_log = UserLog.where(["user_id =?", session_id]).last
        
        new_member = Member.new
        new_member.phone_number = phone_number
        new_member.name = user_log.name
        new_member.gender = user_log.gender
        new_member.district = user_log.district
        new_member.save

        response  = "CON We have successfully registered your phone number with the following details.\n";
        response += "Name: #{user_log.name}\n"
        response += "Gender: #{user_log.gender}\n"
        response += "Current district: #{user_log.district}\n\n"

        response += "Type # to go to main menu: \n"
        clean_db(session_id)
        
        return response
      end

    end
  end

  def existing_client_workflow(latest_user_menu, user_log, last_response, phone_number, session_id)

    unless latest_user_menu.blank?
      menu = latest_user_menu.menu

      if menu.name.match(/EXIT/i)
        response = "END Sesssion terminated"
        latest_user_menu.delete
        return response
      end

      if menu.name.match(/CLAIMS/i)
        response  = "CON Welcome to Claims Menu. \n\n\n";
        return response
      end

      if menu.name.match(/DEPENDANTS/i)
        response  = "CON Welcome to Dependants Menu. \n\n\n";
        return response
      end

      if menu.name.match(/PAYMENTS/i)
        response  = "CON Welcome to Payments Menu. \n\n\n";
        return response
      end
      
    end

  end

end
