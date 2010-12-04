
#
#    Terminus-Bot: An IRC bot to solve all of the problems with IRC bots.
#    Copyright (C) 2010  Terminus-Bot Development Team
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#

def initialize
  registerModule("Services", "Facilitate services authentication.")

  registerCommand("Services", "services automatic", "Activate or deactivate automatic identification with services. If no value is given, show the current value.", "[on|off]")
  registerCommand("Services", "services ident", "Send IDENTIFY command to services.")
  registerCommand("Services", "services nickserv", "Set the NickServ name (and optionally user@host) to use when identifying with NickServ or recognizing NickServ ident requests. If no value is provided, show the current value.", "[nickserv]")
  registerCommand("Services", "services password", "Sets the password to use with NickServ. If none is given, show the current value.", "[password]")
end

def cmd_services(message)
  return unless checkAdmin(message, 8)
  
  case message.msgArr[1].downcase

    when "nickserv"
      if message.msgArr[2] == nil
        current = get("NickServ")
        if current == nil
          reply(message, "NickServ is not set.")
        else
          reply(message, current)
        end
      else
        set("NickServ", message.msgArr[2])
        reply(message, "Changed successfully.")
      end
    when "password"
      if message.msgArr[2] == nil
        current = get("Password")
        if current == nil
          reply(message, "Password is not set.")
        else
          reply(message, current)
        end
      else
        set("Password", message.msgArr[2])
        reply(message, "Changed successfully.")
      end
    when "automatic"
      if message.msgArr[2] == nil
        current = get("Automatic")
        if current == nil
          reply(message, "Automatic is not set.")
        else
          reply(message, current)
        end
      else
        if message.msgArr[2].downcase == "on" or message.msgArr[2].downcase == "off"
          set("Automatic", message.msgArr[2].downcase)
          reply(message, "Changed successfully.")
        else
          reply(message, "Invalid choice: must be #{BOLD}off#{NORMAL} or #{BOLD}on#{NORMAL}.")
        end
      end
    when "identify"
      sendIdentMessage
      reply(message, "Sent IDENTIFY message.")
  end
end

def bot_notice(message)
  if message.message =~ /nickname is registered/i
    $log.debug('services') { "Auto-identify checking for match: #{message.message} from #{message.speaker.to_s}" }

    nickserv = get("NickServ")
    auto = get("Automatic")

    return if nickserv == nil or auto == nil

    if message.speaker.to_s =~ /#{Regexp.escape(nickserv)}/ and auto == "on"
      $log.info('services') { "Auto-identify triggered by #{message.message} from #{message.speaker.to_s}" }
      sendIdentMessage
    end

  end
end

def sendIdentMessage
  destination = get("NickServ")
  password = get("Password")

  sendPrivmsg(destination, "IDENTIFY #{password}")
  sendPrivmsg(destination, "UPDATE")
end
