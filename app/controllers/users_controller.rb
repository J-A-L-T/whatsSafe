class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy, :data]

def addressBook
  @users = User.all
    render json: @users, :only => [:username]
end

 def data
    @user = User.find(params[:username]) 
    render json: @user, :only => [:salt_masterkey, :pubkey_user, :privkey_user_enc]
  end

  def pubkey
    @user = User.find(params[:username]) 
    render json: @user, :only => [:pubkey_user]
  end

  def create
    @user = User.new(user_params)
    if User.exists?(username: @user.username)
      render json: { "Status" => "409 Conflict"}, status: :conflict
    else
      if @user.save 
        render json: @user, :only => [:username, :id], status: :created
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @User = User.find(params[:username])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :salt_masterkey, :pubkey_user, :privkey_user_enc)
    end
end