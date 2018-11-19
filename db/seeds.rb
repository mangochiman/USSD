# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

menu = {
  {:menu_number => 1, :menu_name => "Register"} => {1 => "Full name", 2 => "Gender", 3 => "District", 4 => "Product"},
  {:menu_number => 2, :menu_name => "Exit"} => {}
}

main_menu = {
  {:menu_number => 1, :menu_name => "Dependants"} => {1 => "New dependant", 2 => "Remove dependants", 3 => "View dependants"},
  {:menu_number => 2, :menu_name => "Claims"} => {1 => "Make claim", 2 => "Cancel claims", 3 => "View Claims"},
  {:menu_number => 3, :menu_name => "Payments"} => {1 => "Make payment", 2 => "Check balance"},
  {:menu_number => 4, :menu_name => "Exit"} => {}
}

menu.each do |key, values|
  menu_number = key[:menu_number]
  menu_name = key[:menu_name]
  m = Menu.new
  m.name = menu_name
  m.menu_number = menu_number
  m.save
  values.each do |k, v|
    sm = SubMenu.new
    sm.menu_id = m.menu_id
    sm.name = v
    sm.sub_menu_number = k
    sm.save
  end
end

main_menu.each do |key, values|
  menu_number = key[:menu_number]
  menu_name = key[:menu_name]
  m = MainMenu.new
  m.name = menu_name
  m.menu_number = menu_number
  m.save
  values.each do |k, v|
    sm = MainSubMenu.new
    sm.main_menu_id = m.main_menu_id
    sm.name = v
    sm.sub_menu_number = k
    sm.save
  end
end

dependant_menu = [[1, "New dependant"], [2, "Remove dependants"], [3, "View dependants"]]
dependant_menu.each do |menu|
  menu_number = menu[0]
  menu_name = menu[1]

  new_dependant_menu = DependantMenu.new
  new_dependant_menu.menu_number = menu_number
  new_dependant_menu.name = menu_name
  new_dependant_menu.save
end

payment_menu = [[1, "Airtel Money"], [2, "TNM Mpamba"]]
payment_menu.each do |menu|
  menu_number = menu[0]
  menu_name = menu[1]

  payment_menu = PaymentMenu.new
  payment_menu.menu_number = menu_number
  payment_menu.name = menu_name
  payment_menu.save
end

products = [[1, "Pensioners funeral plan"]]
products.each do |product|
  product_number = product[0]
  product_name = product[1]
  p = Product.new
  p.number = product_number
  p.name = product_name
  p.save
end

titles = [["Mr", 1], ["Miss", 2], ["Mrs", 3], ["Dr", 4], ["Prof", 5]]
titles.each do |title|
  name = title[0]
  menu_number = title[1]

  title_menu = TitleMenu.new
  title_menu.name = name
  title_menu.menu_number = menu_number
  title_menu.save

end

marital_statuses = [
    ["Married", 1],
    ["Single", 2],
    ["Divorced", 3],
    ["Widowed", 4]
]

marital_statuses.each do |row|
  name = row[0]
  menu_number = row[1]

  marital_status = MaritalStatus.new
  marital_status.name = name
  marital_status.menu_number = menu_number
  marital_status.save
end

identification_types = [
    ["National ID", 1],
    ["Passport", 2],
    ["Driver's licence", 3],
    ["Driver's ID", 4],
    ["Voter's card", 5]
]

identification_types.each do |row|
  name = row[0]
  menu_number = row[1]

  identification_type_menu = IdentificationTypeMenu.new
  identification_type_menu.name = name
  identification_type_menu.menu_number = menu_number
  identification_type_menu.save
end