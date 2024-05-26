require 'dry-types'
require 'dry-struct'
require 'time'

# игровой объект
#   игрок
#   предметы
#   препятствия
# coors
#   игровое поле
#   объекты
# actions
#   move
#   attack
#   jump

# module Types
#   include Dry.Types()

#   Coordinates = Struct.new(:x, :y)
#   PlayerStatus = String.enum('alive', 'dead')
# end

# module Game
#   class Player < Dry::Struct
#     attribute :name, Types::String
#     attribute :position, Types::Coordinates
#     attribute :status, Types::PlayerStatus
#   end
# end

module Types
  include Dry.Types()

  Age = Integer.constrained(gteq: 0)
end

class User < Dry::Struct
  attribute :name, Types::Strict::String.constrained(format: /\A\p(Alnum)+ \z/)
  attribute :age, Types::Age
  attribute :height, Types::Coercible::Float
  attribute :type?, Types::Symbol.default(:guest).enum(:guest, :admin, :investor)
  attribute :sad, Types.Instance(Range)
end

alln = User.new name: 'Allen', age: 39, height: '100.1'

p alln.inspect

user_hash = Types::Hash.schema(
  name: Types::Strict::String,
  age: Types::Strict::Integer.
        default(18).
        constructor { |value|
          value.nil? ? Dry::Types::Undefined : value    
        }
).strict.with_key_transform(&:to_sym)

p user_hash[name: 'asdasd', age:nil]


# fallback если неправильный тип
# default если пусто

class Account < Dry::Struct
  attribute :owner, User
  attribute :balance, Types::Strict::Integer.fallback(0) | Types::Strict::Float.fallback(0.0)
  attribute :description, Types::Strict::String.fallback("about account...".freeze)
  attribute :about, Types::Strict::String.optional
  attribute :deleted_at, Types::JSON::Time.default {Time.now}
  attribute :locked, Types::Params::Bool
  attribute :tags?, Types::Strict::Array.of(Types::Coercible::String)
end

a = Account.new owner: alln, balance: "s,", about: nil, description: nil,
                deleted_at: "1992-01-25 12:00:00", locked: 'true'
p a