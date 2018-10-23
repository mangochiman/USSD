# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

menu = {
  {:menu_number => 1, :menu_name => "Register"} => {1 => "Full name", 2 => "Gender", 3 => "District"},
  {:menu_number => 2, :menu_name => "Check premiums"} => {},
  {:menu_number => 3, :menu_name => "Exit"} => {}
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