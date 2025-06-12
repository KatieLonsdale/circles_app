class JsonWebTokenService
  if Rails.env.production?
    SECRET_KEY = ENV['SECRET_KEY_BASE']
  else
    SECRET_KEY = Rails.application.secrets.secret_key_base.to_s
  end

  def self.encode(payload, exp = 30.days.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    body = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(body)
  rescue JWT::DecodeError
    nil
  end
end
