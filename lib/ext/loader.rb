begin
  require 'ext/extensions'
rescue LoadError => e
  warn "ERROR: could not load extension library, some features may be missing"
  warn e.message
end

$ext = $qApp.findChild(Qt::Object, "kaya extensions") if $qApp
fake = unless $ext
  # install fake implementations of the extension functions
  warn "Creating fake extension library"
  $ext = Qt::Object.new
  class << $ext
    def exp_blur(img, radius)
    end
  end
  true
end
$ext.metaclass_eval do
  define_method(:fake) { fake }
end

# conveniently install extension functions in the appropriate places

class Qt::Image
  def exp_blur(radius)
    $ext.exp_blur(self, radius)
  end
end
