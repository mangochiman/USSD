class Member < ActiveRecord::Base
  self.table_name = "members"
  self.primary_key = "member_id"

  def self.enroll_in_program(params)
    data = params["text"].split("*")
    member = Member.new
    member.phone_number = params["phoneNumber"]
    member.name = data[1]
    member.gender = data[2]
    member.district = data[3]
    member.save
    return member
  end
  
end
