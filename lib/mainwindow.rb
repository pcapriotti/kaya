class MainWindow < KDE::XmlGuiWindow
  def initialize(loader)
    super nil
    
    @loader = loader
  end
end
