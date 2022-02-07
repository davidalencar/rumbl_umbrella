defmodule RumblWeb.VideosChannel do
  use RumblWeb, :channel

  alias Rumbl.{Accounts, Multimedia}

  @impl true
  def join("videos:" <> video_id , payload, socket) do
    send(self(), :after_join)
    video_id = String.to_integer(video_id)
    video = Multimedia.get_videos!(video_id)
    last_seen_id = payload["last_seen_id"] || 0

    annotations = video
                  |> Multimedia.list_annotations(last_seen_id)
                  |> Phoenix.View.render_many(RumblWeb.AnnotationView, "annotation.json")

      {:ok,%{annotations: annotations}, assign(socket, :video_id, video_id)}
  end

  @impl true
  def handle_info(:after_join, socket) do
      push(socket, "presence_state", RumblWeb.Presence.list(socket))
      {:ok, _} = RumblWeb.Presence.track(socket, socket.assigns.user_id,%{device: "browser"})

      {:noreply, socket}
  end

  @impl true
  def handle_in(event, payload, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    handle_in(event, payload, user,socket)
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("new_annotation", payload, user, socket) do
    case Multimedia.annotate_video(user, socket.assigns.video_id, payload) do
      {:ok, annotation} ->
        broadcast_annotationn(socket, user, annotation)

        Task.start(fn ->
          compute_additionalinfo(annotation, socket)
        end)

        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  defp broadcast_annotationn(socket, user, annotation) do
    broadcast!(socket, "new_annotation", %{
      id: annotation.id,
        user: RumblWeb.UserView.render("user.json", %{user: user}),
        body: annotation.body,
        at: annotation.at
      })
  end

  defp compute_additionalinfo(annotation, socket) do
    for result <- InfoSys.compute(annotation.body, limit: 1, timeout: 10_000) do
      IO.puts "-----------------"
      IO.inspect(result)
      backend_user = Accounts.get_user_by(username: result.backend.name())

      attrs = %{body: result.text, at: annotation.at}

      case Multimedia.annotate_video(backend_user, annotation.videos_id, attrs) do
        {:ok, info_ann} ->
          broadcast_annotationn(socket, backend_user, info_ann)
        {:error, _changeset} ->
          :ignore
      end
    end
  end
end
