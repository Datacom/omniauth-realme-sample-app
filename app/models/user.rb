class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :omniauthable, omniauth_providers: [:realme]

  def self.from_omniauth(auth)
    info = auth.info
    where(flt: auth.uid).first_or_create do |realme_user|
      realme_user.first_name = info.first_name
      realme_user.middle_name = info.middle_name
      realme_user.last_name = info.last_name
      realme_user.gender = { 'M' => :male, 'F' => :female }[info.gender]
      realme_user.date_of_birth = Date.new(info.birth_year.to_i, info.birth_month.to_i, info.birth_day.to_i)
      realme_user.birth_country = info.birth_country
      realme_user.address = (info.unit ? info.unit + " " : "") + info.number_street
      realme_user.suburb = info.suburb
      realme_user.post_code = info.post_code
      realme_user.town_or_city = info.town_city
    end
  end
end
