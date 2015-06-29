class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy, :data]

def addressBook
  @users = User.all
    render json: @users, :only => [:username]
end

  def data
    if User.exists?(username: params[:username])
    @user = User.find_by_username(params[:username])
    render json: @user, :only => [:salt_masterkey, :pubkey_user, :privkey_user_enc]
    logger.info "################# LOG #################"
    logger.info "Status: 200 - OK"
    logger.info "################# LOG #################"
    else
    render json: { "Status" => "404 Not Found"}, status: :not_found
    logger.info "################# LOG #################"
    logger.info "Status: 404 - Not Found"
    logger.info "################# LOG #################"
    end
  end


  def pubkey
    if User.exists?(username: params[:username])
    @user = User.find_by_username(params[:username])
    render json: @user, :only => [:pubkey_user]
    logger.info "################# LOG #################"
    logger.info "Status: 200 - OK"
    logger.info "################# LOG #################"
    else
    render json: { "Status" => "404 Not Found"}, status: :not_found
    logger.info "################# LOG #################"
    logger.info "Status: 404 - Not Found"
    logger.info "################# LOG #################"
    end
  end

  def create
    @user = User.new(user_params)
    if User.exists?(username: @user.username)
      render json: { "Status" => "409 Conflict"}, status: :conflict
      logger.info "################# LOG #################"
      logger.info "Status: 409 - Conflict"
      logger.info "################# LOG #################"
    else
      if @user.save 
        render json: @user, :only => [:username, :id], status: :created
        logger.info "################# LOG #################"
        logger.info "Status: 404 - Not Found"
        logger.info "################# LOG #################"
      else
        render json: @user.errors, status: :unprocessable_entity
        logger.info "################# LOG #################"
        logger.info "Status: 422  - Unprocessable Entity"
        logger.info "################# LOG #################"
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @User = User.find_by_username(params[:username])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :salt_masterkey, :pubkey_user, :privkey_user_enc)
    end
end