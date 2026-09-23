# frozen_string_literal: true

require "cgi"

class PublicListsController < ApplicationController
  def show
    list = CustomList.includes(:items).find_by(share_token: params[:token])
    return render plain: "Подборка не найдена", status: :not_found unless list

    response.set_header("X-Robots-Tag", "noindex")
    cards = list.items.sort_by(&:position).first(24).map do |item|
      details = begin
        external_content.title(media_type: item.media_type, id: item.title_id, language: "ru-RU", region: "RU")
      rescue StandardError
        {}
      end
      title = details[:title].presence || details["title"].presence || "Сериал №#{item.title_id}"
      poster = details[:poster_url].presence || details["poster_url"].presence
      image = poster&.start_with?("https://image.tmdb.org/t/p/") ? %(<img src="#{CGI.escapeHTML(poster)}" alt="">) : ""
      %(<article>#{image}<h2>#{CGI.escapeHTML(title)}</h2></article>)
    end.join
    name = CGI.escapeHTML(list.name)
    token = CGI.escapeHTML(list.share_token)
    html = <<~HTML
      <!doctype html>
      <html lang="ru"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
      <title>#{name} · ReelTalk</title><meta property="og:title" content="#{name} · ReelTalk">
      <style>
        *{box-sizing:border-box}body{margin:0;background:#171923;color:#fff;font-family:system-ui,-apple-system,sans-serif}
        main{max-width:1040px;margin:auto;padding:48px 20px}a{color:#ffb9aa}header{margin-bottom:36px}
        small{color:#ffb9aa;font-weight:700;letter-spacing:.14em}h1{font-size:clamp(2rem,6vw,4rem);margin:12px 0}
        p{color:#c9c8d1}.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(150px,1fr));gap:18px}
        article{background:#292b37;border-radius:18px;overflow:hidden}article img{width:100%;aspect-ratio:2/3;object-fit:cover}
        article h2{font-size:1rem;padding:0 14px 14px}.button{display:inline-block;background:#ffb9aa;color:#171923;text-decoration:none;padding:12px 18px;border-radius:12px;font-weight:700}
      </style></head><body><main><header><small>REELTALK · ПОДБОРКА</small><h1>#{name}</h1>
      <p>Дорамы, собранные пользователем ReelTalk.</p><a class="button" href="reeltalk://shared/#{token}">Открыть в приложении</a></header>
      <div class="grid">#{cards}</div></main></body></html>
    HTML
    render html: html.html_safe
  end
end
