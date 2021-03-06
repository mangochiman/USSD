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
      main_seen_status = MainSeenStatus.where(["user_id =?", session_id]).last
      unless main_seen_status.blank?
        reset = (main_seen_status.reset == true)
        if reset
          response  = "CON Welcome #{member.name.upcase} to Wella Funeral Services. Select action \n";

          count = 1
          main_menu.each do |name|
            response += "#{count}. #{name} \n"
            count += 1
          end

          main_seen_status.reset = 0
          main_seen_status.save
          render :text => response and return
        end
      end

      if main_latest_user_menu.blank?
        response  = "CON Welcome #{member.name.upcase} to Wella Funeral Services. Select action \n";

        count = 1
        main_menu.each do |name|
          response += "#{count}. #{name} \n"
          count += 1
        end

        main_menu_response = MainMenu.where(["menu_number =?", params[:text].last]).last

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

      first_name_sub_menu = SubMenu.find_by_name("First name")
      surname_sub_menu = SubMenu.find_by_name("Surname")
      previous_surname_sub_menu = SubMenu.find_by_name("Previous surname")
      initials_sub_menu = SubMenu.find_by_name("Initials")
      gender_sub_menu = SubMenu.find_by_name("Gender")
      title_sub_menu = SubMenu.find_by_name("Title")
      year_of_birth_sub_menu = SubMenu.find_by_name("Year of birth")
      month_of_birth_sub_menu = SubMenu.find_by_name("Month of birth")
      day_of_birth_sub_menu = SubMenu.find_by_name("Day of birth")
      identification_type_sub_menu = SubMenu.find_by_name("Identification type")
      identification_number_sub_menu = SubMenu.find_by_name("Identification number")
      marital_status_sub_menu = SubMenu.find_by_name("Marital status")
      nationality_sub_menu = SubMenu.find_by_name("Nationality")
      country_of_birth_sub_menu = SubMenu.find_by_name("Country of birth")
      product_sub_menu = SubMenu.find_by_name("Product")
      seen_status = SeenStatus.where(["user_id =?", session_id]).last
      products = Product.all

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

      if menu.name.match(/REGISTER/i)
        first_name_answer = UserMenu.where(["user_id =? AND sub_menu_id =?", session_id, first_name_sub_menu.id]).last
        surname_answer = UserMenu.where(["user_id =? AND sub_menu_id =?", session_id, surname_sub_menu.id]).last
        previous_surname_answer = UserMenu.where(["user_id =? AND sub_menu_id =?", session_id, previous_surname_sub_menu.id]).last
        initials_answer = UserMenu.where(["user_id =? AND sub_menu_id =?", session_id, initials_sub_menu.id]).last
        gender_answer = UserMenu.where(["user_id =? AND sub_menu_id =?", session_id, gender_sub_menu.id]).last
        title_answer = UserMenu.where(["user_id =? AND sub_menu_id =?", session_id, title_sub_menu.id]).last
        year_of_birth_answer = UserMenu.where(["user_id =? AND sub_menu_id =?", session_id, year_of_birth_sub_menu.id]).last
        month_of_birth_answer = UserMenu.where(["user_id =? AND sub_menu_id =?", session_id, month_of_birth_sub_menu.id]).last
        day_of_birth_answer = UserMenu.where(["user_id =? AND sub_menu_id =?", session_id, day_of_birth_sub_menu.id]).last
        identification_type_answer = UserMenu.where(["user_id =? AND sub_menu_id =?", session_id, identification_type_sub_menu.id]).last
        identification_number_answer = UserMenu.where(["user_id =? AND sub_menu_id =?", session_id, identification_number_sub_menu.id]).last
        marital_status_answer = UserMenu.where(["user_id =? AND sub_menu_id =?", session_id, marital_status_sub_menu.id]).last
        nationality_answer = UserMenu.where(["user_id =? AND sub_menu_id =?", session_id, nationality_sub_menu.id]).last
        country_of_birth_answer = UserMenu.where(["user_id =? AND sub_menu_id =?", session_id, country_of_birth_sub_menu.id]).last
        product_answer = UserMenu.where(["user_id =? AND sub_menu_id =?", session_id, product_sub_menu.id]).last

        seen_status = SeenStatus.where(["user_id =?", session_id]).last

        first_name_asked = (seen_status.first_name == true)
        surname_asked = (seen_status.surname == true)
        previous_surname_asked = (seen_status.previous_surname == true)
        initials_asked = (seen_status.initials == true)
        gender_asked = (seen_status.gender == true)
        title_asked = (seen_status.title == true)
        year_of_birth_asked = (seen_status.year_of_birth == true)
        month_of_birth_asked = (seen_status.month_of_birth == true)
        day_of_birth_asked = (seen_status.day_of_birth == true)
        identification_type_asked = (seen_status.identification_type == true)
        identification_number_asked = (seen_status.identification_number == true)
        marital_status_asked = (seen_status.marital_status == true)
        nationality_asked = (seen_status.nationality == true)
        country_of_birth_asked = (seen_status.country_of_birth == true)
        product_asked = (seen_status.product == true)


        if user_log.first_name.blank?
          if first_name_answer.blank? && !first_name_asked
            response  = "CON Registration: \n Please enter your first name\n"
            seen_status.first_name = true
            seen_status.save

            first_name_answer = UserMenu.new
            first_name_answer.user_id = session_id
            first_name_answer.menu_id = menu.menu_id
            first_name_answer.sub_menu_id = first_name_sub_menu.id
            first_name_answer.save

            return response
          else
            if (params[:text].last == "*")
              seen_status.first_name = false
              seen_status.save
              first_name_answer.delete

              response  = "CON First name can not be blank: \n\n"
              response += "Press any key to go to first name input"
              return response
            end

            if user_log.first_name.blank?
              user_log.first_name = params[:text].split("*").last
              user_log.save
            end
          end
        end

        if user_log.surname.blank?
          if surname_answer.blank? && !surname_asked
            response  = "CON Registration: \n Please enter your surname\n"
            seen_status.surname = true
            seen_status.save

            surname_answer = UserMenu.new
            surname_answer.user_id = session_id
            surname_answer.menu_id = menu.menu_id
            surname_answer.sub_menu_id = surname_sub_menu.id
            surname_answer.save

            return response
          else
            if (params[:text].last == "*")
              seen_status.surname = false
              seen_status.save
              surname_answer.delete

              response  = "CON Surname can not be blank: \n\n"
              response += "Press any key to go to surname input"
              return response
            end

            if user_log.surname.blank?
              user_log.surname = params[:text].split("*").last
              user_log.save
            end
          end
        end

        if user_log.previous_surname.blank?
          if previous_surname_answer.blank? && !previous_surname_asked
            response  = "CON Registration: \n Please enter your previous surname\n"
            seen_status.previous_surname = true
            seen_status.save

            previous_surname_answer = UserMenu.new
            previous_surname_answer.user_id = session_id
            previous_surname_answer.menu_id = menu.menu_id
            previous_surname_answer.sub_menu_id = previous_surname_sub_menu.id
            previous_surname_answer.save

            return response
          else
            if (params[:text].last != "*")
              user_log.previous_surname = params[:text].split("*").last
              user_log.save
            end
          end
        end

        if user_log.initials.blank?
          if initials_answer.blank? && !initials_asked
            response  = "CON Registration: \n Please enter your initials\n"
            seen_status.initials = true
            seen_status.save

            initials_answer = UserMenu.new
            initials_answer.user_id = session_id
            initials_answer.menu_id = menu.menu_id
            initials_answer.sub_menu_id = initials_sub_menu.id
            initials_answer.save

            return response
          else
            if (params[:text].last != "*")
              user_log.initials = params[:text].split("*").last
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

              response  = "CON Gender can not be blank: \n"
              response += "Press any key to go to gender menu"
              return response
            end

            if (gender.blank?)
              seen_status.gender = false
              seen_status.save
              gender_answer.delete

              response  = "CON Invalid gender selected: \n"
              response += "Press any key to go to gender menu"
              return response
            end

            if user_log.gender.blank?
              user_log.gender = gender
              user_log.save
            end
          end
        end


        if user_log.title.blank?
          if title_answer.blank? && !title_asked
            response  = "CON Registration: \n Please select title\n"
            titles = TitleMenu.all
            titles.each do |title|
              response += "#{title.menu_number}. #{title.name} \n"
            end

            seen_status.title = true
            seen_status.save

            title_answer = UserMenu.new
            title_answer.user_id = session_id
            title_answer.menu_id = menu.menu_id
            title_answer.sub_menu_id = title_sub_menu.id
            title_answer.save

            return response
          else
            selected_title = TitleMenu.where(["menu_number =?", params[:text].last]).last
            if (selected_title.blank?)
              seen_status.title = false
              seen_status.save
              title_answer.delete

              response  = "CON Invalid selection: \n\n"
              response += "Press any key to go to title input"
              return response
            end
            if user_log.title.blank?
              user_log.title = selected_title.name
              user_log.save
            end
          end
        end


        if user_log.year_of_birth.blank?
          if year_of_birth_answer.blank? && !year_of_birth_asked
            response  = "CON Registration: \n Please enter birth year\n"
            seen_status.year_of_birth = true
            seen_status.save

            year_of_birth_answer = UserMenu.new
            year_of_birth_answer.user_id = session_id
            year_of_birth_answer.menu_id = menu.menu_id
            year_of_birth_answer.sub_menu_id = year_of_birth_sub_menu.id
            year_of_birth_answer.save

            return response
          else
            if (params[:text].last == "*")
              seen_status.year_of_birth = false
              seen_status.save
              year_of_birth_answer.delete

              response  = "CON Birth year can not be blank: \n\n"
              response += "Press any key to go to birth year input"
              return response
            end
            if user_log.year_of_birth.blank?
              user_log.year_of_birth = params[:text].split("*").last
              user_log.save
            end
          end
        end

        available_months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Nov", "Dec"]
        if user_log.month_of_birth.blank?
          if month_of_birth_answer.blank? && !month_of_birth_asked
            response  = "CON Registration: \n Please select month\n"
            count = 1
            available_months.each do |name|
              response += "#{count}. #{name} \n"
              count = count + 1
            end
            seen_status.month_of_birth = true
            seen_status.save

            month_of_birth_answer = UserMenu.new
            month_of_birth_answer.user_id = session_id
            month_of_birth_answer.menu_id = menu.menu_id
            month_of_birth_answer.sub_menu_id = month_of_birth_sub_menu.id
            month_of_birth_answer.save

            return response
          else
            selected_month_index = params[:text].last.to_i - 1
            if selected_month_index < 0
              seen_status.month_of_birth = false
              seen_status.save
              month_of_birth_answer.delete

              response  = "CON Invalid selection: \n"
              response += "Press any key to go to month input"
              return response
            end

            selected_month = available_months[selected_month_index]
            if (selected_month.blank?)
              seen_status.month_of_birth = false
              seen_status.save
              month_of_birth_answer.delete

              response  = "CON Invalid selection: \n"
              response += "Press any key to go to month input"
              return response
            end

            if user_log.month_of_birth.blank?
              user_log.month_of_birth = selected_month
              user_log.save
            end
          end
        end

        if user_log.day_of_birth.blank?
          if day_of_birth_answer.blank? && !day_of_birth_asked
            response  = "CON Registration: \n Please enter day of birth\n"
            seen_status.day_of_birth = true
            seen_status.save

            day_of_birth_answer = UserMenu.new
            day_of_birth_answer.user_id = session_id
            day_of_birth_answer.menu_id = menu.menu_id
            day_of_birth_answer.sub_menu_id = day_of_birth_sub_menu.id
            day_of_birth_answer.save

            return response
          else
            day_of_birth = params[:text].last
            birth_date = (user_log.year_of_birth.to_s + " " + user_log.month_of_birth.to_s + " " + day_of_birth.to_s).to_date rescue nil
            if (birth_date.blank?)
              seen_status.day_of_birth = false
              seen_status.save
              day_of_birth_answer.delete

              response  = "CON Invalid date: \n\n"
              response += "Press any key to go to day input"
              return response
            end
            if user_log.day_of_birth.blank?
              user_log.day_of_birth = params[:text].split("*").last
              user_log.save
            end
          end
        end

        if user_log.identification_type.blank?
          if identification_type_answer.blank? && !identification_type_asked
            response  = "CON Registration: \n Please select identification type\n"
            identification_types = IdentificationTypeMenu.all
            identification_types.each do |identification_type|
              response += "#{identification_type.menu_number}. #{identification_type.name} \n"
            end
            seen_status.identification_type = true
            seen_status.save

            identification_type_answer = UserMenu.new
            identification_type_answer.user_id = session_id
            identification_type_answer.menu_id = menu.menu_id
            identification_type_answer.sub_menu_id = identification_type_sub_menu.id
            identification_type_answer.save

            return response
          else
            selected_identification_type = IdentificationTypeMenu.where(["menu_number =?", params[:text].last]).last
            if (selected_identification_type.blank?)
              seen_status.identification_type = false
              seen_status.save
              identification_type_answer.delete

              response  = "CON Invalid selection: \n\n"
              response += "Press any key to go to identification type input"
              return response.+
            end
            if user_log.identification_type.blank?
              user_log.identification_type = selected_identification_type.name
              user_log.save
            end
          end
        end

        if user_log.identification_number.blank?
          if identification_number_answer.blank? && !identification_number_asked
            response  = "CON Registration: \n Please select identification type\n"
            seen_status.identification_type = true
            seen_status.save

            identification_number_answer = UserMenu.new
            identification_number_answer.user_id = session_id
            identification_number_answer.menu_id = menu.menu_id
            identification_number_answer.sub_menu_id = identification_number_sub_menu.id
            identification_number_answer.save

            return response
          else
            if (params[:text].last == "*")
              seen_status.identification_type = false
              seen_status.save
              identification_type_answer.delete

              response  = "CON Identification number can not be blank: \n\n"
              response += "Press any key to go to identification number input"
              return response
            end
            if user_log.identification_number.blank?
              user_log.identification_number = params[:text].split("*").last
              user_log.save
            end
          end
        end

        if user_log.marital_status.blank?
          if marital_status_answer.blank? && !marital_status_asked
            response  = "CON Registration: \n Please select marital status\n"
            marital_statuses = MaritalStatus.all
            marital_statuses.each do |marital_status|
              response += "#{marital_status.menu_number}. #{marital_status.name} \n"
            end
            seen_status.marital_status = true
            seen_status.save

            marital_status_answer = UserMenu.new
            marital_status_answer.user_id = session_id
            marital_status_answer.menu_id = menu.menu_id
            marital_status_answer.sub_menu_id = marital_status_sub_menu.id
            marital_status_answer.save

            return response
          else
            selected_marital_status = MaritalStatus.where(["menu_number =?", params[:text].last]).last
            if (selected_marital_status.blank?)
              seen_status.marital_status = false
              seen_status.save
              marital_status_answer.delete

              response  = "CON Invalid selection: \n\n"
              response += "Press any key to go to marital status"
              return response
            end
            if user_log.marital_status.blank?
              user_log.marital_status = selected_marital_status.name
              user_log.save
            end
          end
        end

        country_of_birth_options = ["Malawi", "Foreign"]
        if user_log.country_of_birth.blank?
          if country_of_birth_answer.blank? && !country_of_birth_asked
            response  = "CON Registration: \n Country of birth\n"
            count = 1
            country_of_birth_options.each do |option|
              response += "#{count}. #{option} \n"
              count = count + 1
            end
            seen_status.country_of_birth = true
            seen_status.save

            country_of_birth_answer = UserMenu.new
            country_of_birth_answer.user_id = session_id
            country_of_birth_answer.menu_id = menu.menu_id
            country_of_birth_answer.sub_menu_id = country_of_birth_sub_menu.id
            country_of_birth_answer.save

            return response
          else

            selected_index = params[:text].last.to_i - 1
            if selected_index < 0
              seen_status.country_of_birth = false
              seen_status.save
              country_of_birth_answer.delete

              response  = "CON Invalid selection: \n"
              response += "Press any key to go to marital status"
              return response
            end

            selected_option = country_of_birth_options[selected_index]
            if (selected_option.blank?)
              seen_status.country_of_birth = false
              seen_status.save
              country_of_birth_answer.delete

              response  = "CON Invalid selection: \n"
              response += "Press any key to go to marital status"
              return response
            end


            if user_log.marital_status.blank?
              user_log.marital_status = selected_option
              user_log.save
            end
          end
        end

        nationality_options = ["Malawian", "Foreign"]
        if user_log.nationality.blank?
          if nationality_answer.blank? && !nationality_asked
            response  = "CON Registration: \n Nationality\n"
            count = 1
            nationality_options.each do |option|
              response += "#{count}. #{option} \n"
              count = count + 1
            end
            seen_status.nationality = true
            seen_status.save

            nationality_answer = UserMenu.new
            nationality_answer.user_id = session_id
            nationality_answer.menu_id = menu.menu_id
            nationality_answer.sub_menu_id = nationality_sub_menu.id
            nationality_answer.save

            return response
          else

            selected_index = params[:text].last.to_i - 1
            if selected_index < 0
              seen_status.nationality = false
              seen_status.save
              nationality_answer.delete

              response  = "CON Invalid selection: \n"
              response += "Press any key to go to nationality"
              return response
            end

            selected_option = nationality_options[selected_index]
            if (selected_option.blank?)
              seen_status.nationality = false
              seen_status.save
              nationality_answer.delete

              response  = "CON Invalid selection: \n"
              response += "Press any key to go to nationality"
              return response
            end

            if user_log.nationality.blank?
              user_log.nationality = selected_option
              user_log.save
            end
          end
        end


        if user_log.product.blank?
          if product_answer.blank? && !product_asked
            response  = "CON Please select funeral product: \n"
            products.each do |product|
              response += "#{product.number}. #{product.name} \n"
            end

            seen_status.product = true
            seen_status.save

            product_answer = UserMenu.new
            product_answer.user_id = session_id
            product_answer.menu_id = menu.menu_id
            product_answer.sub_menu_id = product_sub_menu.id
            product_answer.save

            return response
          else
            product_number = params[:text].split("*").last.to_s
            selected_product = Product.find_by_number(product_number)

            if (params[:text].last == "*")
              seen_status.product = false
              seen_status.save
              product_answer.delete

              response  = "CON Product can not be blank: \n"
              response += "Press any key to go to products menu"
              return response
            end

            if (selected_product.blank?)
              seen_status.product = false
              seen_status.save
              product_answer.delete

              response  = "CON Invalid product selected: \n\n"
              response += "Press any key to go to products menu"
              return response
            end

            if user_log.product.blank?
              user_log.product = selected_product.name
              user_log.save
            end
          end
        end

        user_log = UserLog.where(["user_id =?", session_id]).last

        new_member = Member.new
        new_member.phone_number = phone_number
        new_member.gender = user_log.gender
        new_member.title = user_log.title
        new_member.initials = user_log.initials
        new_member.first_name = user_log.first_name
        new_member.surname = user_log.surname
        new_member.previous_surname = user_log.previous_surname
        new_member.date_of_birth = ""
        new_member.identification_type = user_log.identification_type
        new_member.identification_number = user_log.identification_number
        new_member.country_of_birth = user_log.country_of_birth
        new_member.nationality = user_log.nationality
        new_member.marital_status = user_log.marital_status
        new_member.product = user_log.product
        new_member.save

        response  = "END We have successfully registered your phone number (#{phone_number})with the following details.\n";
        response += "Name: #{user_log.first_name} #{user_log.surname}\n"
        response += "Previous surname: #{user_log.previous_surname}\n"
        response += "Gender: #{user_log.gender}\n"
        response += "Title: #{user_log.title}\n"
        response += "Identification Type: #{user_log.identification_type}\n"
        response += "Identification Number: #{user_log.identification_number}\n"
        response += "Date of Birth:  #{user_log.date_of_birth}\n"
        response += "Marital status: #{user_log.marital_status}\n"
        response += "Product: #{user_log.product}\n\n"

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
      member = Member.find_by_phone_number(phone_number)
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
      payments_menu_asked = (main_seen_status.payment_menu == true)
      claims_menu_asked = (main_seen_status.claims_menu == true)

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

            #main_seen_status.delete unless main_seen_status.blank?
            #main_user_log.delete unless main_user_log.blank?
            #fullname_answer.delete unless fullname_answer.blank?
            #gender_answer.delete unless gender_answer.blank?
            #current_district_answer.delete unless current_district_answer.blank?

            reset_session(session_id)
            response  = "CON We have successfully registered the dependant with the following details.\n\n"
            response += "Name: #{main_user_log.name}\n"
            response += "Gender: #{main_user_log.gender}\n"
            response += "Current district: #{main_user_log.district}\n\n"
            response += "Reply with # to go to main menu \n"
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
            reset_session(session_id)
            response  = "CON You have not added dependants yet.\n"
            response += "Press any key to go to main menu \n"
            return response
          end

          unless dependants.blank?
            response  = "CON View dependants(#{dependants.count}) \n"
            response += "Name  |  Gender  |  District \n"
            dependants.each do |dependant|
              response += "#{dependant.name} | #{dependant.gender} | #{dependant.district} \n"
            end

            reset_session(session_id)
            response += "Press any key to go to dependant's menu \n"
            return response
          end
        end

        if user_dependant_sub_menu.main_sub_menu.name.match(/Remove dependants/i)
          member = Member.find_by_phone_number(phone_number)
          dependants = member.dependants
          remove_dependant = (main_seen_status.remove_dependant == true)

          if dependants.blank?
            response  = "CON You have not added dependants yet.\n"
            response += "Press any key to go to main menu \n"
            reset_session(session_id)
            return response
          end

          if remove_dependant
            dependant = dependants[last_response.to_i - 1]
            if (last_response.to_i <= 0 || dependant.blank?)
              main_seen_status.remove_dependant = false
              main_seen_status.save
              response  = "CON Invalid option selected.\n"
              response += "Press any key to go to dependant's menu \n"
              return response
            end

            dependant.delete

            response  = "CON Dependant deleted successfully.\n"
            response += "Press any key to go to main menu \n"
            reset_session(session_id)
            return response
          end

          unless dependants.blank?
            response  = "CON Select depandant to delete \n"
            count = 1
            dependants.each do |dependant|
              response += "#{count}. #{dependant.name} | #{dependant.gender} | #{dependant.district} \n"
              count = count + 1
            end
            main_seen_status.remove_dependant = true
            main_seen_status.save
            return response
          end


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
        end
      end

      if menu.name.match(/PAYMENTS/i)
        if !payments_menu_asked
          response  = "CON Payments Menu. Select action \n"
          count = 1
          payment_sub_menus = menu.main_sub_menus.collect{|msm|msm.name}
          payment_sub_menus.each do |name|
            response += "#{count}. #{name} \n"
            count += 1
          end

          main_seen_status.payment_menu = true #one has to go
          main_seen_status.save

          return response
        end


        if payments_menu_asked
          payment_menu = MainMenu.find_by_name("Payments")
          payment_sub_menu = payment_menu.main_sub_menus.where(["sub_menu_number =?", last_response]).last
          make_payment_sub_menu_id = MainSubMenu.find_by_name("Make payment").main_sub_menu_id
          check_balance_sub_menu_id = MainSubMenu.find_by_name("Check balance").main_sub_menu_id
          user_payment_sub_menu = UserPaymentSubMenu.where(["user_id =?", session_id])
          #payment_menu_answer = MainUserMenu.where(["user_id =? AND main_sub_menu_id =?", session_id, make_payment_sub_menu_id.id]).last

          if user_payment_sub_menu.blank?
            if payment_sub_menu.blank?
              response  = "CON Invalid option \n"
              response  += "Reply with any key to go to previous menu \n"
              main_seen_status.payment_menu = false #one has to go
              main_seen_status.save
              return response
            else
              make_payment_sub_menu = UserPaymentSubMenu.new
              make_payment_sub_menu.user_id = session_id
              make_payment_sub_menu.payment_menu_id = payment_menu.main_menu_id

              if payment_sub_menu.name.match(/Make payment/i)
                make_payment_sub_menu.payment_menu_sub_id = make_payment_sub_menu_id
                make_payment_sub_menu.save
              end

              if payment_sub_menu.name.match(/Check balance/i)
                make_payment_sub_menu.payment_menu_sub_id = check_balance_sub_menu_id
                make_payment_sub_menu.save

                reset_session(session_id)
                response  = "CON Check balance\n. We will notify you through an SMS\n\n"
                response += "Reply with # to go to main menu \n"
                return response
              end
            end
          end

          if main_user_log.payment_menu.blank?
            response  = "CON Payment menu: \n"
            payment_menus = PaymentMenu.all
            payment_menus.each do |pm|
              response += "#{pm.menu_number}. #{pm.name}\n"
            end
            main_user_log.payment_menu = params[:text].split("*").last
            main_user_log.save
            return response
          end

          payment_type = PaymentMenu.where(["menu_number =?", last_response])
          user_payment_menu = UserPaymentMenu.where(["user_id =?", session_id]).last

          if user_payment_menu.blank?
            if payment_type.blank?
              response  = "CON Invalid option \n"
              response  += "Reply with any key to go to previous menu \n"

              main_user_log.payment_menu = nil
              main_user_log.save
              return response
            else
              user_payment_menu = UserPaymentMenu.new
              user_payment_menu.user_id = session_id
              user_payment_menu.payment_menu_id = last_response
              user_payment_menu.save
            end
          end

          menu_number = user_payment_menu.payment_menu_id #take note here
          payment_option = PaymentMenu.where(["menu_number =?", menu_number]).last

          if payment_option.name.match(/Airtel/i)
            if !main_seen_status.airtel
              response  = "CON Airtel money: \n"
              response  += "Enter valid amount"
              main_seen_status.airtel = true
              main_seen_status.save
              return response
            end

            if main_user_log.airtel_money.blank?
              if (params[:text].last == "*")
                main_seen_status.airtel = false
                main_seen_status.save

                response  = "CON Invalid amount: \n"
                response += "Reply with # to got to previous menu"
                return response
              end

              number_is_valid = (last_response =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/)
              if (!number_is_valid)
                main_seen_status.airtel = false
                main_seen_status.save

                response  = "CON Invalid amount: \n"
                response += "Reply with # to got to previous menu"
                return response
              end

              main_user_log.airtel_money = last_response
              main_user_log.save
              reset_session(session_id)
              response  = "CON Transaction of #{last_response} is in progress. You will be notified of an SMS: \n\n"
              response+= "Reply with # for main menu"
              return response

            end
          end

          if payment_option.name.match(/TNM/i)
            if !main_seen_status.tnm
              response  = "CON TNM Mpamba: \n"
              response  += "Enter valid amount"
              main_seen_status.tnm = true
              main_seen_status.save
              return response
            end

            if main_user_log.tnm_mpamba.blank?
              if (params[:text].last == "*")
                main_seen_status.tnm = false
                main_seen_status.save

                response  = "CON Invalid amount: \n"
                response += "Reply with # to got to previous menu"
                return response
              end

              number_is_valid = (last_response =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/)
              if (!number_is_valid)
                main_seen_status.tnm = false
                main_seen_status.save

                response  = "CON Invalid amount: \n"
                response += "Reply with # to got to previous menu"
                return response
              end

              main_user_log.tnm_mpamba = last_response
              main_user_log.save
              reset_session(session_id)
              response  = "CON Transaction of #{last_response} is in progress. You will be notified of an SMS: \n\n"
              response+= "Reply with # for main menu"
              return response

            end
          end

        end

      end

      if menu.name.match(/CLAIMS/i)
        if !claims_menu_asked
          response  = "CON Claims Menu. Select action \n"
          count = 1
          claims_sub_menus = menu.main_sub_menus.collect{|msm|msm.name}
          claims_sub_menus.each do |name|
            response += "#{count}. #{name} \n"
            count += 1
          end

          main_seen_status.claims_menu = true
          main_seen_status.save

          return response
        end

        ######################################
        if claims_menu_asked
          claims_menu = MainMenu.find_by_name("Claims")
          claim_sub_menu = claims_menu.main_sub_menus.where(["sub_menu_number =?", params[:text].last]).last
          make_claim_sub_menu_id = MainSubMenu.find_by_name("Make claim").main_sub_menu_id
          cancel_claims_sub_menu_id = MainSubMenu.find_by_name("Cancel claims").main_sub_menu_id
          view_claims_sub_menu_id = MainSubMenu.find_by_name("View Claims").main_sub_menu_id
          user_claims_sub_menu = UserClaimsSubMenu.where(["user_id =?", session_id])

          if user_claims_sub_menu.blank?
            if claim_sub_menu.blank?
              response  = "CON Invalid option \n"
              response  += "Reply with any key to go to previous menu \n"
              main_seen_status.claims_menu = false #one has to go
              main_seen_status.save
              return response
            else
              user_claims_sub_menu = UserClaimsSubMenu.new
              user_claims_sub_menu.user_id = session_id
              user_claims_sub_menu.claim_menu_id = claims_menu.main_menu_id

              if claim_sub_menu.name.match(/Make claim/i)
                user_claims_sub_menu.claim_menu_sub_id = make_claim_sub_menu_id
                user_claims_sub_menu.save
              end

              if claim_sub_menu.name.match(/Cancel claims/i)
                user_claims_sub_menu.claim_menu_sub_id = cancel_claims_sub_menu_id
                user_claims_sub_menu.save
              end

              if claim_sub_menu.name.match(/View Claims/i)
                user_claims_sub_menu.claim_menu_sub_id = view_claims_sub_menu_id
                user_claims_sub_menu.save
              end

            end
          end

          make_claim_answer = UserClaimsSubMenu.where(["user_id =? AND claim_menu_id =? AND claim_menu_sub_id =?", session_id,
                                                       claims_menu.main_menu_id, make_claim_sub_menu_id])

          view_claims_answer = UserClaimsSubMenu.where(["user_id =? AND claim_menu_id =? AND claim_menu_sub_id =?", session_id,
                                                        claims_menu.main_menu_id, view_claims_sub_menu_id])

          cancel_claims_answer = UserClaimsSubMenu.where(["user_id =? AND claim_menu_id =? AND claim_menu_sub_id =?", session_id,
                                                          claims_menu.main_menu_id, cancel_claims_sub_menu_id])

          unless make_claim_answer.blank?
            if main_user_log.claim_description.blank?
              if !(main_seen_status.new_claims_menu == true)
                main_seen_status.new_claims_menu = true
                main_seen_status.save

                response  = "CON Claim Description \n"
                return response
              end

              if (params[:text].last == "*")
                main_seen_status.new_claims_menu = false
                main_seen_status.save

                response  = "CON Description can not be blank: \n"
                response += "Press any key to go to previous menu"
                return response
              end

              new_claim = Claim.new
              new_claim.member_id = member.member_id
              new_claim.description = last_response
              new_claim.save

              main_user_log.claim_description = last_response
              main_user_log.save

              response  = "CON Message \n"
              response += "Your claim has been made. You will hear from us soon\n\n"
              response += "Reply with # to go to main menu"

              reset_session(session_id)
              return response
            end
          end

          unless view_claims_answer.blank?
            claims = member.claims
            response  = "CON My claims (#{claims.count}) \n"
            response += "Date  | Description \n"
            claims.each do |claim|
              response += "#{claim.created_at.to_date.strftime("%Y-%b-%d")} | #{claim.description} \n"
            end
            response += "Reply with # to go to main menu"

            reset_session(session_id)
            return response
          end

          unless cancel_claims_answer.blank?
            claims = member.claims
            if claims.blank?
              reset_session(session_id)
              response  = "CON You have not made any claims yet.\n"
              response += "Reply with # to go to main menu \n"

              return response
            end

            if !(main_seen_status.cancel_claims_menu == true)
              response  = "CON Cancel claims (#{claims.count}). Select item to delete \n"
              count = 1
              claims.each do |claim|
                response += "#{count}. #{claim.created_at.to_date.strftime("%Y-%b-%d")} | #{claim.description} \n"
                count = count + 1
              end

              main_seen_status.cancel_claims_menu = true
              main_seen_status.save

              return response
            end

            claim = claims[params[:text].last.to_i - 1]

            if (params[:text].last.to_i <= 0 || claim.blank?)
              main_seen_status.cancel_claims_menu = false
              main_seen_status.save
              response  = "CON Invalid option selected.\n"
              response += "Reply with any key to go to previous menu \n"
              return response
            end

            claim.delete
            response  = "CON The selected claim has been deleted.\n"
            response += "Reply with # to go to main menu"
            reset_session(session_id)
            return response

          end

        end
        ######################################
      end


    end

  end

  def reset_session(session_id)
    user_dependant_sub_menus = UserDependantSubMenu.where(["user_id =?", session_id])
    main_user_menus =  MainUserMenu.where(["user_id =?", session_id])
    main_user_logs = MainUserLog.where(["user_id =?", session_id])
    main_seen_status = MainSeenStatus.where(["user_id =?", session_id])
    user_claims_sub_menus  = UserClaimsSubMenu.where(["user_id =?", session_id])
    user_payment_sub_menus = UserPaymentSubMenu.where(["user_id =?", session_id])


    user_dependant_sub_menus.each do |i|
      i.delete
    end

    main_user_menus.each do |j|
      j.delete
    end

    main_user_logs.each do |k|
      k.delete
    end

    main_seen_status.each do |m|
      m.delete
    end

    user_claims_sub_menus.each do |n|
      n.delete
    end

    user_payment_sub_menus.each do |p|
      p.delete
    end

    main_seen_status = MainSeenStatus.new
    main_seen_status.user_id = session_id
    main_seen_status.reset = 1
    main_seen_status.save

  end

end
