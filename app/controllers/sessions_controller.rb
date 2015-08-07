class SessionsController < ApplicationController
  # ew, but a necessary ew :(
  skip_before_filter :verify_authenticity_token, only: :create

  def new
    # go to Instagram for authorization & confirmation
    redirect_to Instagram.authorize_url(:redirect_uri => callback_url)
  end

  def create
    auth_hash = request.env['omniauth.auth']
    user = User.find_or_create_from_omniauth(auth_hash) #returns a user obj. or nil
    # come back to our site
    if params[:provider] == 'instagram'
      response = Instagram.get_access_token(params[:code], :redirect_uri => callback_url)
      session[:access_token] = response.access_token
      session[:user_id] = user.id
    end
    redirect_to feeds_path :notice => "You are logged in to CreepPeep!"
  end



  def show
  end

  def destroy
    session[:user_id] = nil

    redirect_to feeds_path, :notice => "You are signed out of CreepPeep!" 
  end

end

