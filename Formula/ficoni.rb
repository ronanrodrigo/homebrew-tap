class Ficoni < Formula
  desc "Custom icons for Finder sidebar items via Finder Sync helper apps"
  homepage "https://github.com/ronanrodrigo/ficoni"
  url "https://github.com/ronanrodrigo/ficoni/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "1f01d063f3e7818701fe17a5fc8dbeeac8d40c4d4f1c366461002c23b5ffc779"
  license "MIT"
  head "https://github.com/ronanrodrigo/ficoni.git", branch: "main"

  # The tool compiles (swiftc) and codesigns a Finder Sync helper app per folder.
  depends_on xcode: ["13.0", :clt_only]
  depends_on macos: :ventura

  def install
    # Layout the scripts expect: <libexec>/ficoni/{scripts,examples,assets},
    # because build_manager.sh and install_examples.sh resolve ROOT as "<scripts dir>/.."
    # and then look for assets/AppIcon.icns and examples/*.json there.
    root = libexec/"ficoni"
    root.install "scripts"
    root.install "examples"
    # Only the bits the scripts actually consume; the repo's assets/ also carries
    # README screenshots, which have no business in libexec.
    (root/"assets").install "assets/AppIcon.icns", "assets/example-config.json"

    chmod 0755, root/"scripts/build_icon_app.sh"
    chmod 0755, root/"scripts/build_manager.sh"
    chmod 0755, root/"scripts/install_examples.sh"

    # The wrapper finds the scripts through its own (symlink-resolved) location:
    # bin/../libexec/ficoni/scripts.
    bin.install "bin/sidebar-icon"
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/sidebar-icon help")
    assert_match "add --name", shell_output("#{bin}/sidebar-icon help")
  end

  def caveats
    <<~EOS
      sidebar-icon builds each helper app on this Mac: it needs an
      "Apple Development" code-signing identity (Xcode > Settings > Accounts), because an
      ad-hoc signed extension is often not picked up by pkd.

      The helper apps land in ~/Applications/Ficoni/ and register a Finder Sync
      extension each; the sidebar draws the icon of the app that owns the folder.

      First command:

        sidebar-icon add --name Projects --target ~/Projects --symbol hammer

      Other commands: sidebar-icon help, examples, manager, status, favorites, remove, uninstall.
    EOS
  end
end
