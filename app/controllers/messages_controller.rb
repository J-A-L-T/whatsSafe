require 'openssl' # Dokumentation dazu: http://ruby-doc.org/stdlib-2.0/libdoc/openssl/rdoc/OpenSSL.html
require 'Base64'  # Dokumentation dazu: http://api.rubyonrails.org/v3.2.0/classes/Base64.html
class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :update, :destroy]

  def create
    # => Empfänger überhaupt vorhanden?
    if !User.exists?(username: params[:username])
      render json: { "Status" => "404 Not Found"}, status: :not_found
      logger.info "################# LOG #################"
      logger.info "Status: 404 - Not Found"
      logger.info "################# LOG #################"
    else 
      @outerMessage = OuterMessage.new(outer_message_params)
      @outerMessage.recipient = params[:username]
      # => Nachrichtenalter entsprich noch jünger als 5 min?
      if (Time.now.to_i-@outerMessage.timestamp) > 300
       render json: { "Status" => "408 Request Time-out"}, status: :request_timeout
       logger.info "################# LOG #################"
       logger.info "Status: 408 - Request Time-out"
       logger.info "################# LOG #################"
      else
        # => Krypto-Vorbereitung
        # => Pubkey des Users, der die Nachricht absendet.
        pubkey = OpenSSL::PKey::RSA.new(Base64.strict_decode64(User.find_by_username(@outerMessage.sender).pubkey_user))
        sig_service = Base64.strict_decode64(@outerMessage.sig_service)
        digest = OpenSSL::Digest::SHA256.new
        data =  @outerMessage.sender.to_s +
                Base64.strict_decode64(@outerMessage.cipher).to_s +
                Base64.strict_decode64(@outerMessage.iv).to_s +
                Base64.strict_decode64(@outerMessage.key_recipient_enc).to_s +
                Base64.strict_decode64(@outerMessage.sig_recipient).to_s +
                @outerMessage.timestamp.to_s +
                params[:username].to_s
        # => Signatur ist verifiziert? => http://ruby-doc.org/stdlib-2.0/libdoc/openssl/rdoc/OpenSSL.html
        if pubkey.verify digest, sig_service, data
        @message = Message.new( :recipient => params[:username],
                                :sender => @outerMessage.sender,
                                :cipher => @outerMessage.cipher,
                                :iv => @outerMessage.iv,
                                :key_recipient_enc => @outerMessage.key_recipient_enc,
                                :sig_recipient => @outerMessage.sig_recipient,)
          if @message.save 
            render json: @message, :only => [:username ,:sender, :cipher, :iv, :key_recipient_enc, :sig_recipient], status: :created
            logger.info "################# LOG #################"
            logger.info "Status: 201 - Created "
            logger.info "################# LOG #################"
          else
            render json: @message.errors, status: :unprocessable_entity
            logger.info "################# LOG #################"
            logger.info "Status: 422  - Unprocessable Entity"
            logger.info "################# LOG #################"
          end
         else
           render json: { "Status" => "401 Unauthorized"}, status: :unauthorized
           logger.info "################# LOG #################"
           logger.info "Status: 401 - Unauthorized"
           logger.info "################# LOG #################"
         # => Nachricht wurde gespeichert?
       end
      end
    end
  end

  def recieve
    if !User.exists?(username: params[:username])
      render json: { "Status" => "404 Not Found"}, status: :not_found
      logger.info "################# LOG #################"
      logger.info "Status: 404 - Not Found"
      logger.info "################# LOG #################"
    else
      # => Krypto-Vorbereitung
      digest = OpenSSL::Digest::SHA256.new
      # => Pubkey des Users, an den die Nachricht bestimmt ist.
      pubkey = OpenSSL::PKey::RSA.new(Base64.strict_decode64(User.find_by_username(params[:username]).pubkey_user))
      # => Empfang der Parameter
      timestamp = params[:timestamp].to_i
      signature = Base64.strict_decode64(params[:signature])
      data = params[:username]+timestamp.to_s
      # => Abfragealter entsprich noch jünger als 5 min?
      if (Time.now.to_i-timestamp) > 300
       render json: { "Status" => "408 Request Time-out"}, status: :request_timeout
       logger.info "################# LOG #################"
       logger.info "Status: 408 - Request Time-out"
       logger.info "################# LOG #################"
      else
        # => Signatur ist verifiziert? => http://ruby-doc.org/stdlib-2.0/libdoc/openssl/rdoc/OpenSSL.html
        if pubkey.verify digest, signature, data
          # Liefern der Nachricht
          @messages = Message.where(:recipient => params[:username])
          if @messages==nil
            render json: { "Status" => "404 Not Found"}, status: :not_found
            logger.info "################# LOG #################"
            logger.info "Status: 404 - Not Found"
            logger.info "################# LOG #################"
          else
            render json: @messages, :only => [:sender, :cipher, :iv, :key_recipient_enc, :sig_recipient]
            logger.info "################# LOG #################"
            logger.info @messages.to_json
            logger.info "Status: 200 OK"
            logger.info "################# LOG #################"
          end
        else
           render json: { "Status" => "401 Unauthorized"}, status: :unauthorized
            logger.info "################# LOG #################"
            logger.info "Status: 401 - Unauthorized"
            logger.info "################# LOG #################"
         end
      end
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