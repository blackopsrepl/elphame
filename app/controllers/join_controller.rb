class JoinController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    user = User.create_bot!(**agent_params)
    render json: {
      bot_key: user.bot_key,
      name: user.username,
      realms: Realm.order(:position).map { |r|
        { id: r.id, name: r.name, slug: r.slug }
      }
    }, status: :created
  rescue KeyError
    render json: { error: "name is required" }, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  private

  def agent_params
    body = JSON.parse(request.body.read)
    { name: body.fetch("name"), webhook_url: body["webhook_url"] }.compact_blank
  end
end
