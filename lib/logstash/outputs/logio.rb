# # encoding: utf-8
# require "logstash/outputs/base"
# require "logstash/namespace"

# # An example output that does nothing.
# class LogStash::Outputs::Example < LogStash::Outputs::Base
#   config_name "example"

#   public
#   def register
#   end # def register

#   public
#   def receive(event)
#     return "Event received"
#   end # def event
# end # class LogStash::Outputs::Example


require "logstash/outputs/base"
require "logstash/namespace"
require "socket"

# Log.io Output
#
# Sends events to a Log.io server over TCP.
#
# Plugin is fault tolerant.  If the plugin is unable to connect to the server,
# or writes to a broken socket, it will attempt to reconnect indefinitely.
#
class LogStash::Outputs::LogIO < LogStash::Outputs::Base

  config_name "logio"
  plugin_status "experimental"

  # log.io server host
  config :host, :validate => :string, :required => true

  # log.io server TCP port
  config :port, :validate => :number, :default => 28777

  # log.io TCP message format
  config :format, :default => "+log|%{@source}|%{@source_host}|%{@level}|%{@timestamp}: %{@message}\r\n"

  public
  def register
    connect
  end

  public
  def receive(event)
    return unless output?(event)
    msg = event.sprintf(@format)
    send_log(msg)
  end

  private
  def connect
    begin
      @sock = TCPSocket.open(@host, @port)
    rescue
      sleep(2)
      connect
    end
  end

  private
  def send_log(msg)
    begin
      @sock.puts msg
    rescue
      sleep(2)
      connect
    end
  end
end
