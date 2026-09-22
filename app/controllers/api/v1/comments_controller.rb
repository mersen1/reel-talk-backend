module Api
  module V1
    class CommentsController < ApplicationController
      include InteractionRequest

      def index
        owner = device_id
        key = title_key
        return unless owner && key
        episode = episode_key
        return if performed?

        comments = Comment.where(media_type: key[0], title_id: key[1], season_number: episode&.first,
          episode_number: episode&.last).includes(:comment_likes).order(:created_at).to_a
        by_parent = comments.group_by(&:parent_id)
        by_id = comments.index_by(&:id)
        render json: { comments: (by_parent[nil] || []).reverse.map { |comment| serialize(comment, by_parent, owner, by_id) } }
      end

      def create
        owner = device_id
        key = title_key
        return unless owner && key
        episode = episode_key
        return if performed?

        guest = GuestUser.find_by!(device_id: owner)
        comment = Comment.new(device_id: owner, media_type: key[0], title_id: key[1],
          season_number: episode&.first, episode_number: episode&.last,
          user_name: guest.display_name, body: params[:text], parent_id: params[:parent_id])
        comment.save ? render(json: serialize(comment, {}, owner, {}), status: :created) : invalid_record(comment)
      end

      def like
        owner = device_id
        return unless owner

        comment = Comment.find_by(id: params[:id])
        return render_error("not_found", "Comment not found", :not_found) unless comment

        liked = ActiveModel::Type::Boolean.new.cast(params[:liked])
        if liked
          CommentLike.find_or_create_by!(comment: comment, device_id: owner)
        else
          CommentLike.where(comment: comment, device_id: owner).delete_all
        end
        render json: { id: comment.id, likes: comment.comment_likes.count, is_liked: liked }
      end

      private

      def episode_key
        return nil unless params.key?(:season_number) || params.key?(:episode_number)

        season = params[:season_number].to_s
        episode = params[:episode_number].to_s
        return [season.to_i, episode.to_i] if season.match?(/\A[1-9]\d*\z/) && episode.match?(/\A[1-9]\d*\z/)

        render_error("invalid_episode", "Invalid episode identifier", :unprocessable_content)
        nil
      end

      def serialize(comment, by_parent, owner, by_id)
        { id: comment.id, user_name: comment.user_name, text: comment.body,
          likes: comment.comment_likes.size, is_liked: comment.comment_likes.any? { |like| like.device_id == owner },
          created_at: comment.created_at.iso8601,
          reply_to_user_name: by_id[comment.parent_id]&.user_name,
          replies: (by_parent[comment.id] || []).map { |reply| serialize(reply, by_parent, owner, by_id) } }
      end
    end
  end
end
