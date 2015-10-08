class UsersController < ApplicationController

  before_filter :get_user, only: [:show]
  before_filter :get_colors_date, only: [:show]
  before_filter :authenticate_user!, only: [:edit,:update]

  set_pagination_headers :colors, only: [:show]


  def show
    render_user_channel(@user)
  end

  def edit
    respond_to do |format|
      format.html { render :edit }
    end
  end

  def update
    results = ->{
      current_user.update(user_update_params)
    }

    respond_to do |format|
      format.html {
        if results.call
          redirect_to user_settings_url
        else
          render :edit
        end
      }
      format.json {
        if results.call
          render json: { user: current_user.to_api(:current_user) }
        else
          render json: { errors: current_users.errors }, status: :unprocessable_entity
        end
      }
    end
  end

private

  def get_user
    @user = User.find(params[:id])
    raise ActiveRecord::RecordNotFound if @user.blank?
  end

  def get_colors_date
    @colors_date = Date.parse(params[:date]) rescue nil
    @colors_date ||= @user.page_colors.recent.first.created_at.to_date rescue Date.today
  end

  def user_update_params
    params.require(:user).permit(:name, :email, :profile_private)
  end

end
