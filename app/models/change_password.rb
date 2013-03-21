class ChangePassword
  include ActiveModel::Validations

  attr_accessor :developer
  attr_accessor :current_password
  attr_accessor :new_password, :new_password_confirmation

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  validates_presence_of :current_password, :new_password, :new_password_confirmation
  validate :current_password_matches

  def initialize(attributes={})
    attributes && attributes.each do |name, value|
      send("#{name}=", value) if respond_to? name.to_sym
    end
  end

  def persisted?
    false
  end

  def self.inspect
    "#<#{ self.to_s} #{ self.attributes.collect{ |e| ":#{ e }" }.join(', ') }>"
  end

  def save
    if self.valid?
      @developer.password = new_password
      @developer.password_confirmation = new_password_confirmation
      if @developer.save
        return true
      else
        errors.merge!(@developer.errors)
      end
    end
    return false
  end

  private
  def current_password_matches
    devSession = DeveloperSession.new({:email => @developer.email,
                                      :password => @current_password})
    unless devSession.valid?
      errors.add(:current_password, "is incorrect.")
    end
  end
end
