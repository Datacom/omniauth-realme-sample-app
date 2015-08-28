class User < ActiveRecord::Base
  devise :omniauthable, omniauth_providers: [:realme]

  def self.from_omniauth(auth)
    info = auth.info

    where(flt: auth.uid).first_or_create do |user|
      user.first_name = info.first_name
      user.fit = info.fit
      user.middle_name = info.middle_name
      user.last_name = info.last_name
    end
  end
end
