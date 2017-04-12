require 'sinatra'
require 'httparty'
require 'json'

post '/gateway' do
  return if params[:token] != ENV['SLACK_TOKEN']

  message = params[:text].gsub(params[:trigger_word], '').strip

  action = message.split.first
  term = message.split(' ')[1..-1].join(' ')

  compliments = ["you are soooooo good lookin'", "your teeth are lookin' shiny today", "I admire your courage", "nobody does it better than you", "you are kind to animals", "you are so beautiful that you know what I mean", "you’re to be a key? Because I can bear your toot?", "you look like a thing and I love you", "you are so beautiful that you make me feel better to see you"]

  case action
  # when 'ashley'
  #   respond_message "Ashley, you are soooooo good lookin'"
  when 'I'
    respond_message params[:user_name] + ", " + compliments[rand(compliments.length)]
  when 'define'
    term = term.gsub(" ", "+").gsub("\"", "")
    respond_message "http://lmgtfy.com/?q=#{term}"
  when 'add'
    add_message term
  else 
    if term == "needs love"
      respond_message action + ", " + compliments[rand(compliments.length)]
    end
  end
end

def respond_message message
  content_type :json
  {:text => message}.to_json
  #TODO include ethereal response to successful message add
end

def add_message message
  compliments.push(message) 
  respond_message "Thanks, I'll pass that on"
end


get '/anonymize' do
  postback params[:text], params[:channel_id]
  status 200
end
 
def postback message, channel
    # slack_webhook = ENV['SLACK_WEBHOOK_URL']
    url = ENV['SLACK_WEBHOOK_URL'] + "&channel=%23test"
    msg = params[:text]
    HTTParty.post(url, body: msg.to_json)

    # HTTParty.post slack_webhook, body: {"text" => message.to_s, "username" => "John Doe", "channel" => params[:channel_id]}.to_json, headers: {'content-type' => 'application/json'}

    # curl --data ":tea:" $'https://horacephair.slack.com/services/hooks/slackbot?token=lzGQgtMVo2e6cb9ewpWmvqET&channel=%23test'
end