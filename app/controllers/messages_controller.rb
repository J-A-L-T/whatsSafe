class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :update, :destroy, :data]

  def send
    @message = Message.new(message_params)

    if @message.save 
      render json: @message, status: :created
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def recieve
    @message = Message.find(params[:id]) 
    render json: @message, :only => [:id_sender, :cipher, :iv, :key_recipient_enc, :sig_recipient]
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @Message = Message.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:id_recipient, :id_sender, :cipher, :iv, :key_recipient_enc, :sig_recipient)
    end
end