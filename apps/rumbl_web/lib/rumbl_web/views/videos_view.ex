defmodule RumblWeb.VideosView do
  use RumblWeb, :view

  def category_select_option(categories) do
    for category <- categories do
      {category.name, category.id}
    end
  end
end
