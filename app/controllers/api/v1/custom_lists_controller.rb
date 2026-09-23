# frozen_string_literal: true

module Api
  module V1
    class CustomListsController < ApplicationController
      include InteractionRequest

      def index
        owner = device_id
        return unless owner

        render json: { lists: CustomList.where(device_id: owner).includes(:items).order(updated_at: :desc).map { |list| serialize(list) } }
      end

      def create
        owner = device_id
        return unless owner

        list = CustomList.new(device_id: owner, name: params[:name].to_s.strip)
        list.save ? render(json: serialize(list), status: :created) : invalid_record(list)
      end

      def update
        list = owned_list
        return unless list

        list.name = params[:name].to_s.strip
        list.save ? render(json: serialize(list)) : invalid_record(list)
      end

      def destroy
        list = owned_list
        return unless list

        list.destroy!
        head :no_content
      end

      def add_item
        list = owned_list
        return unless list

        key = item_key
        return unless key

        item = list.items.find_or_initialize_by(media_type: key[0], title_id: key[1])
        item.position ||= (list.items.maximum(:position) || -1) + 1
        item.save ? render(json: serialize(list.reload), status: :created) : invalid_record(item)
      end

      def remove_item
        list = owned_list
        return unless list

        key = item_key
        return unless key

        list.items.where(media_type: key[0], title_id: key[1]).delete_all
        head :no_content
      end

      def shared
        list = CustomList.includes(:items).find_by(share_token: params[:token])
        return render_error("not_found", "List not found", :not_found) unless list

        render json: { list: serialize(list).except(:id, :share_token) }
      end

      private

      def owned_list
        owner = device_id
        return unless owner

        list = CustomList.includes(:items).find_by(id: params[:id], device_id: owner)
        return list if list

        render_error("not_found", "List not found", :not_found)
        nil
      end

      def item_key
        type = params[:media_type]
        id = params[:title_id].to_s
        return [type, id.to_i] if type == "tv" && id.match?(/\A[1-9]\d*\z/)

        render_error("invalid_title", "Invalid title identifier", :unprocessable_content)
        nil
      end

      def serialize(list)
        { id: list.id, name: list.name, share_token: list.share_token,
          items: list.items.sort_by(&:position).map { |item| { media_type: item.media_type, title_id: item.title_id } } }
      end
    end
  end
end
