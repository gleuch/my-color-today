class UsersController < ApplicationController

  before_filter :get_user, only: [:show]
  before_filter :authenticate_user!, only: [:edit,:update]


  def show
    results = ->{
      @latest_colors = @user.page_colors.recently(5.days).limit(100)
    }

    respond_to do |format|
      format.html {
        results.call
        render :show
      }
      format.json {
        render json: {
          channel:      @user.uuid,
          channelInfo:  @user.to_api,
          colors:       results.call.map(&:to_public_api),
          url:          user_profile_path(@user),
          viewType:     :user
        }
      }
    end
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

  def user_update_params
    params.require(:user).permit(:name, :email, :profile_private)
  end

end
