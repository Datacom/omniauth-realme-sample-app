# omniauth-realme
RealMe Strategy for OmniAuth

## Installation
Add the gem to your `Gemfile`. You may want to do this via submodule and a local path.

```ruby
gem 'omniauth-realme', path: "lib/omniauth-realme"
```

Followed by a `bundle install`.

## Configuration
The configuration for this gem is slightly more involved than some others, due to some custom requirements. The basics are the same as other omniauth gems though.

Start by adding the gem to your config/initializers/devise.rb

```ruby
config.omniauth :realme, ENV['CLIENT_NAME'], ENV['APP_NAME_ASSERT'], ENV['APP_NAME_LOGON'], ENV['SHARED_KEY']
```

Followed by adding realme as a provider in your user model

```ruby
devise :omniauthable, omniauth_providers: [:realme]
```

And the corressponding routes

```ruby
devise_for :realme_users, controllers: { omniauth_callbacks: "realme_users/omniauth_callbacks" }
```


### Callbacks

Notice above we specified the callback controller. This needs to be created under `controllers/users/omniauth_callbacks_controller.rb`

The controller should look something like this:

```ruby
class RealmeUsers::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def realme
    @realme_user = RealmeUser.from_omniauth(request.env["omniauth.auth"])

    if @realme_user.persisted?
      sign_in_and_redirect @realme_user, :event => :authentication #this will throw if @realme_user is not activated
      set_flash_message(:notice, :success, :kind => "Realme") if is_navigational_format?
    else
      # If for some reason the user cannot be saved
      raise 'RealMe user was not found or created'
    end
  end
end
```

This will accept callbacks from the gem and find / create a user accordingly. Should the data from RealMe be insufficient, it will raise an exception.

You will also have to add the `from_omniauth` method to your user model.

```ruby
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
```

This will create the user from the data returned by the gem.

### Redirection

Because of a suspected bug with the omniauth.origin request information, you will have to manually setup redirection after logging in.

You can do this by adding two methods to your `application_controller`.

Note: we are defining the logon type as `assert`. By default it is simply logon.

```ruby
def realme_authenticate!
    # Return URL specified by the gem, due to bug in the request.env['omniauth.origin'] value.
    # See: https://github.com/intridea/omniauth/issues/306
    redirect_to realme_user_omniauth_authorize_path(:realme, logon_type: "assert", return_url: request.env["REQUEST_URI"]) unless realme_user_signed_in?
  end

  # Redirects the user to the appropriate page after sign in
  def after_sign_in_path_for(resource)
    if request.env["omniauth.auth"] && request.env["omniauth.auth"]["extra"]
      return_path = request.env["omniauth.auth"]["extra"]["return_url"]
      raise 'host not allowed in return path' if URI.parse(return_path).host
    end
    return_path || stored_location_for(resource) || root_path
  end
```

The gem is setup to handle a return url being passed in. Note however that this can be insecure, so you will need to sanitise it in the redirection method as above.