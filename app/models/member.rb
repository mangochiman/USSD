class Member < ActiveRecord::Base
  self.table_name = "members"
  self.primary_key = "member_id"

  has_many :dependants, :foreign_key => :member_id
  
  def self.enroll_in_program(params, phone_number)
    data = params.split("*")
    name = data[1]
    gender = data[2]
    district = data[3]
    
    if gender.to_s == "1"
      gender = "Male"
    else
      gender = "Female"
    end

    member = Member.new
    member.phone_number = phone_number
    member.name = name
    member.gender = gender
    member.district = district
    member.save
    
    return member
  end
  
end
