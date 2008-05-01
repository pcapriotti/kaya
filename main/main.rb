require 'korundum4'

description = "KDE Board Game Suite"
version = "1.5"
about = KDE::AboutData.new("tagua", "Tagua", KDE.ki18n(description),
    version, KDE.ki18n(description),KDE::AboutData::License_GPL,KDE.ki18n("(C) 2003 whoever the author is"))

about.addAuthor(KDE.ki18n("author1"), KDE.ki18n("whatever they did"), "email@somedomain")
about.addAuthor(KDE.ki18n("author2"), KDE.ki18n("they did something else"), "another@email.address")

KDE::CmdLineArgs.init(ARGV, about)

app = KDE::Application.new
main_window = KDE::MainWindow.new(nil)
main_window.show
app.exec
