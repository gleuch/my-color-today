class UserAuthenticationsController < ApplicationController
 
  before_filter :authenticate_user!, only: [:destroy]
 
 
  def create
    omniauth = request.env['omniauth.auth']
    @auth = UserAuthentication.find_from_omniauth_data(omniauth)

    if current_user
      current_user.authorizations.create(provider: omniauth['provider'], uid: omniauth['uid'])
      # url = edit_user_path(:current)
      flash[:notice] = t('.success.new_auth')

    elsif @auth
      UserSession.create(@auth.user, true)
      flash[:notice] = t('.success.update_auth')

    else
      @new_auth = UserAuthentication.create_from_omniauth_data(omniauth, current_user)
      UserSession.create(@new_auth.user, true)
      flash[:notice] = t('.success.new_user')
    end

    redirect_to after_sign_in_url
  end

  def failure
    flash[:notice] = t('.error')
    redirect_to root_url
  end

  def blank
    raise ActiveRecord::RecordNotFound
  end

  def destroy
    @authorization = current_user.authorizations.find(params[:id])
    @authorization.destroy
    flash[:notice] = t('.success')
    redirect_to edit_user_path(:current)
  end


private


end