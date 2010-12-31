class JoinPart
  include Cinch::Plugin
  prefix ">"
  match /join (.+)/, method: :join
  match /part(?: (.+))?/, method: :part
  match /quit(?: (.+))?/, method: :quit
  
  def initialize(*args)
    super
    @team = nil
    ObjectSpace.each_object(Team) do |teamObj|
      @team = teamObj
    end
  end
  
  def join(m, channel)
    return unless @team.helper(m.user)
    Channel(channel).join
  end

  def part(m, channel)
    return unless @team.admin(m.user)
    channel ||= m.channel
    Channel(channel).part if channel
  end
  
  def quit(m,msg)
    return unless @team.admin(m.user)
    msg ||="Quiting...."
    @bot.quit msg
  end
  
end