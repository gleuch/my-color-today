class UserAuthenticationsController < ApplicationController
 
  before_filter :authenticate_user!, only: [:destroy]
 
 
  def create
    omniauth = request.env['omniauth.auth']
    @auth = UserAuthentication.find_from_omniauth_data(omniauth)

    session[:extension_message] = {'action' => 'reload-auth'}

    if current_user && @auth
      if @auth
        @auth.update_from_omniauth_data(authentication_params)
      else
        current_user.authentications.create(provider: omniauth['provider'], uid: omniauth['uid'])
      end
      flash[:notice] = t('.success.new_auth')
      @user = current_user

    elsif @auth
      @auth.update_from_omniauth_data(authentication_params)
      UserSession.create(@auth.user, true)
      flash[:notice] = t('.success.update_auth')
      @user = @auth.user

    else
      @new_auth = UserAuthentication.create_from_omniauth_data(authentication_params, current_user)
      UserSession.create(@new_auth.user, true)
      @user = @new_auth.user
      flash[:notice] = t('.success.new_user')
    end

    if session[:auth_api_app].present?
      ApiToken.where(token_key: session.delete(:auth_api_app)).first.update(user: @user)
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

  def authentication_params
    auth = env['omniauth.auth']

    {
      name: auth.info.name,
      username: auth.info.try(:nickname),
      email: auth.info.try(:email),
      profile_image_url: auth.info.try(:image),
      provider: auth['provider'], 
      uid: auth['uid'], 
      token: auth.credentials.token, 
      secret: auth.credentials.try(:secret),
      refresh_token: auth.credentials.try(:refresh_token),
      token_expire_at: (Time.at(auth.credentials.expires_at) rescue nil),
      birthday: auth.extra.raw_info.try(:birthday),
      gender: auth.extra.raw_info.try(:gender),
      profile_url: auth.extra.raw_info.try(:profile_url),
      locale: auth.extra.raw_info.try(:locale)
    }
  end

end