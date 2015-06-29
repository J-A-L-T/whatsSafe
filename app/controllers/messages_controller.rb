require 'openssl' # Dokumentation dazu: http://ruby-doc.org/stdlib-2.0/libdoc/openssl/rdoc/OpenSSL.html
class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :update, :destroy]

  def create
    @outerMessage = OuterMessage.new(outer_message_params)
    @outerMessage.recipient = params[:username]
    if (Time.now.to_i-@outerMessage.timestamp) > 300
     render json: { "Status" => "408 Request Time-out"}, status: :request_timeout
    else
      # @pubkey = User.find(@outerMessage.sender).pubkey_user
      # @signature = @outerMessage.sig_service
      # digest = OpenSSL::Digest::SHA256.new
      # @data = @outerMessage.sender + @outerMessage.cipher + @outerMessage.iv + @outerMessage.key_recipient_enc + @outerMessage.sig_recipient + @outerMessage.timestamp + params[:id_recipient]
      # if @pubkey.verify digest, @signature, @data
      # else
      #   render json: { "Status" => "401 Unauthorized"}, status: :unauthorized
      
      @message = Message.new( :recipient => params[:username],
                                :sender => @outerMessage.sender,
                                :cipher => @outerMessage.cipher,
                                :iv => @outerMessage.iv,
                                :key_recipient_enc => @outerMessage.key_recipient_enc,
                                :sig_recipient => @outerMessage.sig_recipient,)
        if @message.save 
          render json: @message, :only => [:username ,:sender, :cipher, :iv, :key_recipient_enc, :sig_recipient], status: :created
        else
          render json: @message.errors, status: :unprocessable_entity
        end
      end
    end

  def recieve
    # Krypto-Vorbereitung
    # digest = OpenSSL::Digest::SHA256.new
    # @pubkey = User.find(username).pubkey_user

    # Empfang der Parameter
    @timestamp = params[:timestamp].to_f
    @signature = params[:signature]
    # Time-out-Abfrage
    if (Time.now.to_i-@timestamp) > 300
     render json: { "Status" => "408 Request Time-out"}, status: :request_timeout
    else
      # if @pubkey.verify digest, @signature, Identität+Timestamp
        # Liefern der Nachricht
        @messages = Message.where(:recipient => params[:username])
        render json: @messages, :only => [:sender, :cipher, :iv, :key_recipient_enc, :sig_recipient]
      # else
      #   render json: { "Status" => "401 Unauthorized"}, status: :unauthorized
      # end
    end
  end


  private
    def set_message
      @Message = Message.find(params[:username])
    end

    def outer_message_params
      params.require(:outerMessage).permit(:timestamp, :sig_service, :sender, :cipher, :iv, :key_recipient_enc, :sig_recipient)
    end
end