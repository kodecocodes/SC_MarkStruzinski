class User
    attr_accessor :email, :password

    def initialize(attributes = {})
        @email = attributes[:email]
        @password = attributes[:password]
    end
end