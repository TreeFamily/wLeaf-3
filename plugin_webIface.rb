require 'digest/sha1'

class WebIface
  include Cinch::Plugin
  prefix ">"
  match /createwebpass(?: (.+))?/i , method: :createPass
  
  def initialize(*args)
    super
    ObjectSpace.each_object(Team) do |teamObj|
      @team = teamObj
    end
    @mysql = nil
    ObjectSpace.each_object(Mysql) { |o|
	 @mysql = o
    }
  end
  
  def createPass(m,passwd)
    return unless @team.helper(m.user)
    passwd ||= password 8
    sha1Pass = Digest::SHA1.hexdigest(passwd)
    @mysql.query("UPDATE `rubyTest`.`team` SET `passwd` = '#{sha1Pass}' WHERE `auth`='#{m.user.authname}';")
    m.user.send "You can now login with #{m.user.authname} #{passwd}"
    
  end
  
  
  def password(size = 6)
    c = %w(b c d f g h j k l m n p qu r s t v w x z ch cr fr nd ng nk nt ph pr rd sh sl sp st th tr)
    v = %w(a e i o u y)
    f, r = true, ''
    (size * 2).times do
	 r << (f ? c[rand * c.size] : v[rand * v.size])
	 f = !f
    end
    r
  end

end