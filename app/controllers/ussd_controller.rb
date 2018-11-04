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
    main_latest_user_menu = MainUserMenu.where(["user_id =?", session_id]).last
    last_response = params["text"].split("*").last

    user_log = UserLog.where(["user_id =?", session_id]).last
    main_user_log = MainUserLog.where(["user_id =?", session_id]).last

    if user_log.blank?
      user_log = UserLog.new
      user_log.user_id = session_id
      user_log.save
    end

    if main_user_log.blank?
      main_user_log = MainUserLog.new
      main_user_log.user_id = session_id
      main_user_log.save
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

      if main_latest_user_menu.blank?
        response  = "CON Welcome #{member.name} to Wella Funeral Services. Select action \n";

        count = 1
        main_menu.each do |name|
          response += "#{count}. #{name} \n"
          count += 1
        end

        main_menu_response = MainMenu.where(["menu_number =?", last_response]).last

        unless main_menu_response.blank?
          main_user_menu = MainUserMenu.new
          main_user_menu.user_id = session_id
          main_user_menu.main_menu_id = main_menu_response.main_menu_id
          main_user_menu.save
        end

        main_latest_user_menu = MainUserMenu.where(["user_id =?", session_id]).last
        unless main_latest_user_menu.blank?
          response = existing_client_workflow(main_latest_user_menu, main_user_log, last_response, phone_number, session_id)
          render :text => response and return if response
        end
      else
        response = existing_client_workflow(main_latest_user_menu, main_user_log, last_response, phone_number, session_id)
        render :text => response and return if response
      end
      
    end

    render :text => response and return
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

  def existing_client_workflow(latest_user_menu, main_user_log, last_response, phone_number, session_id)

    unless latest_user_menu.blank?
      menu = latest_user_menu.main_menu
      full_name_sub_menu = SubMenu.find_by_name("Full name")
      gender_sub_menu = SubMenu.find_by_name("gender")
      current_district_sub_menu = SubMenu.find_by_name("District")
      
      main_seen_status = MainSeenStatus.where(["user_id =?", session_id]).last
      
      if main_seen_status.blank?
        main_seen_status = MainSeenStatus.new
        main_seen_status.user_id = session_id
        main_seen_status.save
      end

      fullname_asked = (main_seen_status.name == true)
      gender_asked = (main_seen_status.gender == true)
      district_asked = (main_seen_status.district == true)
      dependant_menu_asked = (main_seen_status.dependant == true)
      new_dependant_menu_asked = (main_seen_status.new_dependant == true)
      
      if menu.name.match(/EXIT/i)
        response = "END Sesssion terminated"
        latest_user_menu.delete
        return response
      end

      if menu.name.match(/DEPENDANT/i)
        fullname_answer = MainUserMenu.where(["user_id =? AND main_sub_menu_id =?", session_id, full_name_sub_menu.id]).last
        gender_answer = MainUserMenu.where(["user_id =? AND main_sub_menu_id =?", session_id, gender_sub_menu.id]).last
        current_district_answer = MainUserMenu.where(["user_id =? AND main_sub_menu_id =?", session_id, current_district_sub_menu.id]).last


        if !dependant_menu_asked
          response  = "CON Dependant Menu. Select action \n"
          count = 1
          main_sub_menus = menu.main_sub_menus.collect{|msm|msm.name}
          main_sub_menus.each do |name|
            response += "#{count}. #{name} \n"
            count += 1
          end

          dependant_menu = DependantMenu.where(["menu_number =?", last_response]).last
          user_dependant_menu = UserDependantMenu.where(["user_id =?", session_id]).last

          unless dependant_menu.blank?
            main_seen_status.dependant = true
            main_seen_status.save
          
            user_dependant_menu = UserDependantMenu.new
            user_dependant_menu.user_id = session_id
            user_dependant_menu.dependant_menu_id = dependant_menu.dependant_menu_id
            user_dependant_menu.save
          end

          return response
        end

        dependent_menu = MainMenu.find_by_name("Dependants")
        new_dependant_sub_menu_id = MainSubMenu.find_by_name("New dependant").main_sub_menu_id
        remove_dependant_sub_menu_id = MainSubMenu.find_by_name("Remove dependants").main_sub_menu_id
        view_dependant_sub_menu_id = MainSubMenu.find_by_name("View dependants").main_sub_menu_id

        user_dependant_sub_menu = UserDependantSubMenu.where(["user_id =?", session_id])
        
        new_dependent_sub_menu = UserDependantSubMenu.where(["user_id =? AND dependant_menu_id =? AND
          dependant_menu_sub_id =?", session_id, dependent_menu.main_menu_id, new_dependant_sub_menu_id])

        remove_dependent_sub_menu = UserDependantSubMenu.where(["user_id =? AND dependant_menu_id =? AND
          dependant_menu_sub_id =?", session_id, dependent_menu.main_menu_id, remove_dependant_sub_menu_id])

        view_dependent_sub_menu = UserDependantSubMenu.where(["user_id =? AND dependant_menu_id =? AND
          dependant_menu_sub_id =?", session_id, dependent_menu.main_menu_id, view_dependant_sub_menu_id])

        if user_dependant_sub_menu.blank?
          dependant_sub_menu = dependent_menu.main_sub_menus.where(["sub_menu_number =?", last_response]).last

          unless dependant_sub_menu.blank?
            if dependant_sub_menu.name.match(/New dependant/i)
              new_dependent_sub_menu = UserDependantSubMenu.new
              new_dependent_sub_menu.user_id = session_id
              new_dependent_sub_menu.dependant_menu_id = dependent_menu.main_menu_id
              new_dependent_sub_menu.dependant_menu_sub_id = new_dependant_sub_menu_id
              new_dependent_sub_menu.save
              #main_seen_status.new_dependant = true
              #main_seen_status.save
            end #if new_dependent_sub_menu.blank?

            if dependant_sub_menu.name.match(/Remove dependants/i)
              remove_dependent_sub_menu = UserDependantSubMenu.new
              remove_dependent_sub_menu.user_id = session_id
              remove_dependent_sub_menu.dependant_menu_id = dependent_menu.main_menu_id
              remove_dependent_sub_menu.dependant_menu_sub_id = remove_dependant_sub_menu_id
              remove_dependent_sub_menu.save
              #main_seen_status.remove_dependant = true
              #main_seen_status.save
            end #if remove_dependent_sub_menu.blank?

            if dependant_sub_menu.name.match(/View dependants/i)
              view_dependent_sub_menu = UserDependantSubMenu.new
              view_dependent_sub_menu.user_id = session_id
              view_dependent_sub_menu.dependant_menu_id = dependent_menu.main_menu_id
              view_dependent_sub_menu.dependant_menu_sub_id = view_dependant_sub_menu_id
              view_dependent_sub_menu.save
              #main_seen_status.view_dependant = true
              #main_seen_status.save
            end #if view_dependent_sub_menu.blank?
          end
        end
        
        user_dependant_sub_menu = UserDependantSubMenu.where(["user_id =?", session_id]).last
        
        unless user_dependant_sub_menu.blank?
          if user_dependant_sub_menu.main_sub_menu.name.match(/New dependant/i)
            if main_user_log.name.blank?
              if fullname_answer.blank? && !fullname_asked
                response  = "CON Dependant Registration: \n Please enter dependant's name\n"
                main_seen_status.name = true
                main_seen_status.save

                fullname_answer = MainUserMenu.new
                fullname_answer.user_id = session_id
                fullname_answer.main_menu_id = menu.main_menu_id
                fullname_answer.main_sub_menu_id = full_name_sub_menu.id
                fullname_answer.save

                return response
              else
                if (params[:text].last == "*")
                  main_seen_status.name = false
                  main_seen_status.save
                  fullname_answer.delete

                  response  = "CON Name can not be blank: \n"
                  response += "Press any key to go to name input"
                  return response
                end

                if main_user_log.name.blank?
                  main_user_log.name = params[:text].split("*").last
                  main_user_log.save
                end
              end
            end

            if main_user_log.gender.blank?
              if gender_answer.blank? && !gender_asked
                response  = "CON Dependant Registration: \n  Please select dependant's gender: \n"
                response += "1. Male \n"
                response += "2. Female \n"

                main_seen_status.gender = true
                main_seen_status.save

                gender_answer = MainUserMenu.new
                gender_answer.user_id = session_id
                gender_answer.main_menu_id = menu.main_menu_id
                gender_answer.main_sub_menu_id = gender_sub_menu.id
                gender_answer.save

                return response
              else
                gender = ""
                gender = "Male" if params[:text].split("*").last.to_s == "1"
                gender = "Female" if params[:text].split("*").last.to_s == "2"

                if (params[:text].last == "*")
                  main_seen_status.gender = false
                  main_seen_status.save
                  gender_answer.delete

                  response  = "CON Gender can not be blank: \n\n"
                  response += "Press any key to go to gender menu"
                  return response
                end

                if (gender.blank?)
                  main_seen_status.gender = false
                  main_seen_status.save
                  gender_answer.delete

                  response  = "CON Invalid gender selected: \n"
                  response += "Press any key to go to gender menu"
                  return response
                end

                if main_user_log.gender.blank?
                  main_user_log.gender = gender
                  main_user_log.save
                end
              end
            end

            if main_user_log.district.blank?
              if current_district_answer.blank? && !district_asked
                response  = "CON Dependant Registration: \n District dependant is currently staying: \n"

                main_seen_status.district = true
                main_seen_status.save

                current_district_answer = MainUserMenu.new
                current_district_answer.user_id = session_id
                current_district_answer.main_menu_id = menu.main_menu_id
                current_district_answer.main_sub_menu_id = current_district_sub_menu.id
                current_district_answer.save

                return response
              else
                if (params[:text].last == "*")
                  main_seen_status.district = false
                  main_seen_status.save
                  current_district_answer.delete

                  response  = "CON District can not be blank: \n"
                  response += "Press any key to go to district input"
                  return response
                end
                if main_user_log.district.blank?
                  main_user_log.district = params[:text].split("*").last
                  main_user_log.save
                end
              end
            end

            main_user_log = MainUserLog.where(["user_id =?", session_id]).last
            member = Member.find_by_phone_number(phone_number)
            new_dependant = Dependant.new
            new_dependant.member_id = member.member_id
            #new_dependant.phone_number = phone_number
            new_dependant.name = main_user_log.name
            new_dependant.gender = main_user_log.gender
            new_dependant.district = main_user_log.district
            new_dependant.save

            main_user_menus = MainUserMenu.where(["user_id =?", session_id])
            main_user_menus.each do |user_menu|
              user_menu.delete
            end

            main_seen_status.delete unless main_seen_status.blank?
            main_user_log.delete unless main_user_log.blank?
            fullname_answer.delete unless fullname_answer.blank?
            gender_answer.delete unless gender_answer.blank?
            current_district_answer.delete unless current_district_answer.blank?

            response  = "CON We have successfully registered the dependant with the following details.\n\n"
            response += "Name: #{main_user_log.name}\n"
            response += "Gender: #{main_user_log.gender}\n"
            response += "Current district: #{main_user_log.district}\n\n"

            response += "Type any key to go to main menu: \n"

            return response
          end
        else
          main_seen_status = MainSeenStatus.where(["user_id =?", session_id]).last
          main_seen_status.dependant = 0
          main_seen_status.save
          response  = "END Invalid option selected. Session terminated.\n"
          return response
        end

        #### view dependants
        if user_dependant_sub_menu.main_sub_menu.name.match(/View dependants/i)
          member = Member.find_by_phone_number(phone_number)
          dependants = member.dependants
          
          if dependants.blank?
            response  = "CON You have not added dependants yet.\n"
            return response
          end
          
          unless dependants.blank?
            response  = "CON View dependants(#{dependants.count}) \n"
            response += "Name Gender District \n"
            dependants.each do |dependant|
              response += "#{dependant.name} #{dependant.gender} #{dependant.district} \n"
              count += 1
            end
            return response
          end
        end
      end

    end

  end

end
