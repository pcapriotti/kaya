$:.unshift(File.dirname(__FILE__))
require 'qtutils'
require 'mainwindow'
require 'themes/loader'

if $0 == __FILE__
  app = KDE::Application.init(
    :version => '0.1',
    :id => 'kaya',
    :name => KDE.ki18n('Kaya'),
    :description => KDE.ki18n('KDE Board Game Suite'),
    :copyright => KDE.ki18n('(C) 2009 Paolo Capriotti'),
    :authors => [[KDE.ki18n('Paolo Capriotti'), 'p.capriotti@gmail.com']],
    :contributors => [[KDE.ki18n("Jani Huhtanen"), KDE.ki18n('Gaussian blur code')]],
    :bug_tracker => 'http://github.com/pcapriotti/kaya/issues')
    
  
  theme_loader = ThemeLoader.new
  main = MainWindow.new(theme_loader)
  
  main.show
  app.exec
end
