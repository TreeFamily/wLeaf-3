class Autovoice
  include Cinch::Plugin
  
  listen_to :join
  prefix "<"
  match /autovoice (on|off)/ , method: :setOpt
  match /autovoice$/ , method: :getOpt
  def initialize(*args)
    super
    @autovoice = {"#werring"=>true}
    
    
  end
  def listen(m)
    unless m.user.nick == bot.nick
      m.channel.voice(m.user) if @autovoice[m.channel.name]
      
    end
  end

  def setOpt(m, option)
    @autovoice[m.channel.name] = option == "on"

    m.reply "Autovoice is now #{@autovoice[m.channel.name] ? 'enabled' : 'disabled'}"
  end
  def getOpt(m)
    m.reply "Autovoice is #{@autovoice[m.channel.name] ? 'enabled' : 'disabled'}"
  end
end