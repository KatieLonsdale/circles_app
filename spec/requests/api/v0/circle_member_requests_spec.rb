require 'rails_helper'

RSpec.describe 'Circle Member API', type: :request do
  describe 'create a circle member' do
    it 'creates a circle member if user is circle owner' do
      users = create_list(:user, 3)
      # owner
      owner = users[0]
      circle = create(:circle, user_id: owner.id)
      # member, not owner
      member = users[1]
      create(:circle_member, circle_id: circle.id, user_id: member.id)
      # not member or owner
      newbie = users[2]

      post "/api/v0/users/#{member.id}/circles/#{circle.id}/circle_members", params: { new_member_id: newbie.id }

      expect(response.status).to eq(401)
      expect(JSON.parse(response.body, symbolize_names: true)[:errors]).to eq("Unauthorized")
      expect(CircleMember.count).to eq(1)

      post "/api/v0/users/#{owner.id}/circles/#{circle.id}/circle_members", params: { new_member_id: newbie.id }

      expect(response.status).to eq(201)
      response_data = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(response_data[:type]).to eq("circle_member")
      expect(response_data[:attributes][:user_id]).to eq(newbie.id)
      expect(response_data[:attributes][:circle_id]).to eq(circle.id)
    end
  end
end