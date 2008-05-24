module Theme
  def item(scene, *args)
    pixmap(*args).to_item(scene)
  end
end
