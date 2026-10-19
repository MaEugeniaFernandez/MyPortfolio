source "https://rubygems.org"

# LOCAL PREVIEW ONLY. GitHub Pages ignores this file and always builds with
# its own fixed versions (Jekyll 3.10, see https://pages.github.com/versions/).
#
# The brief asks for the "github-pages" gem here for exact parity, but its
# current release (232) only installs on Ruby < 4.0, and this Mac has Ruby 4.0.
# Until a Ruby 3.3 is set up (see the build brief, section 9), plain Jekyll 4
# is used instead. It renders this site the same way; the only gap is that
# GitHub's stricter older Sass could reject syntax Jekyll 4 accepts, so after
# editing anything under assets/ check the repo's Actions tab after uploading.
gem "jekyll", "~> 4.3"
gem "webrick"
gem "kramdown-parser-gfm", "1.1.0"

# Markdown converter and code highlighter pinned to GitHub Pages' versions,
# so code blocks and headings come out exactly as they do on the live site.
gem "kramdown", "2.4.0"
gem "rouge", "3.30.0"

# Plugins GitHub Pages switches on by default for every site. Listed here only
# so the local preview behaves like the live site; versions match GitHub Pages.
group :jekyll_plugins do
  gem "jekyll-optional-front-matter", "0.3.2"
  gem "jekyll-default-layout", "0.1.5"
  gem "jekyll-titles-from-headings", "0.5.3"
  gem "jekyll-relative-links", "0.6.1"
  gem "jekyll-readme-index", "0.3.0"
end
