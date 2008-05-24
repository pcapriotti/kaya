require 'item'

module ItemBag
  def add_item(key, *args)
    remove_item key
    item = create_item(key, *args)
    items[key] = item
  end
  
  def remove_item(key, *args)
    if items[key]
      destroy_item items[key] unless args.include? :keep
      removed = items[key]
      items[key] = nil
      removed
    end
  end
  
  def move_item(src, dst)
    remove_item dst
    items[dst] = items[src]
    items[src] = nil
    items[dst]
  end
end
