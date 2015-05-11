class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :update, :destroy, :data]


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